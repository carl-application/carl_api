import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/business.dart';
import 'package:carl_api/model/notifications_black_list.dart';
import 'package:carl_api/model/user.dart';
import 'package:carl_api/response/toggle_notifications_blacklist_response.dart';

class UserNotificationsBlackListController extends ResourceController {
  UserNotificationsBlackListController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> getAllBlackListedBusinesses() async {
    final getUserQuery = Query<User>(_context)
      ..where((user) => user.account.id).identifiedBy(request.authorization.ownerID);

    final user = await getUserQuery.fetchOne();

    if (user == null) {
      return Response.unauthorized();
    }

    final getNotificationBlackListedQuery = Query<NotificationsBlackListed>(_context)
      ..where((notificationBlackListed) => notificationBlackListed.user.id).equalTo(user.id);

    return Response.ok(await getNotificationBlackListedQuery.fetch());
  }

  @Operation.post("businessId")
  Future<Response> toggleBlackListForBusinessId(@Bind.path("businessId") int businessId) async {
    final getUserQuery = Query<User>(_context)
      ..where((user) => user.account.id).identifiedBy(request.authorization.ownerID);

    final user = await getUserQuery.fetchOne();

    if (user == null) {
      return Response.unauthorized();
    }

    final getCurrentNotificationBlackListedQuery = Query<NotificationsBlackListed>(_context)
      ..where((notificationBlackListed) => notificationBlackListed.business.id).equalTo(businessId)
      ..where((notificationBlackListed) => notificationBlackListed.user.id).equalTo(user.id);

    final currentNotificationBlackListed = await getCurrentNotificationBlackListedQuery.fetchOne();

    ToggleNotificationsBlackListResponse toggleResponse;

    if (currentNotificationBlackListed != null) {
      await getCurrentNotificationBlackListedQuery.delete();
      toggleResponse = ToggleNotificationsBlackListResponse(false);
    } else {
      final getBusinessQuery = Query<Business>(_context)..where((business) => business.id).equalTo(businessId);
      final business = await getBusinessQuery.fetchOne();

      final insertionQuery = Query<NotificationsBlackListed>(_context)
        ..values.business = business
        ..values.user = user;

      await insertionQuery.insert();
      toggleResponse = ToggleNotificationsBlackListResponse(true);
    }

    return Response.ok(toggleResponse);
  }
}
