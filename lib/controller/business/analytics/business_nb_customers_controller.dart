import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/params/business_analytics_params.dart';
import 'package:carl_api/response/business_count_for_date_response.dart';
import 'package:carl_api/utils.dart';

class BusinessNbCustomersController extends ResourceController {
  BusinessNbCustomersController(this._context);

  final ManagedContext _context;

  @Operation.post()
  Future<Response> getNbCustomers(@Bind.body() BusinessAnalyticsParams params) async {
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

    final List<int> weekCounts = [];
    final List<int> correspondingDaysOfWeeks = [];

    for (var i = 0; i < 7; i++) {
      final DateTime d = date.subtract(Duration(days: i));
      correspondingDaysOfWeeks.add(d.weekday);
      final requestedDateCustomersCount = await _getCustomersCountForDate(d, account, params);
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
        hasEvolve: prevDayCount != 0 && prevDayCount != requestedCount));
  }

  Future<int> _getCustomersCountForDate(DateTime date, Account account, BusinessAnalyticsParams params) async {
    final tomorrowMorning = date.subtract(Duration(
        days: -1,
        hours: date.hour,
        minutes: date.minute,
        seconds: date.second,
        milliseconds: date.millisecond,
        microseconds: date.microsecond));

    final querySql = """
      SELECT Count(_customerrelationship.id)
      FROM _customerrelationship
      WHERE _customerrelationship.business_id IN ${Utils.getAnalyticsAffiliationBusinessSearchQuery(params.subEntities, account.business.id, showCurrentWhenSubEntities: params.showCurrentWhenSubEntities)}
      AND _customerrelationship.date <= '${tomorrowMorning.toIso8601String()}'::date;
      """;

    final result = await _context.persistentStore.execute(querySql);
    final total = result[0][0] as int;

    return total;
  }
}
