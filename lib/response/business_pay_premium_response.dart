import 'package:carl_api/carl_api.dart';
import 'package:carl_api/response/stripe_create_subscription_error.dart';
import 'package:carl_api/response/stripe_create_subscription_response.dart';

class BusinessPayPremiumResponse implements Serializable {
  BusinessPayPremiumResponse({this.stripeCreateSubscriptionError, this.stripeCreateSubscriptionResponse});

  final StripeCreateSubscriptionError stripeCreateSubscriptionError;
  final StripeCreateSubscriptionResponse stripeCreateSubscriptionResponse;

  @override
  Map<String, dynamic> asMap() {
    final map = {
      "error": stripeCreateSubscriptionError?.error?.code,
      "response": stripeCreateSubscriptionResponse?.asMap()
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
