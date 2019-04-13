import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';

class BusinessAudiencesController extends ResourceController {
  BusinessAudiencesController(this._context);

  final ManagedContext _context;

  @Operation.post()
  Future<Response> createAudience() async {
    return Response.ok("Not implemented");
  }
}
