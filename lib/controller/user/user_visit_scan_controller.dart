import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/business.dart';
import 'package:carl_api/model/user.dart';
import 'package:carl_api/model/visit.dart';
import 'package:carl_api/response/valid_visit_response.dart';
import 'package:uuid/uuid.dart';

class UserVisitScanController extends ResourceController {
  UserVisitScanController(this._context);

  final ManagedContext _context;

  @Operation.post("businessKey")
  Future<Response> validVisitFromNScan(@Bind.path("businessKey") String businessKey) async {
    final findBusinessQuery = Query<Business>(_context)
      ..where((business) => business.temporaryKey).identifiedBy(businessKey);

    final findUserQuery = Query<User>(_context)
      ..where((user) => user.account.id).identifiedBy(request.authorization.ownerID);

    final user = await findUserQuery.fetchOne();

    if (user == null) {
      return Response.unauthorized();
    }

    final business = await findBusinessQuery.fetchOne();

    if (business == null) {
      return Response.notFound();
    }

    final createVisit = Query<Visit>(_context)
      ..values.business = business
      ..values.user = user
      ..values.type = VisitValidationType.scan;

//    final updateBusinessKey = Query<Business>(_context)
//      ..values.temporaryKey = Uuid().v4()
//      ..where((b) => b.id).identifiedBy(business.id);
//
//    await updateBusinessKey.update();

    final visit = await createVisit.insert();
    final getUserVisitsCount = Query<Visit>(_context)
      ..where((visit) => visit.business.id).identifiedBy(business.id)
      ..where((visit) => visit.user.id).identifiedBy(user.id);

    final userVisitsCount = await getUserVisitsCount.reduce.count();
    final businessVisitsMax = business.fidelityMax;
    final response = ValidVisitResponse(userVisitsCount, businessVisitsMax, visit);

    return Response.ok(response);
  }
}
