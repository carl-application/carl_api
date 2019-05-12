import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/business.dart';
import 'package:carl_api/model/user.dart';

enum NotificationType { simple }

class Notification extends ManagedObject<_Notification> implements _Notification {
  @override
  void willUpdate() {}

  @override
  void willInsert() {
    date = DateTime.now().toUtc();
  }
}

class _Notification {
  @primaryKey
  int id;

  @Column(indexed: true)
  DateTime date;

  @Column(nullable: false, defaultValue: "'simple'")
  NotificationType type;

  @Column(nullable: false)
  String title;

  @Column(nullable: false)
  String shortDescription;

  @Column(nullable: false)
  String description;

  @Column(defaultValue: "false")
  bool seen;

  @Relate(#notifications)
  Business business;

  @Relate(#notifications)
  User user;
}
