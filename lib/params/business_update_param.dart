import 'package:carl_api/carl_api.dart';

class BusinessUpdateParam implements Serializable {
  BusinessUpdateParam(
      {this.name,
      this.description,
      this.address,
      this.fidelityMax,
      this.nbScanPerDay,
      this.stringTags,
      this.imageId,
      this.logoId});

  String name;
  String description;
  String address;
  int fidelityMax;
  int nbScanPerDay;
  List<String> stringTags;
  int imageId;
  int logoId;

  @override
  Map<String, dynamic> asMap() {
    final map = {
      "name": name,
      "description": description,
      "address": address,
      "fidelityMax": fidelityMax,
      "nbScanPerDay": nbScanPerDay,
      "stringTags": stringTags?.toList() ?? [],
      "imageId": imageId,
      "logoId": logoId,
    };

    return map;
  }

  @override
  APISchemaObject documentSchema(APIDocumentContext context) {
    // TODO: implement documentSchema
    return null;
  }

  @override
  void read(Map<String, dynamic> object, {Iterable<String> ignore, Iterable<String> reject, Iterable<String> require}) {
    _fromMap(object);
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    _fromMap(object);
  }

  void _fromMap(Map<String, dynamic> map) {
    name = map["name"] as String;
    description = map["description"] as String;
    address = map["address"] as String;
    fidelityMax = map["fidelityMax"] as int;
    nbScanPerDay = map["nbScanPerDay"] as int;
    imageId = map["imageId"] as int;
    logoId = map["logoId"] as int;
    stringTags = (map["stringTags"] as List<dynamic>)?.map((dynamicTag) => dynamicTag as String)?.toList();
    // "tags": tags,
  }
}
