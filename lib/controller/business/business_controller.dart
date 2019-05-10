import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/business.dart';

class BusinessController extends ResourceController {
  BusinessController(this._context);

  final ManagedContext _context;

  @Operation.get("id")
  Future<Response> getBusiness(@Bind.path("id") int id) async {
    final accountQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(request.authorization.ownerID);
    final ownerAccount = await accountQuery.fetchOne();

    final query = Query<Business>(_context)
      ..where((business) => business.id).equalTo(id)
      ..join(object: (business) => business.image).returningProperties((image) => [image.url])
      ..join(object: (business) => business.logo).returningProperties((logo) => [logo.url])
      ..join(set: (business) => business.tags).returningProperties((tag) => [tag.name]);

    // Check if the user is the owner of the account and, if then, send him his account
    if (ownerAccount.business != null && ownerAccount.business.id == id) {
      query
          .join(object: (business) => business.account)
          .returningProperties((account) => [account.username, account.isAdmin]);
    }

    final business = await query.fetchOne();
    if (business == null) {
      return Response.notFound();
    }

    return Response.ok(business);
  }
}
