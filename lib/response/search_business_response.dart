import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/business.dart';

class SearchBusinessResponse implements Serializable {
  SearchBusinessResponse({this.businessesFoundByName, this.businessesFoundByTags});

  final List<Business> businessesFoundByName;
  final List<Business> businessesFoundByTags;

  @override
  Map<String, dynamic> asMap() {
    final map = {
      "businessesFoundByName": businessesFoundByName.toList(),
      "businessesFoundByTags": businessesFoundByTags.toList()
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
    // TODO: implement read
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    // TODO: implement readFromMap
  }
}
