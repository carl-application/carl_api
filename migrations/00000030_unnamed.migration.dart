import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration30 extends Migration { 
  @override
  Future upgrade() async {
   		database.deleteColumn("_Business", "nbNotificationsSent");
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    