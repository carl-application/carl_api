import 'dart:async';

import 'package:aqueduct/aqueduct.dart';

class Migration8 extends Migration {
  @override
  Future upgrade() async {
    database.alterColumn("_Visit", "type", (c) {
      c.defaultValue = "'scan'";
    });
  }

  @override
  Future downgrade() async {}

  @override
  Future seed() async {}
}
