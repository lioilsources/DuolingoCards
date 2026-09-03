// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Deck Store';

  @override
  String get homeEmptyTitle => 'No decks yet';

  @override
  String get homeBrowseStore => 'Browse the Deck Store';

  @override
  String get badgeFree => 'Free';

  @override
  String get badgeUnlocked => 'Unlocked';

  @override
  String get badgePurchased => 'Purchased';

  @override
  String get badgePaidDeck => 'Paid deck';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards cards',
      one: '1 card',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs languages',
      one: '1 language',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count known';
  }

  @override
  String legendLearning(int count) {
    return '$count learning';
  }

  @override
  String legendUnknown(int count) {
    return '$count unknown';
  }

  @override
  String get storeTitle => 'Deck Store';

  @override
  String get storeRestorePurchases => 'Restore Purchases';

  @override
  String get storeSearchHint => 'Search decks…';

  @override
  String storeLoadError(String error) {
    return 'Could not load decks: $error';
  }

  @override
  String get storeNoDecks => 'No decks available.';

  @override
  String get storeNothingFound => 'Nothing found.';

  @override
  String get retry => 'Retry';

  @override
  String get buy => 'Buy';

  @override
  String buyFor(String price) {
    return 'Buy for $price';
  }

  @override
  String get add => 'Add';

  @override
  String get addFree => 'Add for free';

  @override
  String get back => 'Back';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get study => 'Study';

  @override
  String get download => 'Download';

  @override
  String get confirmLanguagesLabel => 'Languages';

  @override
  String get styleSectionTitle => 'Image style';

  @override
  String get confirmBuyNote =>
      'Buying unlocks the whole deck — every language and every style. This combination will be added to your home screen.';

  @override
  String get confirmAddNote =>
      'This combination will be added to your home screen. You can add another language or style at any time.';

  @override
  String get purchaseFailedToStart => 'The purchase could not be started.';

  @override
  String get addedToHome => 'Added to your home screen.';

  @override
  String get downloadFailed => 'Download failed. Please try again.';

  @override
  String get deckNotPurchased => 'This deck has not been purchased.';

  @override
  String downloading(int percent) {
    return 'Downloading… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active',
      one: '1 active',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'I know';

  @override
  String get pickerLearning => 'Learning';

  @override
  String get reportIssue => 'Report a problem';

  @override
  String get issueTranslation => 'Translation';

  @override
  String get issueImage => 'Image';

  @override
  String get issuePronunciation => 'Pronunciation';

  @override
  String get issueMeaning => 'Meaning / facts';

  @override
  String get issueOther => 'Other';

  @override
  String get feedbackCommentHint => 'What is wrong? (optional)';

  @override
  String get feedbackSend => 'Send by e-mail';

  @override
  String feedbackNoMailApp(String email) {
    return 'No e-mail app is available. The report was copied to the clipboard — please send it to $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Card problem $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Deck: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Card: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Languages: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Shown: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Style: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Issue type: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'To: $email';
  }

  @override
  String get pronounce => 'Pronounce';

  @override
  String get installVoice => 'Install voice';

  @override
  String noVoiceInstalled(String lang) {
    return 'No voice for \"$lang\" is installed. Add one in Settings → Accessibility → Spoken Content → Voices, then try again.';
  }

  @override
  String get playPronunciation => 'Play pronunciation';

  @override
  String get swipeNext => 'NEXT';

  @override
  String get swipeBack => 'BACK';

  @override
  String get showTranslation => 'Show translation';

  @override
  String get showOriginal => 'Show original';

  @override
  String get noCards => 'No cards';

  @override
  String get deckHasNoCards => 'This deck has no cards.';

  @override
  String get flashcards => 'Flashcards';

  @override
  String get stylePhoto => 'Photo';

  @override
  String get stylePhotoDesc => 'Sharp photograph, closest to real life';

  @override
  String get styleInk => 'Brush and ink';

  @override
  String get styleInkDesc => 'Brush strokes, bare paper, one colour accent';

  @override
  String get stylePastel => 'Pastel';

  @override
  String get stylePastelDesc => 'Dry pastel on tinted paper';

  @override
  String get styleWatercolor => 'Watercolour';

  @override
  String get styleWatercolorDesc => 'Blooming washes, paper showing through';

  @override
  String get stylePonyCartoon => 'Cartoon';

  @override
  String get stylePonyCartoonDesc => 'Colourful cartoon illustration';

  @override
  String get styleStorybook => 'Storybook';

  @override
  String get styleStorybookDesc => 'Soft book illustration';

  @override
  String get stylePonyWatercolor => 'Watercolour – soft';

  @override
  String get stylePonyWatercolorDesc => 'Soft watercolour painting';

  @override
  String get stylePonyOil => 'Oil painting';

  @override
  String get stylePonyOilDesc => 'Thick brush strokes on canvas';

  @override
  String get styleIllustriousOil => 'Oil – impasto';

  @override
  String get styleIllustriousOilDesc => 'Heavy impasto paint, chiaroscuro';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Japanese anime drawing';

  @override
  String get styleFlat => 'Flat vector';

  @override
  String get styleFlatDesc => 'Flat colours and clean shapes';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Japanese woodblock print';

  @override
  String get styleMucha => 'Art Nouveau (Mucha)';

  @override
  String get styleMuchaDesc => 'Ornamental art nouveau with gold accents';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc => 'Post-impressionist swirling strokes';

  @override
  String get langAr => 'Arabic';

  @override
  String get langCs => 'Czech';

  @override
  String get langDe => 'German';

  @override
  String get langEl => 'Greek';

  @override
  String get langEn => 'English';

  @override
  String get langEs419 => 'Spanish';

  @override
  String get langFr => 'French';

  @override
  String get langHe => 'Hebrew';

  @override
  String get langHi => 'Hindi';

  @override
  String get langId => 'Indonesian';

  @override
  String get langJa => 'Japanese';

  @override
  String get langKo => 'Korean';

  @override
  String get langPtBR => 'Portuguese';

  @override
  String get langRu => 'Russian';

  @override
  String get langTr => 'Turkish';

  @override
  String get langVi => 'Vietnamese';

  @override
  String get langZhCN => 'Chinese';
}
