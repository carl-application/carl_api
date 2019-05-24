import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/business.dart';
import 'package:carl_api/model/user.dart';

class UserBusinessSearchController extends ResourceController {
  UserBusinessSearchController(this._context);

  final ManagedContext _context;

  @Operation.get("query")
  Future<Response> getBusinesses(@Bind.path("query") String query) async {
    final getUserQuery = Query<User>(_context)
      ..where((user) => user.account.id).identifiedBy(request.authorization.ownerID);

    final user = await getUserQuery.fetchOne();

    if (user == null) {
      return Response.unauthorized();
    }

    final getBusinessesByNameQuery = Query<Business>(_context)
      ..where((business) => business.name).contains(query, caseSensitive: false)
      ..join(set: (business) => business.tags).returningProperties((tag) => [tag.name]);

    final businesses = await getBusinessesByNameQuery.fetch();

    return Response.ok(businesses);
  }
}
