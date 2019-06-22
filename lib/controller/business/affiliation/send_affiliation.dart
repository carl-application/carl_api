import 'dart:convert';

import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/business.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class SendAffiliationController extends ResourceController {
  SendAffiliationController(this._context, this.mailKey, this.mailSecret);

  final ManagedContext _context;
  final String mailKey;
  final String mailSecret;

  @Operation.post()
  Future<Response> sendAffiliation(@Bind.query("recipient") String recipient) async {
    final accountQuery = Query<Account>(_context)
      ..where((account) => account.id).identifiedBy(request.authorization.ownerID)
      ..where((account) => account.business).isNotNull()
      ..join(object: (account) => account.business);

    final ownerAccount = await accountQuery.fetchOne();

    if (ownerAccount == null) {
      return Response.unauthorized();
    }

    var affiliationKey = ownerAccount.business.affiliationKey;
    if (affiliationKey == null) {
      affiliationKey = Uuid().v4();
      final createAffiliationKeyQuery = Query<Business>(_context)
        ..where((business) => business.id).identifiedBy(ownerAccount.business.id)
        ..values.affiliationKey = affiliationKey;

      await createAffiliationKeyQuery.updateOne();
    }

    await sendEmail(recipient, affiliationKey, ownerAccount.business.name);
    await sendEmail(recipient, affiliationKey, ownerAccount.business.name);

    return Response.ok("sent");
  }

  Future<void> sendEmail(String recipient, String affiliationKey, String businessName) async {
    final response = await http.post("https://api.mailjet.com/v3.1/send",
        headers: {HttpHeaders.authorizationHeader: getBasicHeader(), HttpHeaders.contentTypeHeader: "application/json"},
        body: json.encode({
          "Messages": [
            {
              "From": {
                "Email": "carl.fidelity@gmail.com",
              },
              "To": [
                {
                  "Email": recipient,
                }
              ],
              "Subject": "Vous avez reçu une clé d'affiliation !",
              "TemplateID": 885612,
              "TemplateLanguage": true,
              "Variables": {
                "businessName": businessName,
                "affiliationKey": affiliationKey
              }
            }
          ]
        }));

    print("sending email response = ${response.statusCode}");
    return null;
  }

  String getBasicHeader() {
    final clientCredentials = Base64Encoder().convert("$mailKey:$mailSecret".codeUnits);

    return "Basic $clientCredentials";
  }
}
