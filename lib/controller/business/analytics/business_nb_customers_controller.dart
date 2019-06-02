import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/customer_relationship.dart';
import 'package:carl_api/response/business_count_for_date_response.dart';

class BusinessNbCustomersController extends ResourceController {
  BusinessNbCustomersController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> getNbCustomers(@Bind.query("date") String dateSent) async {
    final getBusinessQuery = Query<Account>(_context)
      ..where((account) => account.id).equalTo(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final account = await getBusinessQuery.fetchOne();
    if (account == null) {
      return Response.unauthorized();
    }

    print("Date sent = $dateSent");
    var date = DateTime.tryParse(dateSent);

    if (date == null) {
      return Response.notFound();
    }

    final List<int> weekCounts = [];
    final List<int> correspondingDaysOfWeeks = [];

    for (var i = 0; i < 7; i++) {
      final DateTime d = date.subtract(Duration(days: i));
      correspondingDaysOfWeeks.add(d.weekday);
      final requestedDateCustomersCount = await _getCustomersCountForDate(d, account);
      weekCounts.add(requestedDateCustomersCount);
    }

    final requestedCount = weekCounts[0];
    final prevDayCount = weekCounts[1];

    final progress = prevDayCount != 0 ? ((requestedCount - prevDayCount) / prevDayCount * 100) : 0.0;

    return Response.ok(BusinessCountForDateResponse(
        count: requestedCount,
        weekCounts: weekCounts,
        correspondingDaysOfWeek: correspondingDaysOfWeeks,
        evolution: progress,
        hasEvolve: prevDayCount != 0));
  }

  Future<int> _getCustomersCountForDate(DateTime date, Account account) async {
    final tomorrowMorning = date.subtract(Duration(
        days: -1,
        hours: date.hour,
        minutes: date.minute,
        seconds: date.second,
        milliseconds: date.millisecond,
        microseconds: date.microsecond));

    final query = Query<CustomerRelationship>(_context)
      ..where((relationship) => relationship.business.id).equalTo(account.business.id)
      ..where((relationship) => relationship.date).lessThan(tomorrowMorning);

    return query.reduce.count();
  }
}
