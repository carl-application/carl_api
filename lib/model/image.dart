import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/business.dart';

enum ImageType { logo, image }

class Image extends ManagedObject<_Image> implements _Image {
  @override
  void willUpdate() {}

  @override
  void willInsert() {}
}

class _Image {
  @primaryKey
  int id;

  @Column(nullable: false)
  String url;

  @Column(nullable: false, defaultValue: "'image'")
  ImageType type;

  ManagedSet<Business> businesses;

  ManagedSet<Business> businessesLogo;
}
