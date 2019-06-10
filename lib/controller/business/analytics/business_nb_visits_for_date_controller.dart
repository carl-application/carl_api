import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/visit.dart';
import 'package:carl_api/response/business_count_for_date_response.dart';

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

    if (date == null) {
      return Response.notFound();
    }

    date = date.toUtc();

    final List<int> weekCounts = [];
    final List<int> correspondingDaysOfWeeks = [];

    for (var i = 0; i < 7; i++) {
      final DateTime d = date.subtract(Duration(days: i));
      correspondingDaysOfWeeks.add(d.weekday);
      final requestedDateVisitsCount = await _getVisitsCountForDate(d, account);
      weekCounts.add(requestedDateVisitsCount);
    }

    final requestedCount = weekCounts[0];
    final prevDayCount = weekCounts[1];

    final progress = prevDayCount != 0 ? ((requestedCount - prevDayCount) / prevDayCount * 100) : 0.0;

    return Response.ok(BusinessCountForDateResponse(
        count: requestedCount,
        weekCounts: weekCounts,
        correspondingDaysOfWeek: correspondingDaysOfWeeks,
        evolution: progress,
        hasEvolve: prevDayCount != 0 && prevDayCount != requestedCount));
  }

  Future<int> _getVisitsCountForDate(DateTime date, Account account) async {
    final morning = date.subtract(Duration(
        hours: date.hour,
        minutes: date.minute,
        seconds: date.second,
        milliseconds: date.millisecond,
        microseconds: date.microsecond));
    final tomorrow = date.subtract(Duration(
        days: -1,
        hours: date.hour,
        minutes: date.minute,
        seconds: date.second,
        milliseconds: date.millisecond,
        microseconds: date.microsecond));

    final getVisitsQuery = Query<Visit>(_context)
      ..where((visit) => visit.business.id).identifiedBy(account.business.id)
      ..where((visit) => visit.date).lessThan(tomorrow)
      ..where((visit) => visit.date).greaterThan(morning);

    return getVisitsQuery.reduce.count();
  }
}
