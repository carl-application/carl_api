import 'package:carl_api/controller/admin/admin_controller.dart';
import 'package:carl_api/controller/admin/admin_get_businesses_controller.dart';
import 'package:carl_api/controller/admin/admin_make_premium_controller.dart';
import 'package:carl_api/controller/admin/admin_middleware_controller.dart';
import 'package:carl_api/controller/admin/admin_send_notifications.dart';
import 'package:carl_api/controller/admin/image_admin_controller.dart';
import 'package:carl_api/controller/business/affiliation/get_affiliations.dart';
import 'package:carl_api/controller/business/business_campaigns_controller.dart';
import 'package:carl_api/controller/business/business_card_color_controller.dart';
import 'package:carl_api/controller/business/business_card_image_controller.dart';
import 'package:carl_api/controller/business/business_controller.dart';
import 'package:carl_api/controller/business/business_logo_controller.dart';
import 'package:carl_api/controller/business/business_tags_controller.dart';
import 'package:carl_api/controller/businesses_locations.dart';
import 'package:carl_api/controller/image_controller.dart';
import 'package:carl_api/controller/user/user_cards_controller.dart';
import 'package:carl_api/controller/user/user_notifications_blacklist_controller.dart';
import 'package:carl_api/controller/user/user_visit_controller.dart';
import 'package:carl_api/controller/user/user_visit_meta_infos_controller.dart';
import 'package:carl_api/controller/user/user_visit_nfc_controller.dart';
import 'package:carl_api/controller/user/user_visit_scan_controller.dart';
import 'package:carl_api/model/account.dart';

import 'carl_api.dart';
import 'controller/business/affiliation/send_affiliation.dart';
import 'controller/business/analytics/business_age_repartition_controller.dart';
import 'controller/business/analytics/business_nb_customers_controller.dart';
import 'controller/business/analytics/business_nb_visits_for_date_controller.dart';
import 'controller/business/analytics/business_nb_visits_for_last_twelve_months_controller.dart';
import 'controller/business/analytics/business_sex_parity_controller.dart';
import 'controller/business/business_current_informations_controller.dart';
import 'controller/business/business_send_notification_controller.dart';
import 'controller/business/business_send_notification_to_campaign_controller.dart';
import 'controller/business/current_business_controller.dart';
import 'controller/logos_controller.dart';
import 'controller/register_controller.dart';
import 'controller/settings_controller.dart';
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
  String stripeKey;
  String mailJetKey;
  String mailJetSecret;
  String geocodingApiKey;

  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future prepare() async {
    CORSPolicy.defaultPolicy.allowedOrigins = [
      "http://localhost:8080",
      "http://www.carl-fidelity.com",
      "https://www.carl-fidelity.com"
    ];
    logger.onRecord.listen((rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    final config = CarlApiConfiguration(options.configurationFilePath);

    firebaseServerKey = config.firebaseServerKey;
    stripeKey = config.stripeKey;
    mailJetKey = config.mailJetKey;
    mailJetSecret = config.mailJetSecret;
    geocodingApiKey = config.geocodingApiKey;
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
        .link(() => RegisterController(context, authServer, geocodingApiKey));

    /* Handle Admin accounts */
    router.route("/admin/[:userId]").link(() => Authorizer.bearer(authServer)).link(() => AdminController(context));

    /* Handle Settings for admin */
    router.route("/admin/settings").link(() => Authorizer.bearer(authServer)).link(() => SettingsController(context));

    /* Handle Admin sending notifications*/
    router
        .route("/admin/notification")
        .link(() => Authorizer.bearer(authServer))
        .link(() => AdminSendNotificationsController(context, firebaseServerKey));

    /* Handle Images accessible for admin */
    router
        .route("/admin/business")
        .link(() => Authorizer.bearer(authServer))
        .link(() => AdminMiddlewareController(context))
        .link(() => AdminGetBusinessesController(context));

    /* Handle making a business Premium */
    router
        .route("/admin/premium/[:id]")
        .link(() => Authorizer.bearer(authServer))
        .link(() => AdminMiddlewareController(context))
        .link(() => AdminMakePremiumController(context));

    /* Handle Images accessible for admin */
    router
        .route("/admin/images/[:id]")
        .link(() => Authorizer.bearer(authServer))
        .link(() => AdminMiddlewareController(context))
        .link(() => ImageAdminController(context));

    /* Handle Images accessible for anyone */
    router.route("/images/[:id]").link(() => ImageController(context));

    /* Handle logos accessible for anyone */
    router.route("/logos").link(() => LogosController(context));

    /* Handle Other Business profile with bearer token */
    router.route("/business/[:id]").link(() => Authorizer.bearer(authServer)).link(() => BusinessController(context));

    /* Handle Current Business profile with bearer token */
    router
        .route("/business/current")
        .link(() => Authorizer.bearer(authServer))
        .link(() => CurrentBusinessController(context, authServer));

    /* Handle Current business profile with bearer token */
    router
        .route("/business/infos")
        .link(() => Authorizer.bearer(authServer))
        .link(() => BusinessCurrentInformationsController(context, geocodingApiKey));

    /* Handle Business campaigns with bearer token */
    router
        .route("/business/campaigns")
        .link(() => Authorizer.bearer(authServer))
        .link(() => BusinessCampaignsController(context));

    /* Handle Business locations */
    router
        .route("/business/locations")
        .link(() => Authorizer.bearer(authServer))
        .link(() => UserBusinessesLocations(context));

    /* Handle Business campaigns  notifications with bearer token */
    router
        .route("/business/campaigns/notifications")
        .link(() => Authorizer.bearer(authServer))
        .link(() => BusinessSendNotificationToCampaignController(context, firebaseServerKey));

    /* Handle Businesses Tags*/
    router.route("/business/tags").link(() => Authorizer.bearer(authServer)).link(() => TagController(context));

    /* Handle Businesses Card image*/
    router
        .route("/business/card/image/[:id]")
        .link(() => Authorizer.bearer(authServer))
        .link(() => BusinessCardImageController(context));

    /* Handle Businesses Logo image*/
    router
        .route("/business/logo/[:id]")
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

    router
        .route("/business/analytics/visits/date")
        .link(() => Authorizer.bearer(authServer))
        .link(() => BusinessNbVisitsForDateController(context));

    router
        .route("/business/analytics/visits")
        .link(() => Authorizer.bearer(authServer))
        .link(() => BusinessNbVisitsForLastTwelveMonthsController(context));

    router
        .route("/business/analytics/ages")
        .link(() => Authorizer.bearer(authServer))
        .link(() => BusinessAgeRepartitionController(context));

    router
        .route("/business/analytics/customer/count")
        .link(() => Authorizer.bearer(authServer))
        .link(() => BusinessNbCustomersController(context));

    router
        .route("/business/analytics/customer/sex/count/[:sex]")
        .link(() => Authorizer.bearer(authServer))
        .link(() => BusinessSexParityController(context));

    /* Handle sending an affiliation link */
    router
        .route("/business/affiliation/send")
        .link(() => Authorizer.bearer(authServer))
        .link(() => SendAffiliationController(context, mailJetKey, mailJetSecret));

    /* Handle getting all current business affiliations */
    router
        .route("/business/affiliation")
        .link(() => Authorizer.bearer(authServer))
        .link(() => GetAffiliationsController(context));

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
  String stripeKey;
  String mailJetKey;
  String mailJetSecret;
  String geocodingApiKey;
}
