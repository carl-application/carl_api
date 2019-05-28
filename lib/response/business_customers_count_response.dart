import 'package:carl_api/carl_api.dart';

class BusinessCustomersCountResponse implements Serializable {
  BusinessCustomersCountResponse({this.customersCount});

  final int customersCount;

  @override
  Map<String, dynamic> asMap() {
    final map = {"customersCount": customersCount};

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
