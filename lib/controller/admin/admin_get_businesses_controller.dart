import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/business.dart';

class AdminGetBusinessesController extends ResourceController {
  AdminGetBusinessesController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> getBusinesses() async {
    final getBusinessesQuery = Query<Business>(_context)
      ..returningProperties((business) => [
        business.name,
        business.planType,
        business.affiliationKey,
        business.temporaryKey
      ]);

    return Response.ok(await getBusinessesQuery.fetch());
  }
}
