import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/business.dart';
import 'package:carl_api/model/notification.dart';
import 'package:carl_api/model/user.dart';
import 'package:carl_api/response/business_send_notification_response.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';

class AdminSendNotificationsController extends ResourceController {
  AdminSendNotificationsController(this._context, this.firebaseServerKey);

  final ManagedContext _context;
  final String firebaseServerKey;

  @Operation.post()
  Future<Response> adminSendNotificationToCampaign(
    @Bind.query("title") String title,
    @Bind.query("description") String description,
  ) async {
    final getAccountQuery = Query<Account>(_context)
      ..where((account) => account.id).equalTo(request.authorization.ownerID)
      ..where((account) => account.isAdmin).equalTo(true);

    final account = await getAccountQuery.fetchOne();

    if (account == null) {
      return Response.unauthorized();
    }

    var querySql = """
    SELECT _user.notificationstoken, _user.id
    FROM _user;
    """;

    final tokensAndIdsList = await _context.persistentStore.execute(querySql) as List<List<dynamic>>;

    if (tokensAndIdsList.isEmpty) {
      return Response.ok(BusinessSendNotificationResponse(success: true, nbMatchedUsers: 0, error: null));
    }

    final getBusinessQuery = Query<Business>(_context)
      ..where((business) => business.id).identifiedBy(account.business.id);
    final business = await getBusinessQuery.fetchOne();

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
