import 'dart:async';

import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/campaign.dart';

class BusinessSendNotificationToCampaignController extends ResourceController {
  BusinessSendNotificationToCampaignController(this._context, this.firebaseServerKey);

  final ManagedContext _context;
  final String firebaseServerKey;

  @Operation.post()
  Future<Response> sendNotificationToCampaign(
    @Bind.query('targetCampaignId') int targetCampaignId,
    @Bind.query("title") String title,
    @Bind.query("shortDescription") String shortDescription,
    @Bind.query("description") String description,
  ) async {
    final getBusinessQuery = Query<Account>(_context)
      ..where((account) => account.id).equalTo(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final account = await getBusinessQuery.fetchOne();

    if (account == null || account.business == null) {
      return Response.unauthorized();
    }

    final getCampaignQuery = Query<Campaign>(_context)
      ..where((campaign) => campaign.id).identifiedBy(targetCampaignId)
      ..where((campaign) => campaign.business.id).identifiedBy(account.business.id);

    final campaign = await getCampaignQuery.fetchOne();

    print("campaign found = ${campaign.name}");

    var querySql = """
    SELECT _user.notificationstoken
    FROM _user
    INNER JOIN _customerrelationship
    ON _customerrelationship.user_id = _user.id
    WHERE _customerrelationship.business_id = ${account.business.id}
    AND date_part('year',age(birthdate)) >= ${campaign.ageMin ?? 0}
    AND date_part('year',age(birthdate)) <= ${campaign.ageMax ?? 130}
    """;

    if (!campaign.men) {
      querySql += """
      AND _user.sex != 'man'
      """;
    }

    if (!campaign.women) {
      querySql += """
      AND _user.sex != 'woman'
      """;
    }

    if (!campaign.np) {
      querySql += """
      AND _user.sex != 'np'
      """;
    }

    if (campaign.visitedPeriodStart != null) {
      querySql += """
      AND 0 < (
      SELECT Count(_visit.id)
      FROM _visit
      WHERE _visit.user_id = _user.id
      AND _visit.business_id = ${account.business.id}
      AND _visit.date >= '${campaign.visitedPeriodStart.toIso8601String()}'::date
      )
      """;
    }

    if (campaign.visitedPeriodEnd != null) {
      querySql += """
      AND 0 < (
      SELECT Count(_visit.id)
      FROM _visit
      WHERE _visit.user_id = _user.id
      AND _visit.business_id = ${account.business.id}
      AND _visit.date <= '${campaign.visitedPeriodEnd.toIso8601String()}'::date
      )
      """;
    }

    querySql += ";";
    final List<String> tokens = [];
    final result = await _context.persistentStore.execute(querySql) as List<List<dynamic>>;

    result.forEach((internList) {
      tokens.add(internList[0] as String);
    });

    return Response.ok(tokens);
  }
}
