import 'package:carl_api/carl_api.dart';

class StripeCreateSubscriptionResponse implements Serializable {
  StripeCreateSubscriptionResponse({this.id, this.latestinvoice});

  final String id;
  final Latestinvoice latestinvoice;

  factory StripeCreateSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return StripeCreateSubscriptionResponse(
        id: json['id'] as String,
        latestinvoice: json['latest_invoice'] != null
            ? Latestinvoice.fromJson(json['latest_invoice'] as Map<String, dynamic>)
            : null);
  }

  @override
  Map<String, dynamic> asMap() {
    return {
      "id": id,
      "latestinvoice": latestinvoice?.asMap(),
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

class Latestinvoice implements Serializable {
  Latestinvoice({this.paid, this.status, this.paymentIntent});

  final bool paid;
  final String status;
  final PaymentIntent paymentIntent;

  factory Latestinvoice.fromJson(Map<String, dynamic> json) {
    return Latestinvoice(
        paid: json['paid'] as bool,
        status: json['status'] as String,
        paymentIntent: json['payment_intent'] != null
            ? PaymentIntent.fromJson(json['payment_intent'] as Map<String, dynamic>)
            : null);
  }

  @override
  Map<String, dynamic> asMap() {
    return {
      "paid": paid,
      "status": status,
      "paymentIntent": paymentIntent?.asMap()
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

class PaymentIntent implements Serializable {
  PaymentIntent({this.status});

  final String status;

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    return PaymentIntent(status: json['status'] as String);
  }

  @override
  Map<String, dynamic> asMap() {
    return {"status": status};
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
