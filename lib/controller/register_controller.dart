import 'package:carl_api/model/account.dart';
import 'package:carl_api/model/business.dart';
import 'package:carl_api/response/password_error.dart';

import '../carl_api.dart';
import '../model/user.dart';

class RegisterController extends ResourceController {
  RegisterController(this._context, this._authServer);

  final ManagedContext _context;
  final AuthServer _authServer;

  @Operation.post()
  Future<Response> createUser(@Bind.body() Account account) async {
    // Check for required parameters before we spend time hashing
    if (account.username == null || account.password == null) {
      return Response.badRequest(body: {"error": "username and password of user are required."});
    }

    if (account.user == null && account.business == null) {
      return Response.badRequest(body: {"error": "missing a linked user or business"});
    }

    if (account.password.length < 6) {
      return Response.unauthorized(body: PasswordError());
    }

    var hasUppercase = false;
    var hasNumber = false;
    for (var index = 0; index < account.password.length; index++) {
      if (_isNumeric(account.password[index])) {
        hasNumber = true;
      } else {
        if (account.password[index] == account.password[index].toUpperCase()) {
          hasUppercase = true;
        }
      }
    }

    if (!hasNumber || !hasUppercase) {
      return Response.unauthorized(body: PasswordError());
    }

    account
      ..salt = AuthUtility.generateRandomSalt()
      ..hashedPassword = _authServer.hashPassword(account.password, account.salt);

    final query = Query<Account>(_context);

    if (account.user != null) {
      final insertUserQuery = Query<User>(_context)..values = account.user;
      final user = await insertUserQuery.insert();
      query
        ..values = account
        ..values.user = user;
    } else {
      if (account.business.affiliationKey != null) {
        final getParentQuery = Query<Business>(_context)
          ..where((business) => business.affiliationKey).identifiedBy(account.business.affiliationKey);

        final parentBusiness = await getParentQuery.fetchOne();

        account.business.parent = parentBusiness;
      }
      final insertBusinessQuery = Query<Business>(_context)..values = account.business;
      final business = await insertBusinessQuery.insert();
      query
        ..values = account
        ..values.business = business;
    }

    final insertedAccount = await query.insert();

    final token = await _authServer.authenticate(account.username, account.password,
        request.authorization.credentials.username, request.authorization.credentials.password);

    final response = AuthController.tokenResponse(token);
    final newBody = insertedAccount.asMap()..["authorization"] = response.body;
    return response..body = newBody;
  }

  @override
  Map<String, APIResponse> documentOperationResponses(APIDocumentContext context, Operation operation) {
    return {
      "200": APIResponse.schema("User successfully registered.", context.schema.getObject("UserRegistration")),
      "400": APIResponse.schema("Error response", APISchemaObject.freeForm())
    };
  }

  @override
  void documentComponents(APIDocumentContext context) {
    super.documentComponents(context);

    final userSchemaRef = context.schema.getObjectWithType(User);
    final userRegistration = APISchemaObject.object({
      "authorization": APISchemaObject.object({
        "access_token": APISchemaObject.string(),
        "token_type": APISchemaObject.string(),
        "expires_in": APISchemaObject.integer(),
        "refresh_token": APISchemaObject.string(),
        "scope": APISchemaObject.string()
      })
    });

    context.schema.register("UserRegistration", userRegistration);

    context.defer(() {
      final userSchema = context.document.components.resolve(userSchemaRef);
      userRegistration.properties.addAll(userSchema.properties);
    });
  }

  bool _isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }
}
