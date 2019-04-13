import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/business.dart';
import 'package:carl_api/model/user.dart';
import 'package:carl_api/model/visit.dart';
import 'package:carl_api/response/user_visits_info_response.dart';

class UserVisitMetaInfoController extends ResourceController {
  UserVisitMetaInfoController(this._context);

  final ManagedContext _context;

  @Operation.get("businessId")
  Future<Response> getMetasInfo(@Bind.path("businessId") int businessId) async {
    final getBusinessQuery = Query<Business>(_context)..where((business) => business.id).identifiedBy(businessId);

    final business = await getBusinessQuery.fetchOne();

    if (business == null) {
      return Response.notFound();
    }

    final getUserQuery = Query<User>(_context)
      ..where((user) => user.account.id).identifiedBy(request.authorization.ownerID);

    final user = await getUserQuery.fetchOne();

    if (user == null) {
      return Response.unauthorized();
    }

    final getUserVisitsCount = Query<Visit>(_context)
      ..where((visit) => visit.business.id).identifiedBy(business.id)
      ..where((visit) => visit.user.id).identifiedBy(user.id);

    final userVisitsCount = await getUserVisitsCount.reduce.count();
    final businessVisitsMax = business.fidelityMax;
    final response = UserVisitInfoResponse(userVisitsCount, businessVisitsMax);
    return Response.ok(response);
  }
}
