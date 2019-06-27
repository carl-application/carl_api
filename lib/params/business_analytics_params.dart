import 'package:carl_api/carl_api.dart';

class BusinessAnalyticsParams implements Serializable {
  BusinessAnalyticsParams({this.dateSent, this.subEntities, this.showCurrentWhenSubEntities});

  DateTime dateSent;
  List<int> subEntities;
  bool showCurrentWhenSubEntities;

  @override
  Map<String, dynamic> asMap() {
    final map = {
      "dateSent": dateSent?.toIso8601String(),
      "subEntities": subEntities?.toList(),
      "showCurrentWhenSubEntities": showCurrentWhenSubEntities
    };

    return map;
  }

  @override
  APISchemaObject documentSchema(APIDocumentContext context) {
    return APISchemaObject.object({
      "dateSent": APISchemaObject.string(),
      "subEntities": APISchemaObject.array(ofType: APIType.integer),
      "showCurrentWhenSubEntities": APISchemaObject.boolean()
    });
  }

  @override
  void read(Map<String, dynamic> object, {Iterable<String> ignore, Iterable<String> reject, Iterable<String> require}) {
    return null;
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    _fromMap(object);
  }

  void _fromMap(Map<String, dynamic> map) {
    dateSent = map["date"] != null ? DateTime.tryParse(map["date"] as String) : DateTime.now().toUtc();
    showCurrentWhenSubEntities =
        map["showCurrentWhenSubEntities"] != null ? map["showCurrentWhenSubEntities"] as bool : false;
    subEntities = (map["subEntities"] as List<dynamic>)?.map((dynamicId) => dynamicId as int)?.toList();
  }
}
