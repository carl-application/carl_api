import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/business.dart';
import 'package:carl_api/model/customer_relationship.dart';
import 'package:carl_api/model/user.dart';
import 'package:carl_api/model/visit.dart';
import 'package:carl_api/response/valid_visit_response.dart';

class UserVisitScanController extends ResourceController {
  UserVisitScanController(this._context);

  final ManagedContext _context;

  @Operation.post("businessKey")
  Future<Response> validVisitFromNScan(
    @Bind.query("businessKey") String businessKey,
    @Bind.query("date") String dateSent
  ) async {
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

    var date = DateTime.tryParse(dateSent);

    if (date == null) {
      return Response.notFound();
    }

    final thisMorning = DateTime(date.year, date.month, date.day);

    final getTodayScansQuery = Query<Visit>(_context)
      ..where((visit) => visit.date).greaterThan(thisMorning)
      ..where((visit) => visit.user.id).identifiedBy(user.id)
      ..where((visit) => visit.business.id).identifiedBy(business.id);

    final todayScansCount = await getTodayScansQuery.reduce.count();

    if (todayScansCount >= business.nbScanPerDay) {
      return Response.forbidden();
    }

    final createVisit = Query<Visit>(_context)
      ..values.business = business
      ..values.user = user
      ..values.date = date
      ..values.type = VisitValidationType.scan;

    final visit = await createVisit.insert();

    final alreadyExistCustomerRelationshipQuery = Query<CustomerRelationship>(_context)
      ..where((relationship) => relationship.business.id).equalTo(business.id)
      ..where((relationship) => relationship.user.id).equalTo(user.id);

    final relationship = await alreadyExistCustomerRelationshipQuery.fetchOne();

    if (relationship == null) {
      final createRelationshipQuery = Query<CustomerRelationship>(_context)
        ..values.business = business
        ..values.user = user;

      await createRelationshipQuery.insert();
    }

    final getUserVisitsCount = Query<Visit>(_context)
      ..where((visit) => visit.business.id).identifiedBy(business.id)
      ..where((visit) => visit.user.id).identifiedBy(user.id);

    final userVisitsCount = await getUserVisitsCount.reduce.count();
    final businessVisitsMax = business.fidelityMax;
    final response = ValidVisitResponse(userVisitsCount, businessVisitsMax, visit);

    return Response.ok(response);
  }
}
