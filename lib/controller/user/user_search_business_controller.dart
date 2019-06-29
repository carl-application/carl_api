import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/business.dart';
import 'package:carl_api/model/tag.dart';
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
      ..join(set: (business) => business.tags).returningProperties((tag) => [tag.name])
      ..join(object: (business) => business.logo);

    final businesses = await getBusinessesByNameQuery.fetch();

    final List<int> businessesIdsToAdd = [];
    final test = Query<Tag>(_context)
      ..where((tag) => tag.name).contains(query, caseSensitive: false);
    final allTags = await test.fetch();

    for (var tag in allTags) {
      if (businesses.isEmpty || businesses.where((b) => b.id == tag.business.id).isEmpty) {
        businessesIdsToAdd.add(tag.business.id);
      }
    }

    final List<Future<Business>> queries = [];
    for (var businessId in businessesIdsToAdd) {
      final query = Query<Business>(_context)
        ..where((business) => business.id).equalTo(businessId)
        ..join(set: (business) => business.tags).returningProperties((tag) => [tag.name])
        ..join(object: (business) => business.logo);
      queries.add(query.fetchOne());
    }

    final result = await Future.wait(queries);

    businesses.addAll(result);

    businesses.sort((first, second) => first.name.compareTo(second.name));

    return Response.ok(businesses);
  }
}
