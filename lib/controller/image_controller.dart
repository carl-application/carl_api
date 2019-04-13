import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/image.dart';

class ImageController extends ResourceController {
  ImageController(this._context);

  final ManagedContext _context;

  @Operation.post()
  Future<Response> createImage(@Bind.body() Image image) async {
    final adminAccountQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(request.authorization.ownerID)
      ..where((account) => account.isAdmin).equalTo(true);

    final account = await adminAccountQuery.fetchOne();

    // Only an Admin user can create images
    if (account == null) {
      return Response.unauthorized();
    }

    return Response.ok(await _context.insertObject(image));
  }

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
    final getImageQuery = Query<Image>(_context);

    return Response.ok(await getImageQuery.fetch());
  }

  @Operation.delete("id")
  Future<Response> deleteImage(@Bind.path("id") int id) async {
    final adminAccountQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(request.authorization.ownerID)
      ..where((account) => account.isAdmin).equalTo(true);

    final account = await adminAccountQuery.fetchOne();

    // Only an Admin user can delete images
    if (account == null) {
      return Response.unauthorized();
    }

    final deleteImageQuery = Query<Image>(_context)..where((image) => image.id).identifiedBy(id);

    final result = await deleteImageQuery.delete();

    if (result == 0) {
      return Response.notFound();
    }

    return Response.ok(result);
  }
}
