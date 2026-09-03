import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Lexify'**
  String get appTitle;

  /// No description provided for @homeStoreTooltip.
  ///
  /// In en, this message translates to:
  /// **'Deck Store'**
  String get homeStoreTooltip;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No decks yet'**
  String get homeEmptyTitle;

  /// No description provided for @homeBrowseStore.
  ///
  /// In en, this message translates to:
  /// **'Browse the Deck Store'**
  String get homeBrowseStore;

  /// No description provided for @badgeFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get badgeFree;

  /// No description provided for @badgeUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get badgeUnlocked;

  /// No description provided for @badgePurchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get badgePurchased;

  /// No description provided for @badgePaidDeck.
  ///
  /// In en, this message translates to:
  /// **'Paid deck'**
  String get badgePaidDeck;

  /// Home tile subtitle: card count and the language pair as upper-case codes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card} other{{count} cards}} · {l1} → {l2}'**
  String tileCardsAndPair(int count, String l1, String l2);

  /// Store list subtitle.
  ///
  /// In en, this message translates to:
  /// **'{cards, plural, =1{1 card} other{{cards} cards}} · {langs, plural, =1{1 language} other{{langs} languages}}'**
  String tileCardsAndLanguages(int cards, int langs);

  /// No description provided for @legendKnown.
  ///
  /// In en, this message translates to:
  /// **'{count} known'**
  String legendKnown(int count);

  /// No description provided for @legendLearning.
  ///
  /// In en, this message translates to:
  /// **'{count} learning'**
  String legendLearning(int count);

  /// No description provided for @legendUnknown.
  ///
  /// In en, this message translates to:
  /// **'{count} unknown'**
  String legendUnknown(int count);

  /// No description provided for @storeTitle.
  ///
  /// In en, this message translates to:
  /// **'Deck Store'**
  String get storeTitle;

  /// No description provided for @storeRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get storeRestorePurchases;

  /// No description provided for @storeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search decks…'**
  String get storeSearchHint;

  /// No description provided for @storeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load decks: {error}'**
  String storeLoadError(String error);

  /// No description provided for @storeNoDecks.
  ///
  /// In en, this message translates to:
  /// **'No decks available.'**
  String get storeNoDecks;

  /// No description provided for @storeNothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found.'**
  String get storeNothingFound;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @buyFor.
  ///
  /// In en, this message translates to:
  /// **'Buy for {price}'**
  String buyFor(String price);

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addFree.
  ///
  /// In en, this message translates to:
  /// **'Add for free'**
  String get addFree;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @study.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get study;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @confirmLanguagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get confirmLanguagesLabel;

  /// No description provided for @styleSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Image style'**
  String get styleSectionTitle;

  /// No description provided for @confirmBuyNote.
  ///
  /// In en, this message translates to:
  /// **'Buying unlocks the whole deck — every language and every style. This combination will be added to your home screen.'**
  String get confirmBuyNote;

  /// No description provided for @confirmAddNote.
  ///
  /// In en, this message translates to:
  /// **'This combination will be added to your home screen. You can add another language or style at any time.'**
  String get confirmAddNote;

  /// No description provided for @purchaseFailedToStart.
  ///
  /// In en, this message translates to:
  /// **'The purchase could not be started.'**
  String get purchaseFailedToStart;

  /// No description provided for @addedToHome.
  ///
  /// In en, this message translates to:
  /// **'Added to your home screen.'**
  String get addedToHome;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed. Please try again.'**
  String get downloadFailed;

  /// No description provided for @deckNotPurchased.
  ///
  /// In en, this message translates to:
  /// **'This deck has not been purchased.'**
  String get deckNotPurchased;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading… {percent}%'**
  String downloading(int percent);

  /// Badge: how many language/style combinations of this deck are on the home screen.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active} other{{count} active}}'**
  String activeCount(int count);

  /// No description provided for @pickerIKnow.
  ///
  /// In en, this message translates to:
  /// **'I know'**
  String get pickerIKnow;

  /// No description provided for @pickerLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get pickerLearning;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get reportIssue;

  /// No description provided for @issueTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get issueTranslation;

  /// No description provided for @issueImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get issueImage;

  /// No description provided for @issuePronunciation.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation'**
  String get issuePronunciation;

  /// No description provided for @issueMeaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning / facts'**
  String get issueMeaning;

  /// No description provided for @issueOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get issueOther;

  /// No description provided for @feedbackCommentHint.
  ///
  /// In en, this message translates to:
  /// **'What is wrong? (optional)'**
  String get feedbackCommentHint;

  /// No description provided for @feedbackSend.
  ///
  /// In en, this message translates to:
  /// **'Send by e-mail'**
  String get feedbackSend;

  /// No description provided for @feedbackNoMailApp.
  ///
  /// In en, this message translates to:
  /// **'No e-mail app is available. The report was copied to the clipboard — please send it to {email}.'**
  String feedbackNoMailApp(String email);

  /// No description provided for @feedbackSubject.
  ///
  /// In en, this message translates to:
  /// **'[Lexify] Card problem {key} ({slug})'**
  String feedbackSubject(String key, String slug);

  /// No description provided for @feedbackBodyDeck.
  ///
  /// In en, this message translates to:
  /// **'Deck: {slug} v{version} ({title})'**
  String feedbackBodyDeck(String slug, String version, String title);

  /// No description provided for @feedbackBodyCard.
  ///
  /// In en, this message translates to:
  /// **'Card: {key}'**
  String feedbackBodyCard(String key);

  /// No description provided for @feedbackBodyLanguages.
  ///
  /// In en, this message translates to:
  /// **'Languages: {l1} → {l2}'**
  String feedbackBodyLanguages(String l1, String l2);

  /// No description provided for @feedbackBodyShown.
  ///
  /// In en, this message translates to:
  /// **'Shown: {foreign} / {native}'**
  String feedbackBodyShown(String foreign, String native);

  /// No description provided for @feedbackBodyStyle.
  ///
  /// In en, this message translates to:
  /// **'Style: {style}'**
  String feedbackBodyStyle(String style);

  /// No description provided for @feedbackBodyIssue.
  ///
  /// In en, this message translates to:
  /// **'Issue type: {issue}'**
  String feedbackBodyIssue(String issue);

  /// No description provided for @feedbackClipboardTo.
  ///
  /// In en, this message translates to:
  /// **'To: {email}'**
  String feedbackClipboardTo(String email);

  /// No description provided for @pronounce.
  ///
  /// In en, this message translates to:
  /// **'Pronounce'**
  String get pronounce;

  /// No description provided for @installVoice.
  ///
  /// In en, this message translates to:
  /// **'Install voice'**
  String get installVoice;

  /// No description provided for @noVoiceInstalled.
  ///
  /// In en, this message translates to:
  /// **'No voice for \"{lang}\" is installed. Add one in Settings → Accessibility → Spoken Content → Voices, then try again.'**
  String noVoiceInstalled(String lang);

  /// No description provided for @playPronunciation.
  ///
  /// In en, this message translates to:
  /// **'Play pronunciation'**
  String get playPronunciation;

  /// No description provided for @swipeNext.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get swipeNext;

  /// No description provided for @swipeBack.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get swipeBack;

  /// No description provided for @showTranslation.
  ///
  /// In en, this message translates to:
  /// **'Show translation'**
  String get showTranslation;

  /// No description provided for @showOriginal.
  ///
  /// In en, this message translates to:
  /// **'Show original'**
  String get showOriginal;

  /// No description provided for @noCards.
  ///
  /// In en, this message translates to:
  /// **'No cards'**
  String get noCards;

  /// No description provided for @deckHasNoCards.
  ///
  /// In en, this message translates to:
  /// **'This deck has no cards.'**
  String get deckHasNoCards;

  /// No description provided for @flashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get flashcards;

  /// No description provided for @stylePhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get stylePhoto;

  /// No description provided for @stylePhotoDesc.
  ///
  /// In en, this message translates to:
  /// **'Sharp photograph, closest to real life'**
  String get stylePhotoDesc;

  /// No description provided for @styleInk.
  ///
  /// In en, this message translates to:
  /// **'Brush and ink'**
  String get styleInk;

  /// No description provided for @styleInkDesc.
  ///
  /// In en, this message translates to:
  /// **'Brush strokes, bare paper, one colour accent'**
  String get styleInkDesc;

  /// No description provided for @stylePastel.
  ///
  /// In en, this message translates to:
  /// **'Pastel'**
  String get stylePastel;

  /// No description provided for @stylePastelDesc.
  ///
  /// In en, this message translates to:
  /// **'Dry pastel on tinted paper'**
  String get stylePastelDesc;

  /// No description provided for @styleWatercolor.
  ///
  /// In en, this message translates to:
  /// **'Watercolour'**
  String get styleWatercolor;

  /// No description provided for @styleWatercolorDesc.
  ///
  /// In en, this message translates to:
  /// **'Blooming washes, paper showing through'**
  String get styleWatercolorDesc;

  /// No description provided for @stylePonyCartoon.
  ///
  /// In en, this message translates to:
  /// **'Cartoon'**
  String get stylePonyCartoon;

  /// No description provided for @stylePonyCartoonDesc.
  ///
  /// In en, this message translates to:
  /// **'Colourful cartoon illustration'**
  String get stylePonyCartoonDesc;

  /// No description provided for @styleStorybook.
  ///
  /// In en, this message translates to:
  /// **'Storybook'**
  String get styleStorybook;

  /// No description provided for @styleStorybookDesc.
  ///
  /// In en, this message translates to:
  /// **'Soft book illustration'**
  String get styleStorybookDesc;

  /// No description provided for @stylePonyWatercolor.
  ///
  /// In en, this message translates to:
  /// **'Watercolour – soft'**
  String get stylePonyWatercolor;

  /// No description provided for @stylePonyWatercolorDesc.
  ///
  /// In en, this message translates to:
  /// **'Soft watercolour painting'**
  String get stylePonyWatercolorDesc;

  /// No description provided for @stylePonyOil.
  ///
  /// In en, this message translates to:
  /// **'Oil painting'**
  String get stylePonyOil;

  /// No description provided for @stylePonyOilDesc.
  ///
  /// In en, this message translates to:
  /// **'Thick brush strokes on canvas'**
  String get stylePonyOilDesc;

  /// No description provided for @styleIllustriousOil.
  ///
  /// In en, this message translates to:
  /// **'Oil – impasto'**
  String get styleIllustriousOil;

  /// No description provided for @styleIllustriousOilDesc.
  ///
  /// In en, this message translates to:
  /// **'Heavy impasto paint, chiaroscuro'**
  String get styleIllustriousOilDesc;

  /// No description provided for @styleAnime.
  ///
  /// In en, this message translates to:
  /// **'Anime'**
  String get styleAnime;

  /// No description provided for @styleAnimeDesc.
  ///
  /// In en, this message translates to:
  /// **'Japanese anime drawing'**
  String get styleAnimeDesc;

  /// No description provided for @styleFlat.
  ///
  /// In en, this message translates to:
  /// **'Flat vector'**
  String get styleFlat;

  /// No description provided for @styleFlatDesc.
  ///
  /// In en, this message translates to:
  /// **'Flat colours and clean shapes'**
  String get styleFlatDesc;

  /// No description provided for @styleUkiyoe.
  ///
  /// In en, this message translates to:
  /// **'Ukiyo-e'**
  String get styleUkiyoe;

  /// No description provided for @styleUkiyoeDesc.
  ///
  /// In en, this message translates to:
  /// **'Japanese woodblock print'**
  String get styleUkiyoeDesc;

  /// No description provided for @styleMucha.
  ///
  /// In en, this message translates to:
  /// **'Art Nouveau (Mucha)'**
  String get styleMucha;

  /// No description provided for @styleMuchaDesc.
  ///
  /// In en, this message translates to:
  /// **'Ornamental art nouveau with gold accents'**
  String get styleMuchaDesc;

  /// No description provided for @styleVanGogh.
  ///
  /// In en, this message translates to:
  /// **'Van Gogh'**
  String get styleVanGogh;

  /// No description provided for @styleVanGoghDesc.
  ///
  /// In en, this message translates to:
  /// **'Post-impressionist swirling strokes'**
  String get styleVanGoghDesc;

  /// No description provided for @langAr.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get langAr;

  /// No description provided for @langCs.
  ///
  /// In en, this message translates to:
  /// **'Czech'**
  String get langCs;

  /// No description provided for @langDe.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get langDe;

  /// No description provided for @langEl.
  ///
  /// In en, this message translates to:
  /// **'Greek'**
  String get langEl;

  /// No description provided for @langEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEn;

  /// No description provided for @langEs419.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get langEs419;

  /// No description provided for @langFr.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get langFr;

  /// No description provided for @langHe.
  ///
  /// In en, this message translates to:
  /// **'Hebrew'**
  String get langHe;

  /// No description provided for @langHi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get langHi;

  /// No description provided for @langId.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get langId;

  /// No description provided for @langJa.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get langJa;

  /// No description provided for @langKo.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get langKo;

  /// No description provided for @langPtBR.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get langPtBR;

  /// No description provided for @langRu.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get langRu;

  /// No description provided for @langTr.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get langTr;

  /// No description provided for @langVi.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get langVi;

  /// No description provided for @langZhCN.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get langZhCN;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['cs', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
