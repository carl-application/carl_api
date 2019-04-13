import 'package:aqueduct_test/aqueduct_test.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/account.dart';

export 'package:aqueduct/aqueduct.dart';
export 'package:aqueduct_test/aqueduct_test.dart';
export 'package:carl_api/carl_api.dart';
export 'package:test/test.dart';

/// A testing harness for carl_api.
///
/// A harness for testing an aqueduct application. Example test file:
///
///         void main() {
///           Harness harness = Harness()..install();
///
///           test("Make request", () async {
///             final response = await harness.agent.get("/path");
///             expectResponse(response, 200);
///           });
///         }
///
class Harness extends TestHarness<CarlApiChannel> with TestHarnessAuthMixin<CarlApiChannel>, TestHarnessORMMixin {
  @override
  ManagedContext get context => channel.context;

  @override
  AuthServer get authServer => channel.authServer;

  Agent publicAgent;

  @override
  Future onSetUp() async {
    // add initialization code that will run once the test application has started
    await resetData();

    publicAgent = await addClient("com.aqueduct.public");
  }

  Future<Agent> registerAccount(Account account, {Agent withClient}) async {
    withClient ??= publicAgent;

    final req = withClient.request("/register")..body = {"username": account.username, "password": account.password};
    await req.post();

    return loginUser(withClient, account.username, account.password);
  }
}
