class StripeCreateSubscriptionResponse {
  StripeCreateSubscriptionResponse({this.id, this.paymentIntent});

  final String id;
  final PaymentIntent paymentIntent;

  factory StripeCreateSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return StripeCreateSubscriptionResponse(
        id: json['id'] as String,
        paymentIntent: json['payment_intent'] != null
            ? PaymentIntent.fromJson(json['payment_intent'] as Map<String, dynamic>)
            : null);
  }
}

class PaymentIntent {
  PaymentIntent({this.status});

  final String status;

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    return PaymentIntent(status: json['status'] as String);
  }
}
