import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/business.dart';
import 'package:carl_api/model/image.dart';

class BusinessCardImageController extends ResourceController {
  BusinessCardImageController(this._context);

  final ManagedContext _context;

  @Operation.post("id")
  Future<Response> postImage(@Bind.path("id") int id) async {
    final getBusinessQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final account = await getBusinessQuery.fetchOne();

    if (account == null) {
      return Response.badRequest();
    }

    final getImageQuery = Query<Image>(_context)..where((image) => image.id).identifiedBy(id);

    final image = await getImageQuery.fetchOne();

    if (image == null) {
      return Response.notFound();
    }

    final updateBusinessQuery = Query<Business>(_context)
      ..values.image = image
      ..where((business) => business.id).equalTo(account.business.id);

    await updateBusinessQuery.update();
    return Response.ok(image);
  }
}
