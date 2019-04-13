import 'dart:async';

import 'package:aqueduct/aqueduct.dart';

class Migration6 extends Migration {
  @override
  Future upgrade() async {
    database.alterColumn("_Account", "isAdmin", (c) {
      c.defaultValue = "false";
      c.isNullable = false;
    }, unencodedInitialValue: "'false'");
  }

  @override
  Future downgrade() async {}

  @override
  Future seed() async {}
}
