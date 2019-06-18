import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';

class AdminMiddlewareController extends Controller {
  final ManagedContext _context;

  AdminMiddlewareController(this._context);

  @override
  Future<RequestOrResponse> handle(Request request) async {
    final Query<Account> adminAccountQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(request.authorization.ownerID)
      ..where((account) => account.isAdmin).equalTo(true);

    final account = await adminAccountQuery.fetchOne();

    if (account == null) {
      return Response.unauthorized();
    }

    return request;
  }
}
