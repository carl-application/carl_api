import 'package:carl_api/carl_api.dart';

class StripeCreateSubscriptionError implements Serializable {
  StripeCreateSubscriptionError({this.error});

  final StripeError error;

  factory StripeCreateSubscriptionError.fromJson(Map<String, dynamic> json) {
    return StripeCreateSubscriptionError(
        error: json['error'] != null
            ? StripeError.fromJson(json['error'] as Map<String, dynamic>)
            : null);
  }

  @override
  Map<String, dynamic> asMap() {
    return {
      "code": error.code,
    };
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

class StripeError implements Serializable {
  StripeError({this.code});

  final String code;

  factory StripeError.fromJson(Map<String, dynamic> json) {
    return StripeError(code: json['code'] as String);
  }

  @override
  Map<String, dynamic> asMap() {
    return {
      "code": code,
    };
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
