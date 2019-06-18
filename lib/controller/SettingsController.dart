import 'package:aqueduct/aqueduct.dart';
import 'package:carl_api/carl_api.dart';
import 'package:carl_api/model/setting.dart';

class SettingsController extends ResourceController {
  final ManagedContext _context;

  SettingsController(this._context);

  @Operation.get()
  Future<Response> getSettings() async {
    final getSettingsQuery = Query<Settings>(_context);
    return Response.ok(await getSettingsQuery.fetchOne());
  }

  @Operation.post()
  Future<Response> postSettings(@Bind.body() Settings settings) async {
    final insertSettingsQuery = Query<Settings>(_context)..values = settings;

    return Response.ok(await insertSettingsQuery.insert());
  }

  @Operation.put()
  Future<Response> updateSettings(@Bind.body() Settings settings) async {
    final oldSettings = await Query<Settings>(_context).fetchOne();
    final updateSettingsQuery = Query<Settings>(_context)
      ..values = settings
      ..where((settings) => settings.id).identifiedBy(oldSettings.id);
    return Response.ok(await updateSettingsQuery.updateOne());
  }
}
