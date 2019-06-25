import 'package:carl_api/model/account.dart';

import '../../carl_api.dart';
import '../../model/user.dart';

class UserController extends ResourceController {
  UserController(this._context, this._authServer);

  final ManagedContext _context;
  final AuthServer _authServer;

  @Operation.get("id")
  Future<Response> getUser(@Bind.path("id") int id) async {
    final accountQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(request.authorization.ownerID);
    final ownerAccount = await accountQuery.fetchOne();

    final query = Query<User>(_context)..where((user) => user.id).equalTo(id);

    // Check if the user is the owner of the account and, if then, send him his account
    if (ownerAccount.user != null && ownerAccount.user.id == id) {
      query.join(object: (user) => user.account).returningProperties((user) => [user.username, user.isAdmin]);
    }

    final user = await query.fetchOne();
    if (user == null) {
      return Response.notFound();
    }

    return Response.ok(user);
  }

  @Operation.put("id")
  Future<Response> updateUser(@Bind.path("id") int id, @Bind.body() User user) async {
    if (request.authorization.ownerID != id) {
      return Response.unauthorized();
    }

    final query = Query<User>(_context)
      ..values = user
      ..where((user) => user.id).equalTo(id);

    final updatedUser = await query.updateOne();
    if (updatedUser == null) {
      return Response.notFound();
    }

    return Response.ok(updatedUser);
  }

  @Operation.delete()
  Future<Response> deleteUser() async {
    final getUserQuery = Query<User>(_context)
      ..where((user) => user.account.id).identifiedBy(request.authorization.ownerID);

    final user = await getUserQuery.fetchOne();

    if (user == null) {
      return Response.unauthorized();
    }

    final accountQuery = Query<Account>(_context)
    ..where((account) => account.user.id).identifiedBy(user.id);

    return Response.ok(await accountQuery.delete());

  }
}
