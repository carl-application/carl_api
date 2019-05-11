import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/business.dart';
import 'package:carl_api/model/image.dart';

class BusinessLogoController extends ResourceController {
  BusinessLogoController(this._context);

  final ManagedContext _context;

  @Operation.post()
  Future<Response> postImage(@Bind.body() Image image) async {
    final getBusinessQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final account = await getBusinessQuery.fetchOne();

    if (account == null || image.type != ImageType.logo) {
      return Response.badRequest();
    }

    final Image insertedImage = await _context.insertObject(image);

    final updateBusinessQuery = Query<Business>(_context)
      ..values.logo = insertedImage
      ..where((business) => business.id).equalTo(account.business.id);

    await updateBusinessQuery.update();

    return Response.ok(insertedImage);
  }
}
