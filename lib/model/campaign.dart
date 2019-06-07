import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/business.dart';
import 'package:carl_api/model/user.dart';

class Campaign extends ManagedObject<_Campaign> implements _Campaign {
  @override
  void willUpdate() {}

  @override
  void willInsert() {
    date = DateTime.now().toUtc();
  }
}

class _Campaign {
  @primaryKey
  int id;

  @Column()
  DateTime date;

  @Column(defaultValue: "'Default'")
  String name;

  @Column(defaultValue: "true")
  bool men;

  @Column(defaultValue: "true")
  bool women;

  @Column(defaultValue: "true")
  bool np;

  @Column(nullable: true)
  int ageMin;

  @Column(nullable: true)
  int ageMax;

  @Column(nullable: true)
  DateTime visitedPeriodStart;

  @Column(nullable: true)
  DateTime visitedPeriodEnd;

  @Relate(#campaigns)
  Business business;
}
