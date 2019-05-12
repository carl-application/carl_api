import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/business.dart';
import 'package:carl_api/model/user.dart';

class UserCardsController extends ResourceController {
  UserCardsController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> getCards() async {
    final getUserQuery = Query<User>(_context)
      ..where((user) => user.account.id).identifiedBy(request.authorization.ownerID);

    final user = await getUserQuery.fetchOne();

    if (user == null) {
      return Response.unauthorized();
    }

    final a = Query<Business>(_context)
      ..where((business) => business.visits.where((visit) => visit.user.id == user.id).length).greaterThan(1);

    a.join(object: (business) => business.image).returningProperties((image) => [image.url]);
    a.join(object: (business) => business.logo);
    //a.join(set: (business) => business.tags).returningProperties((tag) => [tag.name]);

    return Response.ok(await a.fetch());
  }
}
