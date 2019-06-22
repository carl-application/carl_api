import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/business.dart';

class CurrentBusinessController extends ResourceController {
  CurrentBusinessController(this._context, this._authServer);

  final ManagedContext _context;
  final AuthServer _authServer;

  @Operation.get()
  Future<Response> getCurrentBusinessInformations() async {
    final accountQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final ownerAccount = await accountQuery.fetchOne();

    if (ownerAccount == null) {
      return Response.unauthorized();
    }

    final query = Query<Business>(_context)
      ..where((business) => business.id).equalTo(ownerAccount.business.id)
      ..join(object: (business) => business.image)
      ..join(object: (business) => business.logo)
      ..join(set: (business) => business.tags).returningProperties((tag) => [tag.name])
      ..join(object: (business) => business.account)
          .returningProperties((account) => [account.username, account.isAdmin]);

    final business = await query.fetchOne();

    return Response.ok(business);
  }

  @Operation.put()
  Future<Response> updatePassword(
    @Bind.query("newPassword") String newPassword,
  ) async {
    final accountQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final ownerAccount = await accountQuery.fetchOne();

    if (ownerAccount == null) {
      return Response.unauthorized();
    }

    final salt = AuthUtility.generateRandomSalt();

    final updateQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(ownerAccount.id)
      ..values.salt = salt
      ..values.hashedPassword = _authServer.hashPassword(newPassword, salt);

    return Response.ok(await updateQuery.updateOne());
  }
}
