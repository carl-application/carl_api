import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/business.dart';
import 'package:carl_api/model/image.dart';
import 'package:carl_api/model/tag.dart';
import 'package:carl_api/params/business_update_param.dart';
import 'package:google_maps_webservice/places.dart';

class BusinessCurrentInformationsController extends ResourceController {
  BusinessCurrentInformationsController(this._context, this.geocodingAPiKey);

  final ManagedContext _context;
  String geocodingAPiKey;

  @Operation.get()
  Future<Response> getBusinessInformations() async {
    final accountQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final ownerAccount = await accountQuery.fetchOne();

    if (ownerAccount == null) {
      return Response.unauthorized();
    }

    final query = Query<Business>(_context)
      ..where((business) => business.id).equalTo(ownerAccount.business.id)
      ..join(object: (business) => business.image)
      ..join(object: (business) => business.logo)
      ..join(set: (business) => business.tags).returningProperties((tag) => [tag.name])
      ..join(object: (business) => business.account).returningProperties((account) => [account.isAdmin]);

    final business = await query.fetchOne();
    if (business == null) {
      return Response.notFound();
    }

    return Response.ok(business);
  }

  @Operation.put()
  Future<Response> updateBusinessInformations(
    @Bind.body() BusinessUpdateParam updateParams,
  ) async {
    final accountQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final ownerAccount = await accountQuery.fetchOne();

    if (ownerAccount == null) {
      return Response.unauthorized();
    }

    final getBusinessQuery = Query<Business>(_context)
      ..where((business) => business.id).identifiedBy(ownerAccount.business.id);

    final currentBusiness = await getBusinessQuery.fetchOne();

    var image = currentBusiness.image;

    if (updateParams.imageId != null) {
      final imageQuery = Query<Image>(_context)
        ..where((image) => image.id).identifiedBy(updateParams.imageId)
        ..where((image) => image.type).equalTo(ImageType.image);

      final imageTemp = await imageQuery.fetchOne();
      if (imageTemp != null) {
        image = imageTemp;
      }
    }

    var logo = currentBusiness.logo;

    if (updateParams.logoId != null) {
      final logoQuery = Query<Image>(_context)
        ..where((image) => image.id).identifiedBy(updateParams.logoId)
        ..where((image) => image.type).equalTo(ImageType.logo);

      final logoTemp = await logoQuery.fetchOne();
      if (logoTemp != null) {
        logo = logoTemp;
      }
    }

    if (updateParams.stringTags != null) {
      final removeOldTagsQuery = Query<Tag>(_context)..where((tag) => tag.business.id).identifiedBy(currentBusiness.id);

      await removeOldTagsQuery.delete();

      final List<Future<Tag>> tagQueries = [];
      updateParams.stringTags.forEach((stringTag) {
        final insertQuery = Query<Tag>(_context)
          ..values.name = stringTag
          ..values.business = ownerAccount.business;

        tagQueries.add(insertQuery.insert());
      });

      await Future.wait(tagQueries);
    }

    if (updateParams.address != null) {
      final places = GoogleMapsPlaces(apiKey: geocodingAPiKey);
      PlacesSearchResponse response = await places.searchByText(updateParams.address);
      final location = response.results.first.geometry.location;
      currentBusiness.latitude = location.lat;
      currentBusiness.longitude = location.lng;
    }

    final updateBusinessQuery = Query<Business>(_context)
      ..where((business) => business.id).equalTo(currentBusiness.id)
      ..values.name = updateParams.name ?? currentBusiness.name
      ..values.description = updateParams.description ?? currentBusiness.description
      ..values.address = updateParams.address ?? currentBusiness.address
      ..values.fidelityMax = updateParams.fidelityMax ?? currentBusiness.fidelityMax
      ..values.nbScanPerDay = updateParams.nbScanPerDay ?? currentBusiness.nbScanPerDay
      ..values.longitude = currentBusiness.longitude
      ..values.latitude = currentBusiness.latitude
      ..values.image = image
      ..values.logo = logo;

    await updateBusinessQuery.updateOne();

    final finallyUpdatedBusiness = Query<Business>(_context)
      ..where((business) => business.id).equalTo(ownerAccount.business.id)
      ..join(object: (business) => business.image)
      ..join(object: (business) => business.logo)
      ..join(set: (business) => business.tags).returningProperties((tag) => [tag.name])
      ..join(object: (business) => business.account).returningProperties((account) => [account.isAdmin]);

    return Response.ok(await finallyUpdatedBusiness.fetchOne());
  }
}
