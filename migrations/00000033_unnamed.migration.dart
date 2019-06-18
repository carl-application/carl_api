import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration33 extends Migration { 
  @override
  Future upgrade() async {
   		database.createTable(SchemaTable("_Settings", [SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("premiumCost", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("nbFreeNotificationsPerMonth", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false)]));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    