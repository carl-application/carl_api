import 'package:carl_api/carl_api.dart';

class BusinessSendNotificationResponse implements Serializable {
  BusinessSendNotificationResponse({this.success, this.nbMatchedUsers, this.error});

  final bool success;
  final int nbMatchedUsers;
  final int error;

  @override
  Map<String, dynamic> asMap() {
    final map = {
      "success": success,
      "nbMatchedUsers": nbMatchedUsers,
      "error": error,
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
