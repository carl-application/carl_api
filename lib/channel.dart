import 'package:carl_api/controller/admin_controller.dart';
import 'package:carl_api/controller/business/business_audiences_controller.dart';
import 'package:carl_api/controller/business/business_card_color_controller.dart';
import 'package:carl_api/controller/business/business_card_image_controller.dart';
import 'package:carl_api/controller/business/business_controller.dart';
import 'package:carl_api/controller/business/business_logo_controller.dart';
import 'package:carl_api/controller/business/business_tags_controller.dart';
import 'package:carl_api/controller/image_controller.dart';
import 'package:carl_api/controller/user/user_cards_controller.dart';
import 'package:carl_api/controller/user/user_notifications_blacklist_controller.dart';
import 'package:carl_api/controller/user/user_visit_controller.dart';
import 'package:carl_api/controller/user/user_visit_meta_infos_controller.dart';
import 'package:carl_api/controller/user/user_visit_nfc_controller.dart';
import 'package:carl_api/controller/user/user_visit_scan_controller.dart';
import 'package:carl_api/model/account.dart';

import 'carl_api.dart';
import 'controller/business/business_send_notification_controller.dart';
import 'controller/register_controller.dart';
import 'controller/user/user_controller.dart';
import 'controller/user/user_notification_token_controller.dart';
import 'controller/user/user_read_notifications_controller.dart';
import 'controller/user/user_search_business_controller.dart';
import 'controller/user/user_unread_notifications_controller.dart';
import 'controller/user/user_unread_notifications_count_controller.dart';

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://aqueduct.io/docs/http/channel/.
class CarlApiChannel extends ApplicationChannel {
  AuthServer authServer;
  ManagedContext context;
  String firebaseServerKey;

  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future prepare() async {
    CORSPolicy.defaultPolicy.allowedOrigins = ["http://localhost:8080"];
    logger.onRecord.listen((rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    final config = CarlApiConfiguration(options.configurationFilePath);

    firebaseServerKey = config.firebaseServerKey;
    context = contextWithConnectionInfo(config.database);

    final authStorage = ManagedAuthDelegate<Account>(context);
    authServer = AuthServer(authStorage);
  }

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint {
    final router = Router();

    /* OAuth 2.0 Endpoints */
    router.route("/auth/token").link(() => AuthController(authServer));

    /* Create an account */
    router
        .route("/register")
        .link(() => Authorizer.basic(authServer))
        .link(() => RegisterController(context, authServer));

    /* Handle Admin accounts */
    router.route("/admin/[:userId]").link(() => Authorizer.bearer(authServer)).link(() => AdminController(context));

    /* Handle Images*/
    router.route("/images/[:id]").link(() => Authorizer.bearer(authServer)).link(() => ImageController(context));

    /* Handle visits */
    router.route("/visit").link(() => Authorizer.bearer(authServer)).link(() => UserVisitController(context));

    /* Handle Business profile with bearer token */
    router.route("/business/[:id]").link(() => Authorizer.bearer(authServer)).link(() => BusinessController(context));

    /* Handle Business profile with bearer token */
    router
        .route("/business/audiences")
        .link(() => Authorizer.bearer(authServer))
        .link(() => BusinessAudiencesController(context));

    /* Handle Businesses Tags*/
    router.route("/business/tags").link(() => Authorizer.bearer(authServer)).link(() => TagController(context));

    /* Handle Businesses Card image*/
    router
        .route("/business/card/image/[:id]")
        .link(() => Authorizer.bearer(authServer))
        .link(() => BusinessCardImageController(context));

    /* Handle Businesses Logo image*/
    router
        .route("/business/logo")
        .link(() => Authorizer.bearer(authServer))
        .link(() => BusinessLogoController(context));

    /* Handle Businesses Card color*/
    router
        .route("/business/card/color/[:color]")
        .link(() => Authorizer.bearer(authServer))
        .link(() => BusinessCardColorController(context));

    /* Handle Businesses Card color*/
    router
        .route("/business/notifications")
        .link(() => Authorizer.bearer(authServer))
        .link(() => BusinessSendNotificationController(context, firebaseServerKey));

    /* Handle Business searching */
    router
        .route("/search/business/[:query]")
        .link(() => Authorizer.bearer(authServer))
        .link(() => UserBusinessSearchController(context));

    /* Handle User profile with bearer token */
    router
        .route("/user/[:id]")
        .link(() => Authorizer.bearer(authServer))
        .link(() => UserController(context, authServer));

    /* Handle User notification token */
    router
        .route("/user/notifications/token/[:token]")
        .link(() => Authorizer.bearer(authServer))
        .link(() => UserNotificationTokenController(context));

    /* Handle User read notifications count */
    router
        .route("/user/notifications/[:id]")
        .link(() => Authorizer.bearer(authServer))
        .link(() => UserReadNotificationsController(context));

    /* Handle User unread notifications count */
    router
        .route("/user/notifications/unread/count")
        .link(() => Authorizer.bearer(authServer))
        .link(() => UserUnreadNotificationsCountController(context));

    /* Handle User unread notifications */
    router
        .route("/user/notifications/unread/[:notificationId]")
        .link(() => Authorizer.bearer(authServer))
        .link(() => UserUnreadNotificationsController(context));

    /* Handle User getting visits on business */
    router.route("/user/visits").link(() => Authorizer.bearer(authServer)).link(() => UserVisitController(context));

    /* Handle User getting cards */
    router.route("/user/cards").link(() => Authorizer.bearer(authServer)).link(() => UserCardsController(context));

    /* Handle User getting visits infos about a business*/
    router
        .route("/user/visits/info/[:businessId]")
        .link(() => Authorizer.bearer(authServer))
        .link(() => UserVisitMetaInfoController(context));

    /* Handle User validating a visit by NFC */
    router
        .route("/user/visits/nfc/[:businessKey]")
        .link(() => Authorizer.bearer(authServer))
        .link(() => UserVisitNfcController(context));

    /* Handle User validating a visit by Scan */
    router
        .route("/user/visits/scan/[:businessKey]")
        .link(() => Authorizer.bearer(authServer))
        .link(() => UserVisitScanController(context));

    /* Handle User Notifications Blacklist  */
    router
        .route("/user/notifications/blacklist/[:businessId]")
        .link(() => Authorizer.bearer(authServer))
        .link(() => UserNotificationsBlackListController(context));

    return router;
  }

  /*
   * Helper methods
   */

  ManagedContext contextWithConnectionInfo(DatabaseConfiguration connectionInfo) {
    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    final psc = PostgreSQLPersistentStore(connectionInfo.username, connectionInfo.password, connectionInfo.host,
        connectionInfo.port, connectionInfo.databaseName);

    return ManagedContext(dataModel, psc);
  }
}

/// An instance of this class represents values from a configuration
/// file specific to this application.
///
/// Configuration files must have key-value for the properties in this class.
/// For more documentation on configuration files, see
/// https://pub.dartlang.org/packages/safe_config.
class CarlApiConfiguration extends Configuration {
  CarlApiConfiguration(String fileName) : super.fromFile(File(fileName));

  DatabaseConfiguration database;
  String firebaseServerKey;
}
