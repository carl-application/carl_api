import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/business.dart';
import 'package:uuid/uuid.dart';

class FakeController extends ResourceController {
  FakeController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> fake() async {
    final a = Query<Business>(_context)
      ..values.affiliationKey = Uuid().v4()
      ..where((business) => business.affiliationKey).isNull();

    return Response.ok(await a.update());
  }
}
