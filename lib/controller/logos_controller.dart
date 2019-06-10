import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/image.dart';

class LogosController extends ResourceController {
  LogosController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> getAllLogos() async {
    final getImageQuery = Query<Image>(_context)..where((image) => image.type).equalTo(ImageType.logo);

    return Response.ok(await getImageQuery.fetch());
  }
}
