import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/business.dart';

class UserVisitInfoResponse implements Serializable {
  UserVisitInfoResponse(this.userVisitsCount, this.business);

  final int userVisitsCount;
  final Business business;

  @override
  Map<String, dynamic> asMap() {
    final map = {"userVisitsCount": userVisitsCount, "business": business.asMap()};

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
