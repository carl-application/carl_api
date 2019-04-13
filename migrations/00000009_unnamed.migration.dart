import 'dart:async';

import 'package:aqueduct/aqueduct.dart';

class Migration9 extends Migration {
  @override
  Future upgrade() async {
    database.alterColumn("_Visit", "date", (c) {
      c.isIndexed = true;
    });
  }

  @override
  Future downgrade() async {}

  @override
  Future seed() async {}
}
