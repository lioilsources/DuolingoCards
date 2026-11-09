// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'ಡೆಕ್ ಸ್ಟೋರ್';

  @override
  String get homeEmptyTitle => 'ಇನ್ನೂ ಯಾವುದೇ ಡೆಕ್‌ಗಳಿಲ್ಲ';

  @override
  String get homeReorderHint => 'ಕ್ರಮ ಬದಲಿಸಲು ಡೆಕ್ ಅನ್ನು ಒತ್ತಿ ಹಿಡಿದು ಎಳೆಯಿರಿ';

  @override
  String get homeBrowseStore => 'ಡೆಕ್ ಸ್ಟೋರ್ ನೋಡಿ';

  @override
  String get homeDownloadingDecks => 'ನಿಮ್ಮ ಡೆಕ್‌ಗಳನ್ನು ಸಿದ್ಧಪಡಿಸಲಾಗುತ್ತಿದೆ…';

  @override
  String get badgeFree => 'ಉಚಿತ';

  @override
  String get badgeUnlocked => 'ಅನ್‌ಲಾಕ್ ಆಗಿದೆ';

  @override
  String get badgePurchased => 'ಖರೀದಿಸಲಾಗಿದೆ';

  @override
  String get badgePaidDeck => 'ಪಾವತಿಸಿದ ಡೆಕ್';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಕಾರ್ಡ್‌ಗಳು',
      one: '1 ಕಾರ್ಡ್',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards ಕಾರ್ಡ್‌ಗಳು',
      one: '1 ಕಾರ್ಡ್',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs ಭಾಷೆಗಳು',
      one: '1 ಭಾಷೆ',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count ಗೊತ್ತಿರುವವು';
  }

  @override
  String legendLearning(int count) {
    return '$count ಕಲಿಯುತ್ತಿರುವವು';
  }

  @override
  String legendUnknown(int count) {
    return '$count ಗೊತ್ತಿಲ್ಲದವು';
  }

  @override
  String get storeTitle => 'ಡೆಕ್ ಸ್ಟೋರ್';

  @override
  String get storeRestorePurchases => 'ಖರೀದಿಗಳನ್ನು ಮರುಸ್ಥಾಪಿಸಿ';

  @override
  String get storeSearchHint => 'ಡೆಕ್‌ಗಳನ್ನು ಹುಡುಕಿ…';

  @override
  String storeLoadError(String error) {
    return 'ಡೆಕ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲಾಗಲಿಲ್ಲ: $error';
  }

  @override
  String get storeNoDecks => 'ಯಾವುದೇ ಡೆಕ್‌ಗಳು ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String get storeNothingFound => 'ಏನೂ ಸಿಗಲಿಲ್ಲ.';

  @override
  String get retry => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get buy => 'ಖರೀದಿಸಿ';

  @override
  String buyFor(String price) {
    return '$priceಗೆ ಖರೀದಿಸಿ';
  }

  @override
  String get add => 'ಸೇರಿಸಿ';

  @override
  String get addFree => 'ಉಚಿತವಾಗಿ ಸೇರಿಸಿ';

  @override
  String get back => 'ಹಿಂದೆ';

  @override
  String get previous => 'ಹಿಂದಿನದು';

  @override
  String get next => 'ಮುಂದಿನದು';

  @override
  String get study => 'ಕಲಿಯಿರಿ';

  @override
  String get download => 'ಡೌನ್‌ಲೋಡ್';

  @override
  String get confirmLanguagesLabel => 'ಭಾಷೆಗಳು';

  @override
  String get styleSectionTitle => 'ಚಿತ್ರ ಶೈಲಿ';

  @override
  String get confirmBuyNote =>
      'ಖರೀದಿಯಿಂದ ಇಡೀ ಡೆಕ್ ಅನ್‌ಲಾಕ್ ಆಗುತ್ತದೆ — ಎಲ್ಲ ಭಾಷೆಗಳು ಮತ್ತು ಎಲ್ಲ ಶೈಲಿಗಳು. ಈ ಸಂಯೋಜನೆಯನ್ನು ನಿಮ್ಮ ಹೋಮ್ ಸ್ಕ್ರೀನ್‌ಗೆ ಸೇರಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get confirmAddNote =>
      'ಈ ಸಂಯೋಜನೆಯನ್ನು ನಿಮ್ಮ ಹೋಮ್ ಸ್ಕ್ರೀನ್‌ಗೆ ಸೇರಿಸಲಾಗುತ್ತದೆ. ಯಾವಾಗ ಬೇಕಾದರೂ ಬೇರೆ ಭಾಷೆ ಅಥವಾ ಶೈಲಿಯನ್ನು ಸೇರಿಸಬಹುದು.';

  @override
  String get purchaseFailedToStart => 'ಖರೀದಿಯನ್ನು ಪ್ರಾರಂಭಿಸಲಾಗಲಿಲ್ಲ.';

  @override
  String get addedToHome => 'ಹೋಮ್ ಸ್ಕ್ರೀನ್‌ಗೆ ಸೇರಿಸಲಾಗಿದೆ.';

  @override
  String get downloadFailed =>
      'ಡೌನ್‌ಲೋಡ್ ವಿಫಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get deckNotPurchased => 'ಈ ಡೆಕ್ ಅನ್ನು ಖರೀದಿಸಲಾಗಿಲ್ಲ.';

  @override
  String downloading(int percent) {
    return 'ಡೌನ್‌ಲೋಡ್ ಆಗುತ್ತಿದೆ… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಸಕ್ರಿಯ',
      one: '1 ಸಕ್ರಿಯ',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'ಗೊತ್ತಿದೆ';

  @override
  String get pickerLearning => 'ಕಲಿಯುತ್ತಿದ್ದೇನೆ';

  @override
  String get reportIssue => 'ಸಮಸ್ಯೆ ವರದಿ ಮಾಡಿ';

  @override
  String get issueTranslation => 'ಅನುವಾದ';

  @override
  String get issueImage => 'ಚಿತ್ರ';

  @override
  String get issuePronunciation => 'ಉಚ್ಚಾರಣೆ';

  @override
  String get issueMeaning => 'ಅರ್ಥ / ಸತ್ಯಾಂಶಗಳು';

  @override
  String get issueOther => 'ಇತರೆ';

  @override
  String get feedbackCommentHint => 'ಏನು ತಪ್ಪಾಗಿದೆ? (ಐಚ್ಛಿಕ)';

  @override
  String get feedbackSend => 'ಇ-ಮೇಲ್ ಮೂಲಕ ಕಳುಹಿಸಿ';

  @override
  String feedbackNoMailApp(String email) {
    return 'ಯಾವುದೇ ಇ-ಮೇಲ್ ಆ್ಯಪ್ ಲಭ್ಯವಿಲ್ಲ. ವರದಿಯನ್ನು ಕ್ಲಿಪ್‌ಬೋರ್ಡ್‌ಗೆ ನಕಲಿಸಲಾಗಿದೆ — ದಯವಿಟ್ಟು ಅದನ್ನು $emailಗೆ ಕಳುಹಿಸಿ.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] ಕಾರ್ಡ್ ಸಮಸ್ಯೆ $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'ಡೆಕ್: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'ಕಾರ್ಡ್: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'ಭಾಷೆಗಳು: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'ತೋರಿಸಿದ್ದು: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'ಶೈಲಿ: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'ಸಮಸ್ಯೆಯ ಪ್ರಕಾರ: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'ಇವರಿಗೆ: $email';
  }

  @override
  String get pronounce => 'ಉಚ್ಚರಿಸಿ';

  @override
  String get installVoice => 'ಧ್ವನಿ ಸ್ಥಾಪಿಸಿ';

  @override
  String noVoiceInstalled(String lang) {
    return '\"$lang\"ಗಾಗಿ ಯಾವುದೇ ಧ್ವನಿ ಸ್ಥಾಪಿಸಲಾಗಿಲ್ಲ. ಸೆಟ್ಟಿಂಗ್‌ಗಳು → ಪ್ರವೇಶಿಸುವಿಕೆ → ಮಾತನಾಡುವ ವಿಷಯ → ಧ್ವನಿಗಳಲ್ಲಿ ಒಂದನ್ನು ಸೇರಿಸಿ, ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';
  }

  @override
  String get playPronunciation => 'ಉಚ್ಚಾರಣೆ ಕೇಳಿ';

  @override
  String get swipeNext => 'ಮುಂದೆ';

  @override
  String get swipeBack => 'ಹಿಂದೆ';

  @override
  String get showTranslation => 'ಅನುವಾದ ತೋರಿಸಿ';

  @override
  String get showOriginal => 'ಮೂಲ ತೋರಿಸಿ';

  @override
  String get noCards => 'ಕಾರ್ಡ್‌ಗಳಿಲ್ಲ';

  @override
  String get deckHasNoCards => 'ಈ ಡೆಕ್‌ನಲ್ಲಿ ಕಾರ್ಡ್‌ಗಳಿಲ್ಲ.';

  @override
  String get flashcards => 'ಫ್ಲ್ಯಾಶ್‌ಕಾರ್ಡ್‌ಗಳು';

  @override
  String get stylePhoto => 'ಫೋಟೋ';

  @override
  String get stylePhotoDesc => 'ಸ್ಪಷ್ಟ ಛಾಯಾಚಿತ್ರ, ವಾಸ್ತವಕ್ಕೆ ಅತಿ ಹತ್ತಿರ';

  @override
  String get styleInk => 'ಕುಂಚ ಮತ್ತು ಶಾಯಿ';

  @override
  String get styleInkDesc => 'ಕುಂಚದ ಗೆರೆಗಳು, ಖಾಲಿ ಕಾಗದ, ಒಂದು ಬಣ್ಣದ ಸ್ಪರ್ಶ';

  @override
  String get stylePastel => 'ಪ್ಯಾಸ್ಟೆಲ್';

  @override
  String get stylePastelDesc => 'ಬಣ್ಣದ ಕಾಗದದ ಮೇಲೆ ಒಣ ಪ್ಯಾಸ್ಟೆಲ್';

  @override
  String get styleWatercolor => 'ಜಲವರ್ಣ';

  @override
  String get styleWatercolorDesc => 'ಹರಡುವ ಜಲವರ್ಣ, ಕಾಗದ ಕಾಣುತ್ತದೆ';

  @override
  String get styleFlag => 'ಧ್ವಜಗಳು';

  @override
  String get styleFlagDesc => 'ನಿಜವಾದ ರಾಷ್ಟ್ರಧ್ವಜಗಳು';

  @override
  String get stylePonyCartoon => 'ಕಾರ್ಟೂನ್';

  @override
  String get stylePonyCartoonDesc => 'ವರ್ಣರಂಜಿತ ಕಾರ್ಟೂನ್ ಚಿತ್ರ';

  @override
  String get styleStorybook => 'ಕಥೆ ಪುಸ್ತಕ';

  @override
  String get styleStorybookDesc => 'ಮೃದುವಾದ ಪುಸ್ತಕ ಚಿತ್ರ';

  @override
  String get stylePonyWatercolor => 'ಜಲವರ್ಣ – ಮೃದು';

  @override
  String get stylePonyWatercolorDesc => 'ಮೃದುವಾದ ಜಲವರ್ಣ ಚಿತ್ರ';

  @override
  String get stylePonyOil => 'ತೈಲಚಿತ್ರ';

  @override
  String get stylePonyOilDesc => 'ಕ್ಯಾನ್ವಾಸ್ ಮೇಲೆ ದಪ್ಪ ಕುಂಚದ ಗೆರೆಗಳು';

  @override
  String get styleIllustriousOil => 'ತೈಲ – ಇಂಪಾಸ್ಟೊ';

  @override
  String get styleIllustriousOilDesc => 'ದಟ್ಟ ಇಂಪಾಸ್ಟೊ ಬಣ್ಣ, ಬೆಳಕು-ನೆರಳು';

  @override
  String get styleAnime => 'ಅನಿಮೆ';

  @override
  String get styleAnimeDesc => 'ಜಪಾನೀ ಅನಿಮೆ ಚಿತ್ರ';

  @override
  String get styleFlat => 'ಫ್ಲ್ಯಾಟ್ ವೆಕ್ಟರ್';

  @override
  String get styleFlatDesc => 'ಸಮತಟ್ಟಾದ ಬಣ್ಣಗಳು, ಸ್ವಚ್ಛ ಆಕಾರಗಳು';

  @override
  String get styleUkiyoe => 'ಉಕಿಯೋ-ಎ';

  @override
  String get styleUkiyoeDesc => 'ಜಪಾನೀ ಮರದ ಅಚ್ಚು';

  @override
  String get styleMucha => 'ಆರ್ಟ್ ನೂವೋ (ಮುಖಾ)';

  @override
  String get styleMuchaDesc => 'ಚಿನ್ನದ ಸ್ಪರ್ಶದ ಅಲಂಕಾರಿಕ ಆರ್ಟ್ ನೂವೋ';

  @override
  String get styleVanGogh => 'ವ್ಯಾನ್ ಗೋ';

  @override
  String get styleVanGoghDesc => 'ಪೋಸ್ಟ್-ಇಂಪ್ರೆಷನಿಸ್ಟ್ ಸುಳಿಯುವ ಗೆರೆಗಳು';

  @override
  String get langAr => 'ಅರೇಬಿಕ್';

  @override
  String get langCs => 'ಜೆಕ್';

  @override
  String get langDe => 'ಜರ್ಮನ್';

  @override
  String get langEl => 'ಗ್ರೀಕ್';

  @override
  String get langEn => 'ಇಂಗ್ಲಿಷ್';

  @override
  String get langEs419 => 'ಸ್ಪ್ಯಾನಿಷ್';

  @override
  String get langFr => 'ಫ್ರೆಂಚ್';

  @override
  String get langHe => 'ಹೀಬ್ರೂ';

  @override
  String get langHi => 'ಹಿಂದಿ';

  @override
  String get langId => 'ಇಂಡೋನೇಷಿಯನ್';

  @override
  String get langJa => 'ಜಪಾನೀ';

  @override
  String get langKo => 'ಕೊರಿಯನ್';

  @override
  String get langPtBR => 'ಪೋರ್ಚುಗೀಸ್';

  @override
  String get langRu => 'ರಷ್ಯನ್';

  @override
  String get langTr => 'ಟರ್ಕಿಷ್';

  @override
  String get langVi => 'ವಿಯೆಟ್ನಾಮೀಸ್';

  @override
  String get langZhCN => 'ಚೈನೀಸ್';
}
