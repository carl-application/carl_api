import 'package:carl_api/model/image.dart';
import 'package:carl_api/model/notification.dart';
import 'package:carl_api/model/tag.dart';
import 'package:carl_api/model/visit.dart';
import 'package:uuid/uuid.dart';

import './account.dart';
import '../carl_api.dart';

enum PlanType { basic, premium }

class Business extends ManagedObject<_Business> implements _Business {
  @override
  void willInsert() {
    nfcKey = Uuid().v4();
    temporaryKey = Uuid().v4();
  }
}

class _Business {
  @override
  bool operator ==(other) {
    return id == other.id;
  }

  @override
  int get hashCode => id;

  @primaryKey
  int id;

  @Column(nullable: false, omitByDefault: true)
  @Validate(onInsert: false, onUpdate: false)
  String nfcKey;

  @Column(nullable: false)
  @Validate(onInsert: false, onUpdate: false)
  String temporaryKey;

  @Column(nullable: false)
  String name;

  @Column(nullable: true)
  String description;

  @Column(nullable: false)
  String address;

  @Column(nullable: false)
  int fidelityMax;

  ManagedSet<Tag> tags;

  ManagedSet<Visit> visits;

  ManagedSet<Notification> notifications;

  ManagedSet<Business> entities;

  @Relate(#entities)
  Business parent;

  @Column(nullable: false, defaultValue: "'basic'")
  PlanType planType;

  // Card section
  @Column(nullable: true)
  String cardColor;

  @Relate(#businesses)
  Image image;

  @Relate(#businessesLogo)
  Image logo;

  Account account;
}
