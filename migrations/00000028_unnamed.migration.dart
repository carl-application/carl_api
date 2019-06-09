import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration28 extends Migration { 
  @override
  Future upgrade() async {
   		database.alterColumn("_Notification", "shortDescription", (c) {c.isNullable = true;});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    