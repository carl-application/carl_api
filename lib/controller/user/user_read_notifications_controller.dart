import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/notification.dart';
import 'package:carl_api/model/user.dart';

class UserReadNotificationsController extends ResourceController {
  UserReadNotificationsController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> getReadNotifications() async {
    final getUserQuery = Query<User>(_context)
      ..where((user) => user.account.id).identifiedBy(request.authorization.ownerID);

    final user = await getUserQuery.fetchOne();

    if (user == null) {
      return Response.unauthorized();
    }

    final getReadNotificationsCountQuery = Query<Notification>(_context)
      ..where((notification) => notification.seen).equalTo(true)
      ..where((notification) => notification.user.id).equalTo(user.id)
      ..join(object: (notification) => notification.business).returningProperties((business) => [business.name])
      ..sortBy((notification) => notification.date, QuerySortOrder.descending);

    final notifications = await getReadNotificationsCountQuery.fetch();
    return Response.ok(notifications);
  }

  @Operation.get("id")
  Future<Response> getNotificationDetail(@Bind.path("id") int id) async {
    final getUserQuery = Query<User>(_context)
      ..where((user) => user.account.id).identifiedBy(request.authorization.ownerID);

    final user = await getUserQuery.fetchOne();

    if (user == null) {
      return Response.unauthorized();
    }

    final updateQuery = Query<Notification>(_context)
      ..values.seen = true
      ..where((notification) => notification.user.id).equalTo(user.id)
      ..where((notification) => notification.id).equalTo(id);

    await updateQuery.updateOne();

    final getDetailNotificationQuery = Query<Notification>(_context)
      ..where((notification) => notification.id).equalTo(id)
      ..where((notification) => notification.user.id).equalTo(user.id)
      ..join(object: (notification) => notification.business).join(object: (business) => business.logo);

    final notification = await getDetailNotificationQuery.fetchOne();
    return Response.ok(notification);
  }
}
