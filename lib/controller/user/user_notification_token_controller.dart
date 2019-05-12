import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/user.dart';

class UserNotificationTokenController extends ResourceController {
  UserNotificationTokenController(this._context);

  final ManagedContext _context;

  @Operation.put("token")
  Future<Response> updateNotificationToken(@Bind.path("token") String token) async {
    final getUserQuery = Query<User>(_context)
      ..where((user) => user.account.id).identifiedBy(request.authorization.ownerID);

    final user = await getUserQuery.fetchOne();

    if (user == null) {
      return Response.unauthorized();
    }

    final updateTokenQuery = Query<User>(_context)
      ..values.notificationsToken = token
      ..where((user) => user.id).identifiedBy(user.id);

    final updated = await updateTokenQuery.updateOne();

    if (updated == null) {
      return Response.serverError();
    } else {
      return Response.ok(updated);
    }
  }
}
