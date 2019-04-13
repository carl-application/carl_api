import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/business.dart';

class Tag extends ManagedObject<_Tag> implements _Tag {
  @override
  void willUpdate() {}

  @override
  void willInsert() {}
}

class _Tag {
  @primaryKey
  int id;

  @Column(nullable: false)
  String name;

  @Relate(#tags)
  Business business;
}
