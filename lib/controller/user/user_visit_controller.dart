import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/visit.dart';

class UserVisitController extends ResourceController {
  UserVisitController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> getVisitsOfOneBusiness(
    @Bind.query('businessId') int businessId,
    @Bind.query("lastFetchedDate") String date,
    @Bind.query("fetchLimit") int fetchLimit,
    @Bind.query("now") String nowDate,
  ) async {
    var lastFectchedDate = DateTime.tryParse(date);
    lastFectchedDate ??= DateTime.tryParse(nowDate);

    final getVisitsQuery = Query<Visit>(_context)
      ..where((visit) => visit.business.id).identifiedBy(businessId)
      ..where((visit) => visit.user.account.id).identifiedBy(request.authorization.ownerID)
      ..where((visit) => visit.date).lessThan(lastFectchedDate)
      ..sortBy((visit) => visit.date, QuerySortOrder.descending)
      ..returningProperties((visit) => [visit.id, visit.date, visit.type])
      ..fetchLimit = fetchLimit;

    final visits = await getVisitsQuery.fetch();
    return Response.ok(visits);
  }
}
