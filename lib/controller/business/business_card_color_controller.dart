import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/business.dart';

class BusinessCardColorController extends ResourceController {
  BusinessCardColorController(this._context);

  final ManagedContext _context;

  @Operation.post("color")
  Future<Response> postColor(@Bind.path("color") String color) async {
    final getBusinessQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final account = await getBusinessQuery.fetchOne();

    if (account == null) {
      return Response.badRequest();
    }

    final updateBusinessQuery = Query<Business>(_context)
      ..values.cardColor = color
      ..where((business) => business.id).equalTo(account.business.id);

    final results = await updateBusinessQuery.update();
    return Response.ok(results[0]);
  }
}
