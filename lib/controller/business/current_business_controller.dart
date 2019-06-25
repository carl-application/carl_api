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

class CurrentBusinessController extends ResourceController {
  CurrentBusinessController(this._context, this._authServer);

  final ManagedContext _context;
  final AuthServer _authServer;

  @Operation.get()
  Future<Response> getCurrentBusinessInformations() async {
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
      ..join(object: (business) => business.account)
          .returningProperties((account) => [account.username, account.isAdmin]);

    final business = await query.fetchOne();

    return Response.ok(business);
  }

  @Operation.put()
  Future<Response> updatePassword(@Bind.query("newPassword") String newPassword) async {
    final accountQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final ownerAccount = await accountQuery.fetchOne();

    if (ownerAccount == null) {
      return Response.unauthorized();
    }

    final salt = AuthUtility.generateRandomSalt();

    final updateQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(ownerAccount.id)
      ..values.salt = salt
      ..values.hashedPassword = _authServer.hashPassword(newPassword, salt);

    return Response.ok(await updateQuery.updateOne());
  }

  @Operation.delete()
  Future<Response> deleteBusiness() async {
    final accountQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

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

    final deleteAccountQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(ownerAccount.id);

    return Response.ok(await deleteAccountQuery.delete());
  }
}
