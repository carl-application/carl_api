import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/image.dart';

class ImageAdminController extends ResourceController {
  ImageAdminController(this._context);

  final ManagedContext _context;

  @Operation.post()
  Future<Response> createImage(@Bind.body() Image image) async {
    return Response.ok(await _context.insertObject(image));
  }

  @Operation.delete("id")
  Future<Response> deleteImage(@Bind.path("id") int id) async {

    final deleteImageQuery = Query<Image>(_context)..where((image) => image.id).identifiedBy(id);

    final result = await deleteImageQuery.delete();

    if (result == 0) {
      return Response.notFound();
    }

    return Response.ok(result);
  }
}
