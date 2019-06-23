import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/controller/utils.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/params/business_analytics_params.dart';
import 'package:carl_api/response/business_customers_by_sex_count_response.dart';

class BusinessSexParityController extends ResourceController {
  BusinessSexParityController(this._context);

  final ManagedContext _context;

  @Operation.post()
  Future<Response> getSexParity(@Bind.body() BusinessAnalyticsParams params) async {
    final getBusinessQuery = Query<Account>(_context)
      ..where((account) => account.id).equalTo(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final account = await getBusinessQuery.fetchOne();
    if (account == null) {
      return Response.unauthorized();
    }

    final queryWomen = _getQueryFor("woman", account.business.id, params);
    final queryMen = _getQueryFor("man", account.business.id, params);
    final queryNp = _getQueryFor("np", account.business.id, params);

    final getWomenCount = await _context.persistentStore.execute(queryWomen);
    final getMenCount = await _context.persistentStore.execute(queryMen);
    final getNpCount = await _context.persistentStore.execute(queryNp);

    final response = BusinessCustomersBySexCountResponse(
        women: getWomenCount[0][0] as int, men: getMenCount[0][0] as int, np: getNpCount[0][0] as int);
    return Response.ok(response);
  }

  String _getQueryFor(String sex, int businessId, BusinessAnalyticsParams params) {
    return """
    SELECT Count(_user.id)
    FROM _customerrelationship
    INNER JOIN _user
    ON _customerrelationship.user_id = _user.id
    AND _user.sex = '$sex'
    AND _customerrelationship.business_id IN ${Utils.getAnalyticsAffiliationBusinessSearchQuery(params.subEntities, businessId)};
    """;
  }
}
