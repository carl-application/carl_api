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

class FakeController extends ResourceController {
  FakeController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> fake() async {

    final deleteBusinessesQuery =  Query<Business>(_context)..where((business) => business.id).isNotNull();
    await deleteBusinessesQuery.delete();

    final Query deleteVisitsQuery =  Query<Visit>(_context)..where((visit) => visit.id).isNotNull();
    await deleteVisitsQuery.delete();

    final deleteAllBusinessesAccountQuery = Query<Account>(_context)..where((account) => account.user).isNull();
    await deleteAllBusinessesAccountQuery.delete();

    final removeCampaignQuery = Query<Campaign>(_context)..where((campaign) => campaign.id).isNotNull();
    await removeCampaignQuery.delete();

    final removeRelationshipsQuery = await Query<CustomerRelationship>(_context)..where((r) => r.id).isNotNull();
    await removeRelationshipsQuery.delete();


    final notificationQuery = Query<Notification>(_context)..where((notif) => notif.id).isNotNull();
    await notificationQuery.delete();

     final nQuery = Query<NotificationsBlackListed>(_context)..where((n) => n.id).isNotNull();
     await nQuery.delete();

    final tagsQuery =  Query<Tag>(_context)..where((tag) => tag.id).isNotNull();
    await tagsQuery.delete();

    return Response.ok("ok");
  }
}
