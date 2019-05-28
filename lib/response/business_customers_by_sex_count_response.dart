import 'package:carl_api/carl_api.dart';

class BusinessCustomersBySexCountResponse implements Serializable {
  BusinessCustomersBySexCountResponse({this.women, this.men, this.np});

  final int women;
  final int men;
  final int np;

  @override
  Map<String, dynamic> asMap() {
    final map = {"women": women, "men": men, "np": np};

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
