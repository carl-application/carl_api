import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/controller/utils.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/params/business_analytics_params.dart';
import 'package:carl_api/response/business_count_for_date_response.dart';

class BusinessNbVisitsForDateController extends ResourceController {
  BusinessNbVisitsForDateController(this._context);

  final ManagedContext _context;

  @Operation.post()
  Future<Response> getVisitsForDate(@Bind.body() BusinessAnalyticsParams params) async {
    final getBusinessQuery = Query<Account>(_context)
      ..where((account) => account.id).equalTo(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final account = await getBusinessQuery.fetchOne();
    if (account == null) {
      return Response.unauthorized();
    }

    var date = params.dateSent;

    if (date == null) {
      return Response.notFound();
    }

    date = date.toUtc();

    final List<int> weekCounts = [];
    final List<int> correspondingDaysOfWeeks = [];

    for (var i = 0; i < 7; i++) {
      final DateTime d = date.subtract(Duration(days: i));
      correspondingDaysOfWeeks.add(d.weekday);
      final requestedDateVisitsCount = await _getVisitsCountForDate(d, account, params);
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

  Future<int> _getVisitsCountForDate(DateTime date, Account account, BusinessAnalyticsParams params) async {
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

    final querySql = """
      SELECT Count(_visit.id)
      FROM _visit
      WHERE _visit.business_id IN ${Utils.getAnalyticsAffiliationBusinessSearchQuery(params.subEntities, account.business.id)}
      AND _visit.date >= '${morning.toIso8601String()}'::date
      AND _visit.date <= '${tomorrow.toIso8601String()}'::date;
      """;

    final result = await _context.persistentStore.execute(querySql);
    final total = result[0][0] as int;

    return total;
  }
}
