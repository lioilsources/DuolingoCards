import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// On-device pronunciation via the OS text-to-speech engine (`flutter_tts`).
///
/// No audio assets and no hosting: the OS voices do the work, offline when the
/// voice is installed. Per the no-backend plan, availability is checked per
/// language; when a voice is missing the UI offers to install it (the chosen
/// fallback) rather than silently failing.
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  /// Cache of language availability so we do not query the engine repeatedly.
  final Map<String, bool> _availability = {};

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await _tts.awaitSpeakCompletion(true);
    _initialized = true;
  }

  /// BCP-47 → engine locale. `flutter_tts` expects concrete locales, so map the
  /// plan's regional codes to what engines actually ship.
  static const Map<String, List<String>> _localeCandidates = {
    'es-419': ['es-MX', 'es-US', 'es-ES'],
    'pt-BR': ['pt-BR', 'pt-PT'],
    'zh-CN': ['zh-CN', 'zh'],
    'en': ['en-US', 'en-GB', 'en'],
    'ar': ['ar-SA', 'ar'],
    'ur': ['ur-PK', 'ur-IN', 'ur'],
    'bn': ['bn-IN', 'bn-BD', 'bn'],
    'ta': ['ta-IN', 'ta'],
    'te': ['te-IN', 'te'],
    'mr': ['mr-IN', 'mr'],
    'hi': ['hi-IN', 'hi'],
    'ha': ['ha-NG', 'ha'],
  };

  /// First engine locale that is actually available for [lang], or null.
  Future<String?> resolveLocale(String lang) async {
    await _ensureInit();
    final candidates = _localeCandidates[lang] ?? [lang, _base(lang)];
    for (final c in candidates) {
      if (await _isAvailable(c)) return c;
    }
    return null;
  }

  /// Whether any voice exists for [lang] on this device.
  Future<bool> isLanguageAvailable(String lang) async =>
      (await resolveLocale(lang)) != null;

  Future<bool> _isAvailable(String locale) async {
    final cached = _availability[locale];
    if (cached != null) return cached;
    bool ok = false;
    try {
      final res = await _tts.isLanguageAvailable(locale);
      ok = res == true || res == 1;
    } catch (e) {
      if (kDebugMode) debugPrint('TTS isLanguageAvailable($locale) failed: $e');
    }
    _availability[locale] = ok;
    return ok;
  }

  /// Speak [text] in [lang]. Returns false (without throwing) when no voice is
  /// available — callers should then surface [promptInstallVoice].
  Future<bool> speak(String text, String lang) async {
    if (text.isEmpty) return false;
    final locale = await resolveLocale(lang);
    if (locale == null) return false;
    try {
      await _tts.stop();
      await _tts.setLanguage(locale);
      await _tts.speak(text);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('TTS speak failed: $e');
      return false;
    }
  }

  Future<void> stop() => _tts.stop();

  /// Invalidate the cached availability map, e.g. after the user returns from
  /// the system voice-install screen.
  void invalidateAvailabilityCache() => _availability.clear();

  /// Whether this platform can deep-link to a voice installer. `flutter_tts`
  /// exposes no cross-platform install API, so opening Android's
  /// `ACTION_INSTALL_TTS_DATA` intent (or iOS Settings) requires a small native
  /// platform channel. Until that channel is wired up this returns false and
  /// callers should show guidance toward the OS voice settings.
  ///
  /// Extension point for the chosen "offer to install" fallback: implement a
  /// MethodChannel that fires the install intent and return true here.
  Future<bool> promptInstallVoice(String lang) async => false;

  static String _base(String lang) {
    final i = lang.indexOf('-');
    return i == -1 ? lang : lang.substring(0, i);
  }
}
