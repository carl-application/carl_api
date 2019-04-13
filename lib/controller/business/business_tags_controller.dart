import 'dart:async';

import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/tag.dart';

class TagController extends ResourceController {
  TagController(this._context);

  final ManagedContext _context;

  @Operation.post()
  Future<Response> createTags(@Bind.body() List<Tag> tags) async {
    final getBusinessQuery = Query<Account>(_context)
      ..where((account) => account.id).equalTo(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final account = await getBusinessQuery.fetchOne();
    if (account.business == null) {
      return Response.notFound();
    }

    tags.forEach((tag) {
      tag.business = account.business;
    });

    final result = await Query.insertObjects(_context, tags);

    return Response.ok(result);
  }
}
