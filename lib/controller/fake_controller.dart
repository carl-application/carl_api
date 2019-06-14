import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/business.dart';
import 'package:carl_api/model/image.dart';
import 'package:carl_api/model/user.dart';
import 'package:carl_api/model/visit.dart';

class FakeController extends ResourceController {
  FakeController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> fake() async {

    final query = Query<Account>(_context)
        ..where((account)=> account.business).identifiedBy(11)
        ..values.isAdmin = true;

    return Response.ok(await query.updateOne());
  }
}
