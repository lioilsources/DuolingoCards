// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Kortleksbutik';

  @override
  String get homeEmptyTitle => 'Inga kortlekar än';

  @override
  String get homeReorderHint =>
      'Håll ned en kortlek och dra den för att ändra ordningen';

  @override
  String get homeBrowseStore => 'Bläddra i kortleksbutiken';

  @override
  String get homeDownloadingDecks => 'Gör i ordning dina kortlekar…';

  @override
  String get badgeFree => 'Gratis';

  @override
  String get badgeUnlocked => 'Upplåst';

  @override
  String get badgePurchased => 'Köpt';

  @override
  String get badgePaidDeck => 'Betald kortlek';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kort',
      one: '1 kort',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards kort',
      one: '1 kort',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs språk',
      one: '1 språk',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count kan';
  }

  @override
  String legendLearning(int count) {
    return '$count lär mig';
  }

  @override
  String legendUnknown(int count) {
    return '$count okända';
  }

  @override
  String get storeTitle => 'Kortleksbutik';

  @override
  String get storeRestorePurchases => 'Återställ köp';

  @override
  String get storeSearchHint => 'Sök kortlekar…';

  @override
  String storeLoadError(String error) {
    return 'Det gick inte att läsa in kortlekarna: $error';
  }

  @override
  String get storeNoDecks => 'Inga kortlekar tillgängliga.';

  @override
  String get storeNothingFound => 'Inget hittades.';

  @override
  String get retry => 'Försök igen';

  @override
  String get buy => 'Köp';

  @override
  String buyFor(String price) {
    return 'Köp för $price';
  }

  @override
  String get add => 'Lägg till';

  @override
  String get addFree => 'Lägg till gratis';

  @override
  String get back => 'Tillbaka';

  @override
  String get previous => 'Föregående';

  @override
  String get next => 'Nästa';

  @override
  String get study => 'Plugga';

  @override
  String get download => 'Hämta';

  @override
  String get confirmLanguagesLabel => 'Språk';

  @override
  String get styleSectionTitle => 'Bildstil';

  @override
  String get confirmBuyNote =>
      'Köpet låser upp hela kortleken — alla språk och alla stilar. Den här kombinationen läggs till på din hemskärm.';

  @override
  String get confirmAddNote =>
      'Den här kombinationen läggs till på din hemskärm. Du kan när som helst lägga till ett annat språk eller en annan stil.';

  @override
  String get purchaseFailedToStart => 'Köpet kunde inte startas.';

  @override
  String get addedToHome => 'Tillagd på hemskärmen.';

  @override
  String get downloadFailed => 'Hämtningen misslyckades. Försök igen.';

  @override
  String get deckNotPurchased => 'Den här kortleken har inte köpts.';

  @override
  String downloading(int percent) {
    return 'Hämtar… $percent %';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktiva',
      one: '1 aktiv',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Kan';

  @override
  String get pickerLearning => 'Lär mig';

  @override
  String get reportIssue => 'Rapportera ett problem';

  @override
  String get issueTranslation => 'Översättning';

  @override
  String get issueImage => 'Bild';

  @override
  String get issuePronunciation => 'Uttal';

  @override
  String get issueMeaning => 'Betydelse / fakta';

  @override
  String get issueOther => 'Annat';

  @override
  String get feedbackCommentHint => 'Vad är fel? (valfritt)';

  @override
  String get feedbackSend => 'Skicka via e-post';

  @override
  String feedbackNoMailApp(String email) {
    return 'Ingen e-postapp finns. Rapporten har kopierats till urklipp — skicka den till $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Problem med kort $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Kortlek: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Kort: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Språk: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Visat: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Stil: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Typ av problem: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'Till: $email';
  }

  @override
  String get pronounce => 'Uttala';

  @override
  String get installVoice => 'Installera röst';

  @override
  String noVoiceInstalled(String lang) {
    return 'Ingen röst för ”$lang” är installerad. Lägg till en under Inställningar → Hjälpmedel → Uppläst innehåll → Röster och försök igen.';
  }

  @override
  String get playPronunciation => 'Spela upp uttal';

  @override
  String get swipeNext => 'NÄSTA';

  @override
  String get swipeBack => 'TILLBAKA';

  @override
  String get showTranslation => 'Visa översättning';

  @override
  String get showOriginal => 'Visa original';

  @override
  String get noCards => 'Inga kort';

  @override
  String get deckHasNoCards => 'Den här kortleken har inga kort.';

  @override
  String get flashcards => 'Glosor';

  @override
  String get stylePhoto => 'Foto';

  @override
  String get stylePhotoDesc => 'Skarpt fotografi, närmast verkligheten';

  @override
  String get styleInk => 'Pensel och tusch';

  @override
  String get styleInkDesc => 'Penseldrag, bart papper, en färgaccent';

  @override
  String get stylePastel => 'Pastell';

  @override
  String get stylePastelDesc => 'Torrpastell på tonat papper';

  @override
  String get styleWatercolor => 'Akvarell';

  @override
  String get styleWatercolorDesc =>
      'Flytande laveringar, papperet lyser igenom';

  @override
  String get styleFlag => 'Flaggor';

  @override
  String get styleFlagDesc => 'De riktiga nationsflaggorna';

  @override
  String get stylePonyCartoon => 'Tecknat';

  @override
  String get stylePonyCartoonDesc => 'Färgglad tecknad illustration';

  @override
  String get styleStorybook => 'Sagobok';

  @override
  String get styleStorybookDesc => 'Mjuk bokillustration';

  @override
  String get stylePonyWatercolor => 'Akvarell – mjuk';

  @override
  String get stylePonyWatercolorDesc => 'Mjuk akvarellmålning';

  @override
  String get stylePonyOil => 'Oljemålning';

  @override
  String get stylePonyOilDesc => 'Tjocka penseldrag på duk';

  @override
  String get styleIllustriousOil => 'Olja – impasto';

  @override
  String get styleIllustriousOilDesc => 'Tjock impastofärg, chiaroscuro';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Japansk animeteckning';

  @override
  String get styleFlat => 'Platt vektor';

  @override
  String get styleFlatDesc => 'Platta färger och rena former';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Japanskt träsnitt';

  @override
  String get styleMucha => 'Jugend (Mucha)';

  @override
  String get styleMuchaDesc => 'Ornamental jugend med guldaccenter';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc => 'Postimpressionistiska virvlande drag';

  @override
  String get langAr => 'Arabiska';

  @override
  String get langCs => 'Tjeckiska';

  @override
  String get langDe => 'Tyska';

  @override
  String get langEl => 'Grekiska';

  @override
  String get langEn => 'Engelska';

  @override
  String get langEs419 => 'Spanska';

  @override
  String get langFr => 'Franska';

  @override
  String get langHe => 'Hebreiska';

  @override
  String get langHi => 'Hindi';

  @override
  String get langId => 'Indonesiska';

  @override
  String get langJa => 'Japanska';

  @override
  String get langKo => 'Koreanska';

  @override
  String get langPtBR => 'Portugisiska';

  @override
  String get langRu => 'Ryska';

  @override
  String get langTr => 'Turkiska';

  @override
  String get langVi => 'Vietnamesiska';

  @override
  String get langZhCN => 'Kinesiska';
}
