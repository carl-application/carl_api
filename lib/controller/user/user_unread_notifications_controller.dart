import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/notification.dart';
import 'package:carl_api/model/user.dart';

class UserUnreadNotificationsController extends ResourceController {
  UserUnreadNotificationsController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> getUnreadNotifications() async {
    final getUserQuery = Query<User>(_context)
      ..where((user) => user.account.id).identifiedBy(request.authorization.ownerID);

    final user = await getUserQuery.fetchOne();

    if (user == null) {
      return Response.unauthorized();
    }

    final getUnreadNotificationsCountQuery = Query<Notification>(_context)
      ..where((notification) => notification.seen).equalTo(false)
      ..where((notification) => notification.user.id).equalTo(user.id)
      ..join(object: (notification) => notification.business).returningProperties((business) => [business.name])
      ..sortBy((notification) => notification.date, QuerySortOrder.descending);

    final notifications = await getUnreadNotificationsCountQuery.fetch();
    return Response.ok(notifications);
  }
}
