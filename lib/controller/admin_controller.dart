import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';

class AdminController extends ResourceController {
  AdminController(this._context);

  final ManagedContext _context;

  @Operation.post("userId")
  Future<Response> makeUserAdmin(@Bind.path("userId") int userId) async {
    final adminAccountQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(request.authorization.ownerID)
      ..where((account) => account.isAdmin).equalTo(true);

    final account = await adminAccountQuery.fetchOne();

    // Only an Admin user can give admin permissions
    if (account == null) {
      return Response.unauthorized();
    }

    final updateAccountToAdminQuery = Query<Account>(_context)
      ..values.isAdmin = true
      ..where((account) => account.user.id).equalTo(userId);

    final updatedAccount = await updateAccountToAdminQuery.updateOne();
    if (updatedAccount == null) {
      return Response.notFound();
    }

    return Response.ok(updatedAccount);
  }
}
