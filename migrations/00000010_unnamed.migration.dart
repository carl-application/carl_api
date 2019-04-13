import 'dart:async';

import 'package:aqueduct/aqueduct.dart';

class Migration10 extends Migration {
  @override
  Future upgrade() async {
    database.createTable(SchemaTable("_Notification", [
      SchemaColumn("id", ManagedPropertyType.bigInteger,
          isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),
      SchemaColumn("date", ManagedPropertyType.datetime,
          isPrimaryKey: false, autoincrement: false, isIndexed: true, isNullable: false, isUnique: false),
      SchemaColumn("type", ManagedPropertyType.string,
          isPrimaryKey: false,
          autoincrement: false,
          defaultValue: "'simple'",
          isIndexed: false,
          isNullable: false,
          isUnique: false),
      SchemaColumn("title", ManagedPropertyType.string,
          isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
      SchemaColumn("description", ManagedPropertyType.string,
          isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false)
    ]));
    database.addColumn(
        "_Notification",
        SchemaColumn.relationship("business", ManagedPropertyType.bigInteger,
            relatedTableName: "_Business",
            relatedColumnName: "id",
            rule: DeleteRule.nullify,
            isNullable: true,
            isUnique: false));
    database.addColumn(
        "_Notification",
        SchemaColumn.relationship("user", ManagedPropertyType.bigInteger,
            relatedTableName: "_User",
            relatedColumnName: "id",
            rule: DeleteRule.nullify,
            isNullable: true,
            isUnique: false));
  }

  @override
  Future downgrade() async {}

  @override
  Future seed() async {}
}
