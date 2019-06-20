import 'dart:convert';
import 'dart:io';

import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/response/stripe_create_subscription_response.dart';
import 'package:carl_api/response/stripe_create_user_response.dart';
import 'package:http/http.dart' as http;

class SubscriptionPaymentController extends ResourceController {
  final ManagedContext _context;
  final String stripeKey;

  SubscriptionPaymentController(this._context, this.stripeKey);

  @Operation.post()
  Future<Response> pay(@Bind.query("cardToken") String cardToken) async {
    final createUserResponse = await http.post("https://api.stripe.com/v1/customers",
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $stripeKey",
          HttpHeaders.contentTypeHeader: "application/json"
        },
        body: json.encode({
          "source": cardToken,
        }));

    print("createUserResponse : $createUserResponse");

    if (createUserResponse.statusCode != 200) {
      return Response.serverError(body: "create user failed = ${createUserResponse.body}");
    }

    final StripeCreateUserResponse result =
        StripeCreateUserResponse.fromJson(json.decode(createUserResponse.body) as Map<String, dynamic>);
    print("result.id = ${result.id}");

    final createSubscriptionResponse = await http.post("https://api.stripe.com/v1/subscriptions",
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $stripeKey",
          HttpHeaders.contentTypeHeader: "application/json"
        },
        body: json.encode({
          "customer": result.id,
          "items[0][plan]": "plan_CBXbz9i7AIOTzr",
          "expand[]": "latest_invoice.payment_intent"
        }));

    if (createSubscriptionResponse.statusCode != 200) {
      return Response.serverError(body: "create subscription failed = ${createSubscriptionResponse.body}");
    }

    final StripeCreateSubscriptionResponse subscriptionResult =
        StripeCreateSubscriptionResponse.fromJson(json.decode(createSubscriptionResponse.body) as Map<String, dynamic>);

    return Response.ok(subscriptionResult.paymentIntent.status);
  }
}
