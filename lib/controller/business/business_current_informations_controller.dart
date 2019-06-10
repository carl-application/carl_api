import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/business.dart';

class BusinessCurrentInformationsController extends ResourceController {
  BusinessCurrentInformationsController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> getBusinessInformations() async {
    final accountQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final ownerAccount = await accountQuery.fetchOne();

    if (ownerAccount == null) {
      return Response.notFound();
    }

    final query = Query<Business>(_context)
      ..where((business) => business.id).equalTo(ownerAccount.business.id)
      ..join(object: (business) => business.image)
      ..join(object: (business) => business.logo)
      ..join(set: (business) => business.tags).returningProperties((tag) => [tag.name])
      ..join(object: (business) => business.account).returningProperties((account) => [account.isAdmin]);

    final business = await query.fetchOne();
    if (business == null) {
      return Response.notFound();
    }

    return Response.ok(business);
  }
}
