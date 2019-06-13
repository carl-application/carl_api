import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/business.dart';
import 'package:carl_api/model/image.dart';
import 'package:carl_api/model/user.dart';
import 'package:carl_api/model/visit.dart';

class FakeController extends ResourceController {
  FakeController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> fake() async {

    final business = await Query<Business>(_context).fetchOne();
    final user = await Query<User>(_context).fetchOne();

    // final d = _createVisit(DateTime(year), business, user)
    return Response.ok("ok");
  }
  
  _createVisit(DateTime date, Business business, User user) async {
    final query = Query<Visit>(_context)
      ..values.type = VisitValidationType.scan
      ..values.business = business
      ..values.user = user;

    final visit = await query.insert();
    final q = Query<Visit>(_context)
      ..where((visit) => visit.id).identifiedBy(visit.id)
      ..values.date = DateTime(2018, 3, 5);
    
    return await q.updateOne();
  }
}
