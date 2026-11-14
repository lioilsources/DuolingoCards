import 'package:ol1n_telemetry/ol1n_telemetry.dart';

import '../models/card_style.dart';

/// The app version this build reports; `test/telemetry_test.dart` keeps it
/// equal to `version:` in `pubspec.yaml`.
const kAppVersion = '2.3.4';

/// Route name → screen. Every `push` in the app names its route with one of
/// these keys; an unnamed or unknown route reports `other`.
const kScreenRoutes = {
  '/': 'home',
  '/store': 'store',
  '/store/deck': 'store_deck',
  '/study': 'study',
  '/settings': 'settings',
};

/// Deck slugs, a closed list. `test/telemetry_test.dart` fails when a bundled
/// deck is missing here; a deck the build does not know reports `other`.
const kDeckIds = {
  'animals-birds',
  'animals-farm',
  'animals-insects',
  'animals-pets',
  'animals-reptiles',
  'animals-sea',
  'animals-wild',
  'body-parts',
  'colors-basic',
  'emotions',
  'food-fruits',
  'food-vegetables',
  'geo-flags',
  'numbers-1-10',
  'weather',
  'other',
};

/// Card languages (the language being learned), a closed list. The test
/// checks it covers every language of every bundled deck.
const kCardLangs = {
  'ar', 'bg', 'cs', 'da', 'de', 'el', 'en', 'es-419', 'fr', 'he', 'hi', //
  'hr', 'id', 'it', 'ja', 'ko', 'nb', 'nl', 'pl', 'pt-BR', 'ro', 'ru', //
  'sk', 'sl', 'sr', 'sv', 'tr', 'uk', 'vi', 'zh-CN', 'other',
};

/// Image styles: the app's style registry plus `other`.
final kStyleIds = {for (final s in CardStyle.all) s.id, 'other'};

String telemetryDeck(String slug) => kDeckIds.contains(slug) ? slug : 'other';
String telemetryCardLang(String l) => kCardLangs.contains(l) ? l : 'other';
String telemetryStyle(String s) => kStyleIds.contains(s) ? s : 'other';

/// The UI languages of the app (`LexifyApp.supportedLocales`), as
/// `telemetryLocaleId` spells them.
const kUiLangs = {
  'en', 'cs', 'ar', 'de', 'el', 'es', 'fr', 'he', 'hi', 'id', 'ja', 'ko', //
  'pt', 'pt_PT', 'ru', 'tr', 'vi', 'zh', 'zh_Hant',
};

/// The one event dictionary of Lexify, mirrored in `docs/telemetry.md`.
final lexifyDictionary = TelemetryDictionary(
  appVersion: kAppVersion,
  languages: kUiLangs,
  screens: kScreenRoutes.values.toSet(),
  features: {
    'search',
    'reorder',
    'restore',
    'pronounce',
    'flip',
    'card_back',
    'card_report',
    'style_pick',
    'lang_pick',
  },
  errorKinds: {
    'store_load',
    'download',
    'purchase_start',
    'deck_not_owned',
    'no_voice',
  },
  lockedTargets: {'paid_deck'},
  events: {
    'deck_view': {
      'deck': EnumProp(kDeckIds),
      'free': const BoolProp(),
      'owned': const BoolProp(),
    },
    'deck_add': {
      'deck': EnumProp(kDeckIds),
      'style': EnumProp(kStyleIds),
      'l2': EnumProp(kCardLangs),
      'free': const BoolProp(),
    },
    'card_report': {
      'issue': const EnumProp(
          {'translation', 'image', 'pronunciation', 'meaning', 'other'}),
      'via': const EnumProp({'mail', 'clipboard'}),
    },
    ...TelemetryDictionary.flow('study', start: {
      'deck': EnumProp(kDeckIds),
      'style': EnumProp(kStyleIds),
      'l2': EnumProp(kCardLangs),
      'free': const BoolProp(),
      'from': const EnumProp({'home', 'store'}),
    }, end: {
      'rated': const IntProp(100000),
      'known': const IntProp(100000),
      'unknown': const IntProp(100000),
    }),
    ...TelemetryDictionary.flow('purchase', start: {
      'deck': EnumProp(kDeckIds),
    }),
    ...TelemetryDictionary.flow('download', start: {
      'deck': EnumProp(kDeckIds),
      'style': EnumProp(kStyleIds),
      'from': const EnumProp({'home', 'store'}),
    }),
  },
);
