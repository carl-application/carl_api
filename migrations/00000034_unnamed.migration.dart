import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration34 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("_Business", SchemaColumn("affiliationKey", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    