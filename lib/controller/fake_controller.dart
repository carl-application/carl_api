import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/business.dart';

class FakeController extends ResourceController {
  FakeController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> fake() async {
    /*
    final deleteBusinessesQuery =  Query<Business>(_context)..where((business) => business.id).isNotNull();
    await deleteBusinessesQuery.delete();

    final Query deleteVisitsQuery =  Query<Visit>(_context)..where((visit) => visit.id).isNotNull();
    await deleteVisitsQuery.delete();

    final deleteAllBusinessesAccountQuery = Query<Account>(_context)..where((account) => account.user).isNull();
    await deleteAllBusinessesAccountQuery.delete();

    final removeCampaignQuery = Query<Campaign>(_context)..where((campaign) => campaign.id).isNotNull();
    await removeCampaignQuery.delete();

    final removeRelationshipsQuery =  Query<CustomerRelationship>(_context)..where((r) => r.id).isNotNull();
    await removeRelationshipsQuery.delete();


    final notificationQuery = Query<Notification>(_context)..where((notif) => notif.id).isNotNull();
    await notificationQuery.delete();

     final nQuery = Query<NotificationsBlackListed>(_context)..where((n) => n.id).isNotNull();
     await nQuery.delete();

    final tagsQuery =  Query<Tag>(_context)..where((tag) => tag.id).isNotNull();
    await tagsQuery.delete();

    return Response.ok("ok");
    */

    final adminQuery = Query<Account>(_context)
      ..where((account) => account.business).isNotNull()
      ..where((account) => account.business.id).equalTo(50)
      ..values.isAdmin = true;

    await adminQuery.updateOne();
    
    final premiumQuery = Query<Business>(_context)
    ..where((business) => business.id).identifiedBy(54)
    ..values.planType = PlanType.premium;

    await premiumQuery.updateOne();

    return Response.ok("ok");
  }
}
