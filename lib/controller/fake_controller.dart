import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/business.dart';
import 'package:uuid/uuid.dart';

class FakeController extends ResourceController {
  FakeController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> fake() async {
    final query = Query<Business>(_context)
      ..where((business) => business.affiliationKey).isNull()
      ..values.affiliationKey = Uuid().v4();

    return Response.ok(await query.update());
  }
}
