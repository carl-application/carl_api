import 'dart:async';

import 'package:aqueduct/aqueduct.dart';

class Migration7 extends Migration {
  @override
  Future upgrade() async {
    database.addColumn(
        "_Visit",
        SchemaColumn("type", ManagedPropertyType.string,
            isPrimaryKey: false,
            autoincrement: false,
            defaultValue: "'temporary'",
            isIndexed: false,
            isNullable: false,
            isUnique: false));
  }

  @override
  Future downgrade() async {}

  @override
  Future seed() async {}
}
