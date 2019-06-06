import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/response/business_customers_by_age_item_count_response.dart';

class BusinessAgeRepartitionController extends ResourceController {
  BusinessAgeRepartitionController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> getAgeRepartition() async {
    final getBusinessQuery = Query<Account>(_context)
      ..where((account) => account.id).equalTo(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final account = await getBusinessQuery.fetchOne();
    if (account == null) {
      return Response.unauthorized();
    }

    final List<BusinessCustomersByAgeItemCountResponse> results = [];

    final first = _getQueryFor(0, 18, account.business.id);
    final firstCount = await _context.persistentStore.execute(first);
    results.add(BusinessCustomersByAgeItemCountResponse(label: "0 - 18", value: firstCount[0][0] as int));

    final second = _getQueryFor(18, 25, account.business.id);
    final secondCount = await _context.persistentStore.execute(second);
    results.add(BusinessCustomersByAgeItemCountResponse(label: "19 - 25", value: secondCount[0][0] as int));

    final third = _getQueryFor(25, 30, account.business.id);
    final thirdCount = await _context.persistentStore.execute(third);
    results.add(BusinessCustomersByAgeItemCountResponse(label: "26 - 30", value: thirdCount[0][0] as int));

    final fourth = _getQueryFor(30, 40, account.business.id);
    final fourthCount = await _context.persistentStore.execute(fourth);
    results.add(BusinessCustomersByAgeItemCountResponse(label: "31 - 40", value: fourthCount[0][0] as int));

    final fifth = _getQueryFor(40, 50, account.business.id);
    final fifthCount = await _context.persistentStore.execute(fifth);
    results.add(BusinessCustomersByAgeItemCountResponse(label: "41 - 50", value: fifthCount[0][0] as int));

    final sixth = _getQueryFor(50, 60, account.business.id);
    final sixthCount = await _context.persistentStore.execute(sixth);
    results.add(BusinessCustomersByAgeItemCountResponse(label: "51 - 60", value: sixthCount[0][0] as int));

    final seventh = _getQueryFor(60, 100, account.business.id);
    final seventhCount = await _context.persistentStore.execute(seventh);
    results.add(BusinessCustomersByAgeItemCountResponse(label: "61 - +", value: seventhCount[0][0] as int));

    return Response.ok(results);
  }

  String _getQueryFor(int ageMin, int ageMax, int businessId) {
    return """
    SELECT Count(_user.id)
    FROM _user
    INNER JOIN _customerrelationship
    ON _customerrelationship.user_id = _user.id
    WHERE date_part('year',age(birthdate)) > $ageMin
    AND date_part('year',age(birthdate)) <= $ageMax
    AND _customerrelationship.business_id = ${businessId};
    """;
  }
}
