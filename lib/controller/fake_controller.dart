import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/business.dart';
import 'package:uuid/uuid.dart';

class FakeController extends ResourceController {
  FakeController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> fake(@Bind.query("id") int id) async {
    final a = Query<Business>(_context)..values.affiliationKey = Uuid().v4();

    await a.update();

    final query = Query<Business>(_context)
      ..where((business) => business.id).identifiedBy(id)
      ..values.planType = PlanType.premium;

    return Response.ok(await query.updateOne());

  }
}
