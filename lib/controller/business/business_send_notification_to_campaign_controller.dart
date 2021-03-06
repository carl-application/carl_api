import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/business.dart';
import 'package:carl_api/model/campaign.dart';
import 'package:carl_api/model/notification.dart';
import 'package:carl_api/model/setting.dart';
import 'package:carl_api/model/user.dart';
import 'package:carl_api/response/business_send_notification_response.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';

class BusinessSendNotificationToCampaignController extends ResourceController {
  BusinessSendNotificationToCampaignController(this._context, this.firebaseServerKey);

  final ManagedContext _context;
  final String firebaseServerKey;

  @Operation.post()
  Future<Response> sendNotificationToCampaign(
    @Bind.query('targetCampaignId') int targetCampaignId,
    @Bind.query("title") String title,
    @Bind.query("description") String description,
  ) async {
    final getAccountQuery = Query<Account>(_context)
      ..where((account) => account.id).equalTo(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final account = await getAccountQuery.fetchOne();

    if (account == null || account.business == null) {
      return Response.unauthorized();
    }

    final getCampaignQuery = Query<Campaign>(_context)
      ..where((campaign) => campaign.id).identifiedBy(targetCampaignId)
      ..where((campaign) => campaign.business.id).identifiedBy(account.business.id);

    final campaign = await getCampaignQuery.fetchOne();

    var querySql = """
    SELECT _user.notificationstoken, _user.id
    FROM _user
    INNER JOIN _customerrelationship
    ON _customerrelationship.user_id = _user.id
    WHERE _customerrelationship.business_id = ${account.business.id}
    AND date_part('year',age(birthdate)) >= ${campaign.ageMin ?? 0}
    AND date_part('year',age(birthdate)) <= ${campaign.ageMax ?? 130}
    """;

    if (!campaign.men) {
      querySql += """
      AND _user.sex != 'man'
      """;
    }

    if (!campaign.women) {
      querySql += """
      AND _user.sex != 'woman'
      """;
    }

    if (!campaign.np) {
      querySql += """
      AND _user.sex != 'np'
      """;
    }

    if (campaign.visitedPeriodStart != null) {
      querySql += """
      AND 0 < (
      SELECT Count(_visit.id)
      FROM _visit
      WHERE _visit.user_id = _user.id
      AND _visit.business_id = ${account.business.id}
      AND _visit.date >= '${campaign.visitedPeriodStart.toIso8601String()}'::date
      )
      """;
    }

    if (campaign.visitedPeriodEnd != null) {
      querySql += """
      AND 0 < (
      SELECT Count(_visit.id)
      FROM _visit
      WHERE _visit.user_id = _user.id
      AND _visit.business_id = ${account.business.id}
      AND _visit.date <= '${campaign.visitedPeriodEnd.toIso8601String()}'::date
      )
      """;
    }

    querySql += ";";
    final tokensAndIdsList = await _context.persistentStore.execute(querySql) as List<List<dynamic>>;

    if (tokensAndIdsList.isEmpty) {
      return Response.ok(BusinessSendNotificationResponse(success: true, nbMatchedUsers: 0, error: null));
    }

    final getBusinessQuery = Query<Business>(_context)
      ..where((business) => business.id).identifiedBy(account.business.id);
    final business = await getBusinessQuery.fetchOne();

    final now = DateTime.now();
    final startingMonth = now.subtract(Duration(
        days: now.day - 1,
        hours: now.hour,
        minutes: now.minute,
        seconds: now.second,
        milliseconds: now.millisecond,
        microseconds: now.microsecond));

    final endingMonth = DateTime(now.year, now.month + 1);
    final getMonthTotalNotificationSentQuery = """
    SELECT Count(_notification.id)
    FROM _notification
    WHERE _notification.date >= '${startingMonth.toIso8601String()}'::date
    AND _notification.date <= '${endingMonth.toIso8601String()}'::date
    AND _notification.business_id = ${business.id};
    """;

    final result = await _context.persistentStore.execute(getMonthTotalNotificationSentQuery);
    final totalNotificationSent = result[0][0] as int;

    final settings = await Query<Settings>(_context).fetchOne();
    if (totalNotificationSent > settings.nbFreeNotificationsPerMonth &&
        !account.isAdmin &&
        business.planType != PlanType.premium) {
      return Response.ok(BusinessSendNotificationResponse(
          success: false, nbMatchedUsers: 0, error: Constants.SENDING_NOTIFICATION_LIMIT));
    }

    final List<Future<User>> usersQueries = [];

    tokensAndIdsList.forEach((tokenId) {
      final userQuery = Query<User>(_context)..where((user) => user.id).identifiedBy(tokenId[1]);
      usersQueries.add(userQuery.fetchOne());
    });

    final users = await Future.wait(usersQueries);

    final List<Future<Notification>> notificationQueries = [];
    final List<String> tokens = [];

    users.forEach((user) {
      tokens.add(user.notificationsToken);
      final insertNotificationQuery = Query<Notification>(_context)
        ..values.type = NotificationType.simple
        ..values.title = title
        ..values.description = description
        ..values.user = user
        ..values.business = account.business;

      notificationQueries.add(insertNotificationQuery.insert());
    });

    await Future.wait(notificationQueries);

    final getUsersThatAreNotOkForNotificationsQuery = """
          SELECT _user.notificationstoken
          FROM _user
          INNER JOIN _notificationsblacklist
          ON _notificationsblacklist.user_id = _user.id
          WHERE _notificationsblacklist.business_id = ${business.id};
        """;

    final doNotDisturbUsersTokens =
        await _context.persistentStore.execute(getUsersThatAreNotOkForNotificationsQuery) as List<List<dynamic>>;

    doNotDisturbUsersTokens.forEach((token) {
      tokens.remove(token[0]);
    });

    if (tokens.isEmpty) {
      return Response.ok(
          BusinessSendNotificationResponse(success: true, nbMatchedUsers: tokensAndIdsList.length, error: null));
    }

    final response = await http.post("https://fcm.googleapis.com/fcm/send",
        headers: {
          HttpHeaders.authorizationHeader: "key=$firebaseServerKey",
          HttpHeaders.contentTypeHeader: "application/json"
        },
        body: json.encode({
          "registration_ids": tokens,
          "notification": {"body": title, "title": business.name}
        }));

    if (response.statusCode != 200) {
      return Response.serverError(
          body: BusinessSendNotificationResponse(
              success: false,
              nbMatchedUsers: tokensAndIdsList.length,
              error: Constants.SENDING_NOTIFICATION_FIREBASE_ERROR));
    }

    return Response.ok(
        BusinessSendNotificationResponse(success: true, nbMatchedUsers: tokensAndIdsList.length, error: null));
  }
}
