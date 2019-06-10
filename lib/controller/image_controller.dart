import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/image.dart';

class ImageController extends ResourceController {
  ImageController(this._context);

  final ManagedContext _context;

  @Operation.get("id")
  Future<Response> getImage(@Bind.path("id") int id) async {
    final getImageQuery = Query<Image>(_context)..where((image) => image.id).identifiedBy(id);

    final image = await getImageQuery.fetchOne();
    if (image == null) {
      return Response.notFound();
    }

    return Response.ok(image);
  }

  @Operation.get()
  Future<Response> getImages() async {
    final getImageQuery = Query<Image>(_context)..where((image) => image.type).equalTo(ImageType.image);

    return Response.ok(await getImageQuery.fetch());
  }
}
