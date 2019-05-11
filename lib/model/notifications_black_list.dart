import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/business.dart';
import 'package:carl_api/model/user.dart';

class NotificationsBlackListed extends ManagedObject<_NotificationsBlackList> implements _NotificationsBlackList {
  @override
  void willUpdate() {}

  @override
  void willInsert() {}
}

class _NotificationsBlackList {
  @primaryKey
  int id;

  @Relate(#notificationsBlackListedUsers)
  Business business;

  @Relate(#notificationsBlackListedBusinesses)
  User user;
}
