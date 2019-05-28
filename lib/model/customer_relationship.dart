import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/business.dart';
import 'package:carl_api/model/user.dart';

class CustomerRelationship extends ManagedObject<_CustomerRelationship> implements _CustomerRelationship {
  @override
  void willUpdate() {}

  @override
  void willInsert() {
  }
}

class _CustomerRelationship {
  @primaryKey
  int id;

  @Relate(#customerRelationship)
  Business business;

  @Relate(#customerRelationship)
  User user;
}
