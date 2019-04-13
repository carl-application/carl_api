import 'dart:async';

import 'package:aqueduct/aqueduct.dart';

class Migration14 extends Migration {
  @override
  Future upgrade() async {
    database.addColumn(
        "_Business",
        SchemaColumn("planType", ManagedPropertyType.string,
            isPrimaryKey: false,
            autoincrement: false,
            defaultValue: "'basic'",
            isIndexed: false,
            isNullable: false,
            isUnique: false));
  }

  @override
  Future downgrade() async {}

  @override
  Future seed() async {}
}
