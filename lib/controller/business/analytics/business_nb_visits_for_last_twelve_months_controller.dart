import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/visit.dart';
import 'package:carl_api/response/business_count_for_last_months_response.dart';

class BusinessNbVisitsForLastTwelveMonthsController extends ResourceController {
  BusinessNbVisitsForLastTwelveMonthsController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> getVisitsCount() async {
    final getBusinessQuery = Query<Account>(_context)
      ..where((account) => account.id).equalTo(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final account = await getBusinessQuery.fetchOne();
    if (account == null) {
      return Response.unauthorized();
    }

    final date = DateTime.now();

    final List<int> monthsCount = [];
    final List<int> correspondingMonths = [];

    for (var i = 0; i < 12; i++) {
      final d = DateTime(date.year, date.month - i, date.day);
      correspondingMonths.add(d.month);
      final requestedDateVisitsCount = await _getVisitsCountForDate(d, account);
      monthsCount.add(requestedDateVisitsCount);
    }

    final requestedCount = monthsCount[0];
    final prevDayCount = monthsCount[1];

    final progress = prevDayCount != 0 ? ((requestedCount - prevDayCount) / prevDayCount * 100) : 0.0;

    return Response.ok(BusinessCountForLastMonthsResponse(
        count: requestedCount,
        monthsCounts: monthsCount,
        correspondingMonths: correspondingMonths,
        evolution: progress,
        hasEvolve: prevDayCount != 0 && prevDayCount != requestedCount));
  }

  Future<int> _getVisitsCountForDate(DateTime date, Account account) async {
    final monthStart = DateTime(date.year, date.month);
    final monthEnd = DateTime(date.year, date.month + 1);

    final getVisitsQuery = Query<Visit>(_context)
      ..where((visit) => visit.business.id).identifiedBy(account.business.id)
      ..where((visit) => visit.date).lessThan(monthEnd)
      ..where((visit) => visit.date).greaterThan(monthStart);

    return getVisitsQuery.reduce.count();
  }
}
