import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/business.dart';

class AdminMakePremiumController extends ResourceController {
  AdminMakePremiumController(this._context);

  final ManagedContext _context;

  @Operation.post("id")
  Future<Response> makeAdmin(@Bind.path("id") int businessId) async {
    final query = Query<Business>(_context)
      ..where((business) => business.id).identifiedBy(businessId)
      ..values.planType = PlanType.premium;

    return Response.ok(await query.updateOne());
  }
}
