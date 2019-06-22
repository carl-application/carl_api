import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/business.dart';

class FakeController extends ResourceController {
  FakeController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> fake() async {
    final query = Query<Business>(_context)
      ..where((business) => business.id).identifiedBy(13)
      ..values.planType = PlanType.premium;

    return Response.ok(await query.updateOne());
  }
}
