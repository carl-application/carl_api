import 'package:carl_api/model/business.dart';
import 'package:carl_api/model/user.dart';

import '../carl_api.dart';

class Account extends ManagedObject<_Account> implements _Account, ManagedAuthResourceOwner<_Account> {
  @Serialize(input: true, output: false)
  String password;

  @override
  void willInsert() {
    registrationDate = DateTime.now().toUtc();
  }
}

/*
  Here are already handled properties (thanks to `ManagedAuthTOTO` type)
  @primaryKey
  int id;

  @Column(unique: true, indexed: true)
  String username;

  @Column(omitByDefault: true)
  String hashedPassword;

  @Column(omitByDefault: true)
  String salt;

  ManagedSet<ManagedAuthToken> tokens;
 */
class _Account extends ResourceOwnerTableDefinition {
  @Column(defaultValue: "false")
  bool isAdmin;

  @Column(omitByDefault: true)
  DateTime registrationDate;

  @Relate(#account)
  User user;

  @Relate(#account)
  Business business;
}
