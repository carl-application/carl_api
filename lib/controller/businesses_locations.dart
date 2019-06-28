import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/business.dart';

class UserBusinessesLocations extends ResourceController {
  UserBusinessesLocations(this._context);

  ManagedContext _context;

  @Operation.get()
  Future<Response> getBusinessesLocations() async {
    final getAccountQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(request.authorization.ownerID);

    final account = await getAccountQuery.fetchOne();

    if (account == null) {
      return Response.unauthorized();
    }

    final getBusinessesLocations = Query<Business>(_context)
    ..where((business) => business.id).isNotNull()
    ..returningProperties((business) => [business.name, business.address, business.latitude, business.longitude])
    ..join(set: (business) => business.tags)
      .returningProperties((tag) => [tag.name])
    ..join(object: (business) => business.logo)
      .returningProperties((image) => [image.url]);

    return Response.ok(await getBusinessesLocations.fetch());
  }
}
