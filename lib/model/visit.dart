import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/business.dart';
import 'package:carl_api/model/user.dart';

enum VisitValidationType { nfc, scan }

class Visit extends ManagedObject<_Visit> implements _Visit {
  @override
  void willUpdate() {}

  @override
  void willInsert() {
    date = DateTime.now().toUtc();
  }
}

class _Visit {
  @primaryKey
  int id;

  @Column(indexed: true)
  DateTime date;

  @Relate(#visits)
  Business business;

  @Relate(#visits)
  User user;

  @Column(nullable: false, defaultValue: "'scan'")
  VisitValidationType type;
}
