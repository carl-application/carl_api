import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/business.dart';
import 'package:carl_api/model/campaign.dart';
import 'package:carl_api/model/customer_relationship.dart';
import 'package:carl_api/model/notification.dart';
import 'package:carl_api/model/notifications_black_list.dart';
import 'package:carl_api/model/tag.dart';
import 'package:carl_api/model/visit.dart';

class AdminGetBusinessesController extends ResourceController {
  AdminGetBusinessesController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> adminGetBusinesses() async {
    final getBusinessesQuery = Query<Business>(_context)
      ..returningProperties((business) => [
        business.name,
        business.planType,
        business.affiliationKey,
        business.temporaryKey
      ]);

    return Response.ok(await getBusinessesQuery.fetch());
  }

  @Operation.delete("id")
  Future<Response> deleteBusiness(@Bind.path("id") int businessId) async {
    final accountQuery = Query<Account>(_context)
      ..where((account) => account.business).isNotNull()
      ..where((account) => account.business.id).identifiedBy(businessId);

    final ownerAccount = await accountQuery.fetchOne();

    if (ownerAccount == null) {
      return Response.unauthorized();
    }

    final deleteRelationshipsQuery = Query<CustomerRelationship>(_context)
      ..where((relationship) => relationship.business.id).identifiedBy(ownerAccount.business.id);

    await deleteRelationshipsQuery.delete();

    final deleteVisitsQuery = Query<Visit>(_context)
      ..where((visit) => visit.business.id).identifiedBy(ownerAccount.business.id);

    await deleteVisitsQuery.delete();

    final deleteTagsQuery = Query<Tag>(_context)
      ..where((tag) => tag.business.id).identifiedBy(ownerAccount.business.id);

    await deleteTagsQuery.delete();

    final deleteBlackListsQuery = Query<NotificationsBlackListed>(_context)
      ..where((blacklist) => blacklist.business.id).identifiedBy(ownerAccount.business.id);

    await deleteBlackListsQuery.delete();

    final deleteNotificationsQuery = Query<Notification>(_context)
      ..where((notification) => notification.business.id).identifiedBy(ownerAccount.business.id);

    await deleteNotificationsQuery.delete();

    final deleteCampaignsQuery = Query<Campaign>(_context)
      ..where((campaign) => campaign.business.id).identifiedBy(ownerAccount.business.id);

    await deleteCampaignsQuery.delete();

    final deleteBusinessQuery = Query<Business>(_context)
      ..where((business) => business.id).identifiedBy(ownerAccount.business.id);

    await deleteBusinessQuery.delete();

    final deleteAccountQuery = Query<Account>(_context)..where((account) => account.id).identifiedBy(ownerAccount.id);

    return Response.ok(await deleteAccountQuery.delete());
  }
}
