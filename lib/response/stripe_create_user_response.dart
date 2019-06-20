class StripeCreateUserResponse {
  final String id;

  StripeCreateUserResponse({this.id});

  factory StripeCreateUserResponse.fromJson(Map<String, dynamic> json) {
    return StripeCreateUserResponse(id: json['id'] as String);
  }
}
