import 'dart:math';

import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/customer_relationship.dart';

class FakeController extends ResourceController {
  FakeController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> fake() async {
    return Response.ok("not implemented");
    final usersIds = [8, 9, 10];
    const businessId = 5;

    for (var i = 0; i < usersIds.length; i++) {
      final randomMonth = Random().nextInt(6) + 1;
      final randomDay = Random().nextInt(30) + 1;
      final relationshipDate = DateTime(2019, randomMonth, randomDay);
      final previousRelationshipQuery = Query<CustomerRelationship>(_context)
        ..where((relationship) => relationship.business.id).equalTo(businessId)
        ..where((relationship) => relationship.user.id).equalTo(usersIds[i]);
      final previousRelationship = await previousRelationshipQuery.fetchOne();

      if (previousRelationship != null) {
        await _updateRelationshipDate(relationshipDate, businessId, usersIds[i]);
      } else {

      }
    }

    return Response.ok("ok");
  }

  _updateRelationshipDate(DateTime newDate, int businessId, int userId) async {
    final updateQuery = Query<CustomerRelationship>(_context)
      ..values.date = newDate
      ..where((relationship) => relationship.business.id).equalTo(businessId)
      ..where((relationship) => relationship.user.id).equalTo(userId);
    await updateQuery.updateOne();
  }
}
