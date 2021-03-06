import 'dart:async';

import 'package:aqueduct/aqueduct.dart';

class Migration5 extends Migration {
  @override
  Future upgrade() async {
    database.addColumn(
        "_Business",
        SchemaColumn("nfcKey", ManagedPropertyType.string,
            isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
        unencodedInitialValue: "'test'");
    database.addColumn(
        "_Business",
        SchemaColumn("temporaryKey", ManagedPropertyType.string,
            isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
        unencodedInitialValue: "'test'");
    database.deleteColumn("_Business", "guid");
  }

  @override
  Future downgrade() async {}

  @override
  Future seed() async {}
}
