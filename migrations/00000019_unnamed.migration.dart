import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration19 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("_User", SchemaColumn("notificationsToken", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    