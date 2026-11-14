import 'package:flutter/foundation.dart';
import 'package:ol1n_telemetry/ol1n_telemetry.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'telemetry_dictionary.dart';

/// Whether Lexify measures anything on [platform].
///
/// **Never on Android.** On Google Play the app's target audience includes
/// children under 13, so the Families policy applies (plan 04 §10.3, owner's
/// decision: Lexify is not measured on Android). The web build has no sink
/// anyway. iOS, macOS, Windows and Linux are measured.
bool telemetryAllowedOn(TargetPlatform platform, {bool web = kIsWeb}) =>
    !web && platform != TargetPlatform.android;

/// Whether the settings switch is shown: a platform that is measured and a
/// build that can send (a key). [Telemetry.isConfigured] alone is not enough,
/// because before `init` it only looks at the build's `--dart-define`s.
bool telemetryToggleVisible({TargetPlatform? platform, bool web = kIsWeb}) =>
    telemetryAllowedOn(platform ?? defaultTargetPlatform, web: web) &&
    Telemetry.isConfigured;

/// The UI language `lang` reports; [LexifyApp] keeps it current.
String telemetryLang = 'en';

/// Keys that exist only on a device that used Lexify before measuring.
bool hadLexifyData(Iterable<String> prefsKeys) => prefsKeys.any((k) =>
    !k.startsWith('telemetry_') &&
    (k == 'free_decks_seeded_v1' ||
        k == 'deck_entitlements' ||
        k == 'owned_product_codes' ||
        k.startsWith('card_priorities_')));

/// The telemetry store on top of SharedPreferences, which the app already
/// uses for priorities and entitlements.
class PrefsTelemetryStore implements TelemetryStore {
  PrefsTelemetryStore(this._prefs);
  final SharedPreferences _prefs;
  @override
  Future<String?> read(String key) async => _prefs.getString(key);
  @override
  Future<void> write(String key, String value) => _prefs.setString(key, value);
  @override
  Future<void> remove(String key) => _prefs.remove(key);
}

/// Start measuring, unless [platform] is not measured (Android, web): then
/// `Telemetry.init` is never called and every `Telemetry.*` call stays a
/// no-op. The remaining parameters are for tests.
Future<void> startTelemetry({
  TargetPlatform? platform,
  bool web = kIsWeb,
  TelemetryStore? store,
  Iterable<String> Function()? prefsKeys,
  TelemetrySink? sink,
  bool startTimer = true,
  bool observeLifecycle = true,
}) async {
  if (!telemetryAllowedOn(platform ?? defaultTargetPlatform, web: web)) return;
  try {
    SharedPreferences? prefs;
    if (store == null || prefsKeys == null) {
      prefs = await SharedPreferences.getInstance();
    }
    await Telemetry.init(
      app: 'lexify',
      appVersion: kAppVersion,
      dictionary: lexifyDictionary,
      store: store ?? PrefsTelemetryStore(prefs!),
      lang: () => kUiLangs.contains(telemetryLang) ? telemetryLang : 'en',
      tester: const bool.fromEnvironment('TELEMETRY_TESTER'),
      hadDataBefore: () => hadLexifyData(prefsKeys?.call() ?? prefs!.getKeys()),
      sink: sink,
      startTimer: startTimer,
      observeLifecycle: observeLifecycle,
    );
  } catch (_) {
    // Measuring never stops the app.
  }
}
