// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Panjabi Punjabi (`pa`).
class AppLocalizationsPa extends AppLocalizations {
  AppLocalizationsPa([String locale = 'pa']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'ਡੈੱਕ ਸਟੋਰ';

  @override
  String get homeEmptyTitle => 'ਅਜੇ ਕੋਈ ਡੈੱਕ ਨਹੀਂ';

  @override
  String get homeReorderHint => 'ਕ੍ਰਮ ਬਦਲਣ ਲਈ ਡੈੱਕ ਨੂੰ ਦਬਾ ਕੇ ਰੱਖੋ ਅਤੇ ਖਿੱਚੋ';

  @override
  String get homeBrowseStore => 'ਡੈੱਕ ਸਟੋਰ ਦੇਖੋ';

  @override
  String get homeDownloadingDecks => 'ਤੁਹਾਡੇ ਡੈੱਕ ਤਿਆਰ ਕੀਤੇ ਜਾ ਰਹੇ ਹਨ…';

  @override
  String get badgeFree => 'ਮੁਫ਼ਤ';

  @override
  String get badgeUnlocked => 'ਅਨਲੌਕ ਕੀਤਾ';

  @override
  String get badgePurchased => 'ਖਰੀਦਿਆ';

  @override
  String get badgePaidDeck => 'ਭੁਗਤਾਨ ਵਾਲਾ ਡੈੱਕ';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਕਾਰਡ',
      one: '1 ਕਾਰਡ',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards ਕਾਰਡ',
      one: '1 ਕਾਰਡ',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs ਭਾਸ਼ਾਵਾਂ',
      one: '1 ਭਾਸ਼ਾ',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count ਜਾਣੇ';
  }

  @override
  String legendLearning(int count) {
    return '$count ਸਿੱਖ ਰਹੇ';
  }

  @override
  String legendUnknown(int count) {
    return '$count ਅਣਜਾਣੇ';
  }

  @override
  String get storeTitle => 'ਡੈੱਕ ਸਟੋਰ';

  @override
  String get storeRestorePurchases => 'ਖਰੀਦਾਂ ਬਹਾਲ ਕਰੋ';

  @override
  String get storeSearchHint => 'ਡੈੱਕ ਖੋਜੋ…';

  @override
  String storeLoadError(String error) {
    return 'ਡੈੱਕ ਲੋਡ ਨਹੀਂ ਹੋ ਸਕੇ: $error';
  }

  @override
  String get storeNoDecks => 'ਕੋਈ ਡੈੱਕ ਉਪਲਬਧ ਨਹੀਂ।';

  @override
  String get storeNothingFound => 'ਕੁਝ ਨਹੀਂ ਮਿਲਿਆ।';

  @override
  String get retry => 'ਮੁੜ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String get buy => 'ਖਰੀਦੋ';

  @override
  String buyFor(String price) {
    return '$price ਵਿੱਚ ਖਰੀਦੋ';
  }

  @override
  String get add => 'ਸ਼ਾਮਲ ਕਰੋ';

  @override
  String get addFree => 'ਮੁਫ਼ਤ ਸ਼ਾਮਲ ਕਰੋ';

  @override
  String get back => 'ਪਿੱਛੇ';

  @override
  String get previous => 'ਪਿਛਲਾ';

  @override
  String get next => 'ਅਗਲਾ';

  @override
  String get study => 'ਪੜ੍ਹੋ';

  @override
  String get download => 'ਡਾਊਨਲੋਡ ਕਰੋ';

  @override
  String get confirmLanguagesLabel => 'ਭਾਸ਼ਾਵਾਂ';

  @override
  String get styleSectionTitle => 'ਤਸਵੀਰ ਦੀ ਸ਼ੈਲੀ';

  @override
  String get confirmBuyNote =>
      'ਖਰੀਦਣ ਨਾਲ ਪੂਰਾ ਡੈੱਕ ਅਨਲੌਕ ਹੋ ਜਾਂਦਾ ਹੈ — ਹਰ ਭਾਸ਼ਾ ਅਤੇ ਹਰ ਸ਼ੈਲੀ। ਇਹ ਜੋੜ ਤੁਹਾਡੀ ਹੋਮ ਸਕ੍ਰੀਨ \'ਤੇ ਸ਼ਾਮਲ ਹੋ ਜਾਵੇਗਾ।';

  @override
  String get confirmAddNote =>
      'ਇਹ ਜੋੜ ਤੁਹਾਡੀ ਹੋਮ ਸਕ੍ਰੀਨ \'ਤੇ ਸ਼ਾਮਲ ਹੋ ਜਾਵੇਗਾ। ਤੁਸੀਂ ਕਦੇ ਵੀ ਕੋਈ ਹੋਰ ਭਾਸ਼ਾ ਜਾਂ ਸ਼ੈਲੀ ਸ਼ਾਮਲ ਕਰ ਸਕਦੇ ਹੋ।';

  @override
  String get purchaseFailedToStart => 'ਖਰੀਦ ਸ਼ੁਰੂ ਨਹੀਂ ਹੋ ਸਕੀ।';

  @override
  String get addedToHome => 'ਹੋਮ ਸਕ੍ਰੀਨ \'ਤੇ ਸ਼ਾਮਲ ਕੀਤਾ ਗਿਆ।';

  @override
  String get downloadFailed => 'ਡਾਊਨਲੋਡ ਅਸਫਲ ਰਿਹਾ। ਕਿਰਪਾ ਕਰਕੇ ਮੁੜ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get deckNotPurchased => 'ਇਹ ਡੈੱਕ ਖਰੀਦਿਆ ਨਹੀਂ ਗਿਆ।';

  @override
  String downloading(int percent) {
    return 'ਡਾਊਨਲੋਡ ਹੋ ਰਿਹਾ ਹੈ… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਸਰਗਰਮ',
      one: '1 ਸਰਗਰਮ',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'ਮੈਨੂੰ ਆਉਂਦਾ ਹੈ';

  @override
  String get pickerLearning => 'ਸਿੱਖ ਰਿਹਾ ਹਾਂ';

  @override
  String get reportIssue => 'ਸਮੱਸਿਆ ਦੱਸੋ';

  @override
  String get issueTranslation => 'ਅਨੁਵਾਦ';

  @override
  String get issueImage => 'ਤਸਵੀਰ';

  @override
  String get issuePronunciation => 'ਉਚਾਰਨ';

  @override
  String get issueMeaning => 'ਅਰਥ / ਤੱਥ';

  @override
  String get issueOther => 'ਹੋਰ';

  @override
  String get feedbackCommentHint => 'ਕੀ ਗਲਤ ਹੈ? (ਵਿਕਲਪਿਕ)';

  @override
  String get feedbackSend => 'ਈ-ਮੇਲ ਰਾਹੀਂ ਭੇਜੋ';

  @override
  String feedbackNoMailApp(String email) {
    return 'ਕੋਈ ਈ-ਮੇਲ ਐਪ ਉਪਲਬਧ ਨਹੀਂ। ਰਿਪੋਰਟ ਕਲਿੱਪਬੋਰਡ \'ਤੇ ਕਾਪੀ ਕੀਤੀ ਗਈ ਹੈ — ਕਿਰਪਾ ਕਰਕੇ ਇਸਨੂੰ $email \'ਤੇ ਭੇਜੋ।';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] ਕਾਰਡ ਵਿੱਚ ਸਮੱਸਿਆ $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'ਡੈੱਕ: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'ਕਾਰਡ: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'ਭਾਸ਼ਾਵਾਂ: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'ਦਿਖਾਇਆ: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'ਸ਼ੈਲੀ: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'ਸਮੱਸਿਆ ਦੀ ਕਿਸਮ: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'ਨੂੰ: $email';
  }

  @override
  String get pronounce => 'ਉਚਾਰਨ ਕਰੋ';

  @override
  String get installVoice => 'ਆਵਾਜ਼ ਇੰਸਟਾਲ ਕਰੋ';

  @override
  String noVoiceInstalled(String lang) {
    return '\"$lang\" ਲਈ ਕੋਈ ਆਵਾਜ਼ ਇੰਸਟਾਲ ਨਹੀਂ ਹੈ। ਸੈਟਿੰਗਾਂ → ਪਹੁੰਚਯੋਗਤਾ → ਬੋਲੀ ਗਈ ਸਮੱਗਰੀ → ਆਵਾਜ਼ਾਂ ਵਿੱਚ ਇੱਕ ਸ਼ਾਮਲ ਕਰੋ, ਫਿਰ ਮੁੜ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';
  }

  @override
  String get playPronunciation => 'ਉਚਾਰਨ ਸੁਣੋ';

  @override
  String get swipeNext => 'ਅਗਲਾ';

  @override
  String get swipeBack => 'ਪਿੱਛੇ';

  @override
  String get showTranslation => 'ਅਨੁਵਾਦ ਦਿਖਾਓ';

  @override
  String get showOriginal => 'ਮੂਲ ਦਿਖਾਓ';

  @override
  String get noCards => 'ਕੋਈ ਕਾਰਡ ਨਹੀਂ';

  @override
  String get deckHasNoCards => 'ਇਸ ਡੈੱਕ ਵਿੱਚ ਕੋਈ ਕਾਰਡ ਨਹੀਂ।';

  @override
  String get flashcards => 'ਫਲੈਸ਼ਕਾਰਡ';

  @override
  String get stylePhoto => 'ਫੋਟੋ';

  @override
  String get stylePhotoDesc => 'ਸਾਫ਼ ਫੋਟੋ, ਅਸਲੀਅਤ ਦੇ ਸਭ ਤੋਂ ਨੇੜੇ';

  @override
  String get styleInk => 'ਬੁਰਸ਼ ਅਤੇ ਸਿਆਹੀ';

  @override
  String get styleInkDesc => 'ਬੁਰਸ਼ ਦੀਆਂ ਲਕੀਰਾਂ, ਕੋਰਾ ਕਾਗਜ਼, ਇੱਕ ਰੰਗ ਦੀ ਛੋਹ';

  @override
  String get stylePastel => 'ਪੇਸਟਲ';

  @override
  String get stylePastelDesc => 'ਰੰਗੀਨ ਕਾਗਜ਼ \'ਤੇ ਸੁੱਕਾ ਪੇਸਟਲ';

  @override
  String get styleWatercolor => 'ਜਲ-ਰੰਗ';

  @override
  String get styleWatercolorDesc => 'ਫੈਲਦੇ ਜਲ-ਰੰਗ, ਕਾਗਜ਼ ਝਲਕਦਾ ਹੈ';

  @override
  String get styleFlag => 'ਝੰਡੇ';

  @override
  String get styleFlagDesc => 'ਅਸਲੀ ਰਾਸ਼ਟਰੀ ਝੰਡੇ';

  @override
  String get stylePonyCartoon => 'ਕਾਰਟੂਨ';

  @override
  String get stylePonyCartoonDesc => 'ਰੰਗ-ਬਿਰੰਗੀ ਕਾਰਟੂਨ ਤਸਵੀਰ';

  @override
  String get styleStorybook => 'ਕਹਾਣੀਆਂ ਦੀ ਕਿਤਾਬ';

  @override
  String get styleStorybookDesc => 'ਨਰਮ ਕਿਤਾਬੀ ਚਿੱਤਰ';

  @override
  String get stylePonyWatercolor => 'ਜਲ-ਰੰਗ – ਨਰਮ';

  @override
  String get stylePonyWatercolorDesc => 'ਨਰਮ ਜਲ-ਰੰਗ ਚਿੱਤਰਕਾਰੀ';

  @override
  String get stylePonyOil => 'ਤੇਲ ਚਿੱਤਰ';

  @override
  String get stylePonyOilDesc => 'ਕੈਨਵਸ \'ਤੇ ਮੋਟੀਆਂ ਬੁਰਸ਼ ਲਕੀਰਾਂ';

  @override
  String get styleIllustriousOil => 'ਤੇਲ – ਇੰਪਾਸਟੋ';

  @override
  String get styleIllustriousOilDesc => 'ਗਾੜ੍ਹਾ ਇੰਪਾਸਟੋ ਰੰਗ, ਚਾਨਣ-ਛਾਂ';

  @override
  String get styleAnime => 'ਐਨੀਮੇ';

  @override
  String get styleAnimeDesc => 'ਜਾਪਾਨੀ ਐਨੀਮੇ ਡਰਾਇੰਗ';

  @override
  String get styleFlat => 'ਫਲੈਟ ਵੈਕਟਰ';

  @override
  String get styleFlatDesc => 'ਸਪਾਟ ਰੰਗ ਅਤੇ ਸਾਫ਼ ਆਕਾਰ';

  @override
  String get styleUkiyoe => 'ਉਕੀਯੋ-ਏ';

  @override
  String get styleUkiyoeDesc => 'ਜਾਪਾਨੀ ਲੱਕੜ ਛਪਾਈ';

  @override
  String get styleMucha => 'ਆਰਟ ਨੂਵੋ (ਮੁਖਾ)';

  @override
  String get styleMuchaDesc => 'ਸੁਨਹਿਰੀ ਛੋਹਾਂ ਨਾਲ ਸਜਾਵਟੀ ਆਰਟ ਨੂਵੋ';

  @override
  String get styleVanGogh => 'ਵੈਨ ਗੋਗ';

  @override
  String get styleVanGoghDesc => 'ਪੋਸਟ-ਇੰਪ੍ਰੈਸ਼ਨਿਸਟ ਘੁੰਮਦੀਆਂ ਲਕੀਰਾਂ';

  @override
  String get langAr => 'ਅਰਬੀ';

  @override
  String get langCs => 'ਚੈੱਕ';

  @override
  String get langDe => 'ਜਰਮਨ';

  @override
  String get langEl => 'ਯੂਨਾਨੀ';

  @override
  String get langEn => 'ਅੰਗਰੇਜ਼ੀ';

  @override
  String get langEs419 => 'ਸਪੇਨੀ';

  @override
  String get langFr => 'ਫ਼ਰਾਂਸੀਸੀ';

  @override
  String get langHe => 'ਹਿਬਰੂ';

  @override
  String get langHi => 'ਹਿੰਦੀ';

  @override
  String get langId => 'ਇੰਡੋਨੇਸ਼ੀਆਈ';

  @override
  String get langJa => 'ਜਾਪਾਨੀ';

  @override
  String get langKo => 'ਕੋਰੀਆਈ';

  @override
  String get langPtBR => 'ਪੁਰਤਗਾਲੀ';

  @override
  String get langRu => 'ਰੂਸੀ';

  @override
  String get langTr => 'ਤੁਰਕੀ';

  @override
  String get langVi => 'ਵੀਅਤਨਾਮੀ';

  @override
  String get langZhCN => 'ਚੀਨੀ';
}
