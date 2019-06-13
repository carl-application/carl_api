import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration31 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("_Business", SchemaColumn("nbScanPerDay", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, defaultValue: "1", isIndexed: false, isNullable: false, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    