import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/notification.dart';
import 'package:carl_api/model/user.dart';
import 'package:carl_api/response/user_unread_notifications_count_response.dart';

class UserUnreadNotificationsCountController extends ResourceController {
  UserUnreadNotificationsCountController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> getUnreadNotificationsCount() async {
    final getUserQuery = Query<User>(_context)
      ..where((user) => user.account.id).identifiedBy(request.authorization.ownerID);

    final user = await getUserQuery.fetchOne();

    if (user == null) {
      return Response.unauthorized();
    }

    final getUnreadNotificationsCountQuery = Query<Notification>(_context)
      ..where((notification) => notification.seen).equalTo(false)
      ..where((notification) => notification.user.id).equalTo(user.id);

    final notificationsCount = await getUnreadNotificationsCountQuery.reduce.count();
    return Response.ok(UserUnreadNotificationsCountResponse(unreadNotificationsCount: notificationsCount));
  }
}
