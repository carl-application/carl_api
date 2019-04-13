import 'dart:async';

import 'package:aqueduct/aqueduct.dart';

class Migration2 extends Migration {
  @override
  Future upgrade() async {
    database.createTable(SchemaTable("_Image", [
      SchemaColumn("id", ManagedPropertyType.bigInteger,
          isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),
      SchemaColumn("url", ManagedPropertyType.string,
          isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false)
    ]));
    database.addColumn(
        "_Account",
        SchemaColumn("isAdmin", ManagedPropertyType.boolean,
            isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
    database.addColumn(
        "_Business",
        SchemaColumn("cardColor", ManagedPropertyType.string,
            isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
    database.addColumn(
        "_Business",
        SchemaColumn.relationship("image", ManagedPropertyType.bigInteger,
            relatedTableName: "_Image",
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
