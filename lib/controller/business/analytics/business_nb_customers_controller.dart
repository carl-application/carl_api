import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/response/business_customers_count_response.dart';

class BusinessNbCustomersController extends ResourceController {
  BusinessNbCustomersController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> getNbCustomers() async {
    final getBusinessQuery = Query<Account>(_context)
      ..where((account) => account.id).equalTo(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final account = await getBusinessQuery.fetchOne();
    if (account == null) {
      return Response.unauthorized();
    }

    final query = """
    SELECT Count(_customerrelationship.user_id)
    FROM _customerrelationship
    WHERE _customerrelationship.business_id = ${account.business.id};
    """;

    final count = await _context.persistentStore.execute(query);

    return Response.ok(BusinessCustomersCountResponse(customersCount: count[0][0] as int));
  }
}
