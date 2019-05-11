import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration17 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("_Image", SchemaColumn("type", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, defaultValue: "'image'", isIndexed: false, isNullable: false, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    