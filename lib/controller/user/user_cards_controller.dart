import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
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

    final usersQuery = Query<User>(_context)
      ..where((user) => user.id).equalTo(user.id)
      ..join(set: (user) => user.visits).join(object: (visit) => visit.business);

    final users = await usersQuery.fetch();

    final businesses = users.expand((u) => u.visits.map((v) => v.business));

    return Response.ok(businesses.toSet().toList());
  }
}
