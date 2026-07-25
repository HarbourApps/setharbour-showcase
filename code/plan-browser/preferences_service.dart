import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over [SharedPreferences] for the small amount of on-device UI
/// state the demo persists (currently the preferred plan-browser view).
///
/// This is the only persistence the portfolio edition writes. It stores a UI
/// preference string — never workout data, never anything personal.
class PreferencesService {
  const PreferencesService();

  static const String _kPreferredPlanView = 'preferred_plan_view';

  Future<String?> getPreferredPlanView() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPreferredPlanView);
  }

  Future<void> setPreferredPlanView(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPreferredPlanView, value);
  }
}
