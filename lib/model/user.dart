import 'package:carl_api/model/notification.dart';
import 'package:carl_api/model/notifications_black_list.dart';
import 'package:carl_api/model/visit.dart';
import 'package:uuid/uuid.dart';

import './account.dart';
import '../carl_api.dart';

enum Sex { man, woman }

class User extends ManagedObject<_User> implements _User {
  @Serialize(input: false, output: true)
  int get age => DateTime.now().year - birthDate.year;

  @override
  void willInsert() {
    guid = Uuid().v4();
  }
}

class _User {
  @primaryKey
  int id;

  @Column(nullable: false)
  Sex sex;

  @Column(nullable: false)
  String pseudo;

  @Column(nullable: false)
  @Validate(onInsert: false, onUpdate: false)
  String guid;

  // birthDate must be an iso8601 string
  @Column(nullable: false)
  DateTime birthDate;

  ManagedSet<Visit> visits;

  ManagedSet<NotificationsBlackListed> notificationsBlackListedBusinesses;

  ManagedSet<Notification> notifications;

  Account account;
}
