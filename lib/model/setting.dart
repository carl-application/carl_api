import '../carl_api.dart';

class Settings extends ManagedObject<_Settings> implements _Settings {}

class _Settings {
  @primaryKey
  int id;

  @Column()
  int premiumCost;

  @Column()
  int nbFreeNotificationsPerMonth;
}
