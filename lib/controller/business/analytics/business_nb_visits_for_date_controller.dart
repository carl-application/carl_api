import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/visit.dart';
import 'package:carl_api/response/business_visits_count_response.dart';

class BusinessNbVisitsForDateController extends ResourceController {
  BusinessNbVisitsForDateController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> getVisitsForDate(@Bind.query("date") String dateSent) async {
    final getBusinessQuery = Query<Account>(_context)
      ..where((account) => account.id).equalTo(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final account = await getBusinessQuery.fetchOne();
    if (account == null) {
      return Response.unauthorized();
    }

    var date = DateTime.tryParse(dateSent);
    date ??= DateTime.now().toUtc();

    print("date = ${date}");

    final thisMorning = date.subtract(Duration(hours: date.hour, minutes: date.minute, seconds: date.second, milliseconds: date.millisecond, microseconds: date.microsecond));
    final tomorrow = date.subtract(Duration(days: -1, hours: date.hour, minutes: date.minute, seconds: date.second, milliseconds: date.millisecond, microseconds: date.microsecond));

    print("thisMorning = $thisMorning}");
    print("tomorrow = $tomorrow}");

    final getVisitsQuery = Query<Visit>(_context)
      ..where((visit) => visit.business.id).identifiedBy(account.business.id)
      ..where((visit) => visit.date).lessThan(tomorrow)
      ..where((visit) => visit.date).greaterThan(thisMorning);

    final visitsCount = await getVisitsQuery.reduce.count();

    return Response.ok(BusinessVisitsCountResponse(visitsCount));
  }
}
