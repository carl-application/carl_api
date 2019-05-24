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

    print("User = ${user.toString()}, ${user.id}");

    final test = Query<User>(_context)
      ..where((user) => user.id).equalTo(user.id)
      ..join(set: (user) => user.visits).join(object: (visit) => visit.business);

    final tmp = await test.fetch();

    final businesses = tmp.expand((u) => u.visits.map((v) => v.business));

    return Response.ok(businesses.toSet().toList());
  }
}
