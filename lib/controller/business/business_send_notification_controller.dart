import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/notification.dart';
import 'package:carl_api/model/user.dart';
import 'package:carl_api/response/business_send_notification_response.dart';
import 'package:http/http.dart' as http;

class BusinessSendNotificationController extends ResourceController {
  BusinessSendNotificationController(this._context, this.firebaseServerKey);

  final ManagedContext _context;
  final String firebaseServerKey;

  @Operation.post()
  Future<Response> sendNotificationToUniqueUser(
    @Bind.query('targetUserId') int targetUserId,
    @Bind.query("title") String title,
    @Bind.query("shortDescription") String shortDescription,
    @Bind.query("description") String description,
  ) async {
    final getBusinessQuery = Query<Account>(_context)
      ..where((account) => account.id).equalTo(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final account = await getBusinessQuery.fetchOne();

    if (account == null || account.business == null) {
      return Response.unauthorized();
    }

    final getUserQuery = Query<User>(_context)
      ..where((user) => user.id).identifiedBy(targetUserId)
      ..where((user) => user.visits.where((visit) => visit.business.id == account.business.id).length).greaterThan(1);

    final user = await getUserQuery.fetchOne();

    if (user == null) {
      return Response.notFound();
    }

    final notificationsToken = user.notificationsToken;

    if (notificationsToken == null) {
      return Response.serverError(
          body: BusinessSendNotificationResponse(success: false, error: "User has not notifications token"));
    }

    final insertNotificationQuery = Query<Notification>(_context)
      ..values.type = NotificationType.simple
      ..values.title = title
      ..values.shortDescription = shortDescription
      ..values.description = description
      ..values.user = user
      ..values.business = account.business;

    await insertNotificationQuery.insert();

    final response = await http.post("https://fcm.googleapis.com/fcm/send",
        headers: {
          HttpHeaders.authorizationHeader: "key=$firebaseServerKey",
          HttpHeaders.contentTypeHeader: "application/json"
        },
        body: json.encode({
          "to": notificationsToken,
          "notification": {"body": shortDescription, "title": title}
        }));

    if (response.statusCode != 200) {
      return Response.serverError(
          body: BusinessSendNotificationResponse(success: false, error: "Call to firebase failed"));
    }

    return Response.ok(BusinessSendNotificationResponse(success: true, error: null));
  }
}
