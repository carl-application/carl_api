import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/campaign.dart';

class BusinessCampaignsController extends ResourceController {
  BusinessCampaignsController(this._context);

  final ManagedContext _context;

  @Operation.post()
  Future<Response> createCampaign(@Bind.body() Campaign campaign) async {
    final getBusinessQuery = Query<Account>(_context)
      ..where((account) => account.id).equalTo(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final account = await getBusinessQuery.fetchOne();
    if (account == null) {
      return Response.unauthorized();
    }

    campaign.business = account.business;

    final insertedCampaign = await Query.insertObject(_context, campaign);

    return Response.ok(insertedCampaign);
  }

  @Operation.get()
  Future<Response> getCampaigns() async {
    final getBusinessQuery = Query<Account>(_context)
      ..where((account) => account.id).equalTo(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final account = await getBusinessQuery.fetchOne();
    if (account == null) {
      return Response.unauthorized();
    }
    final getCampaignsQuery = Query<Campaign>(_context)
      ..where((campaign) => campaign.business.id).equalTo(account.business.id)
      ..sortBy((campaign) => campaign.date, QuerySortOrder.descending);
    final campaigns = await getCampaignsQuery.fetch();
    return Response.ok(campaigns);
  }
}
