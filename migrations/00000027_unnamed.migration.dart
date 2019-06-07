import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration27 extends Migration { 
  @override
  Future upgrade() async {
   		database.alterColumn("_Campaign", "men", (c) {c.defaultValue = "true";});
		database.alterColumn("_Campaign", "women", (c) {c.defaultValue = "true";});
		database.alterColumn("_Campaign", "np", (c) {c.defaultValue = "true";});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    