import 'dart:convert';
import 'dart:io';

import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/response/business_pay_premium_response.dart';
import 'package:carl_api/response/stripe_create_subscription_error.dart';
import 'package:carl_api/response/stripe_create_subscription_response.dart';
import 'package:carl_api/response/stripe_create_user_response.dart';
import 'package:http/http.dart' as http;

class SubscriptionPaymentController extends ResourceController {
  final ManagedContext _context;
  final String stripeKey;

  SubscriptionPaymentController(this._context, this.stripeKey);

  @Operation.post()
  Future<Response> pay(@Bind.query("cardToken") String cardToken) async {
    final accountQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull();

    final ownerAccount = await accountQuery.fetchOne();

    if (ownerAccount == null) {
      return Response.unauthorized();
    }

    final userCreationData = {'source': cardToken, 'email': ownerAccount.username};
    final createUserResponse = await http.post("https://api.stripe.com/v1/customers",
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $stripeKey",
          HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded"
        },
        body: userCreationData);

    if (createUserResponse.statusCode != 200) {
      final error =
          StripeCreateSubscriptionError.fromJson(json.decode(createUserResponse.body) as Map<String, dynamic>);
      return Response.ok(
          BusinessPayPremiumResponse(stripeCreateSubscriptionError: error, stripeCreateSubscriptionResponse: null));
    }

    final StripeCreateUserResponse result =
        StripeCreateUserResponse.fromJson(json.decode(createUserResponse.body) as Map<String, dynamic>);
    print("result.id = ${result.id}");

    final params = {
      "customer": result.id,
      "items[0][plan]": "plan_FIhkFmymwBzWaY",
      "expand[]": "latest_invoice.payment_intent"
    };
    final createSubscriptionResponse = await http.post("https://api.stripe.com/v1/subscriptions",
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $stripeKey",
          HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded"
        },
        body: params);

    if (createSubscriptionResponse.statusCode != 200) {
      final error =
          StripeCreateSubscriptionError.fromJson(json.decode(createSubscriptionResponse.body) as Map<String, dynamic>);
      return Response.ok(
          BusinessPayPremiumResponse(stripeCreateSubscriptionError: error, stripeCreateSubscriptionResponse: null));
    }

    final StripeCreateSubscriptionResponse subscriptionResult =
        StripeCreateSubscriptionResponse.fromJson(json.decode(createSubscriptionResponse.body) as Map<String, dynamic>);

    return Response.ok(BusinessPayPremiumResponse(
        stripeCreateSubscriptionError: null, stripeCreateSubscriptionResponse: subscriptionResult));
  }
}
