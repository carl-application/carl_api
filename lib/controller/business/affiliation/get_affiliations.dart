import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/business.dart';

class GetAffiliationsController extends ResourceController {
  GetAffiliationsController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> getAffiliations() async {
    final accountQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull()
      ..where((account) => account.business.planType).equalTo(PlanType.premium)
      ..join(object: (account) => account.business);

    final ownerAccount = await accountQuery.fetchOne();

    if (ownerAccount == null) {
      return Response.unauthorized();
    }

    final getAffiliationsQuery = Query<Business>(_context)
      ..where((business) => business.parent.id).identifiedBy(ownerAccount.business.id)
      ..join(object: (business) => business.logo)
      ..join(object: (business) => business.image)
      ..returningProperties((business) => [business.name, business.address, business.image, business.logo]);

    return Response.ok(await getAffiliationsQuery.fetch());
  }
}
