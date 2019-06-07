import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration25 extends Migration { 
  @override
  Future upgrade() async {
   		database.createTable(SchemaTable("_Campaign", [SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("date", ManagedPropertyType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("men", ManagedPropertyType.boolean, isPrimaryKey: false, autoincrement: false, defaultValue: "false", isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("women", ManagedPropertyType.boolean, isPrimaryKey: false, autoincrement: false, defaultValue: "false", isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("np", ManagedPropertyType.boolean, isPrimaryKey: false, autoincrement: false, defaultValue: "false", isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("ageMin", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false),SchemaColumn("ageMax", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false),SchemaColumn("visitedPeriodStart", ManagedPropertyType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false),SchemaColumn("visitedPeriodEnd", ManagedPropertyType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false)]));
		database.addColumn("_Campaign", SchemaColumn.relationship("business", ManagedPropertyType.bigInteger, relatedTableName: "_Business", relatedColumnName: "id", rule: DeleteRule.nullify, isNullable: true, isUnique: false));
		database.alterColumn("_CustomerRelationship", "date", (c) {c.defaultValue = null;});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    