import 'package:carl_api/carl_api.dart';

class PasswordError implements Serializable {
  PasswordError();

  final String error = "INVALID_PASSWORD";

  @override
  Map<String, dynamic> asMap() {
    return {"error": error};
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
