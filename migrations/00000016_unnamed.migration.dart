import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration16 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("_Business", SchemaColumn.relationship("logo", ManagedPropertyType.bigInteger, relatedTableName: "_Image", relatedColumnName: "id", rule: DeleteRule.nullify, isNullable: true, isUnique: false));
		database.alterColumn("_User", "pseudo", (c) {c.defaultValue = null;});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    