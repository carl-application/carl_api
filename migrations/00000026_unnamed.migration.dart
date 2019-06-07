import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration26 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("_Campaign", SchemaColumn("name", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, defaultValue: "'Default'", isIndexed: false, isNullable: false, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    