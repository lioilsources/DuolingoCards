// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Deck-Shop';

  @override
  String get homeEmptyTitle => 'Noch keine Decks';

  @override
  String get homeReorderHint =>
      'Halte ein Deck gedrückt und ziehe es, um die Reihenfolge zu ändern';

  @override
  String get homeBrowseStore => 'Zum Deck-Shop';

  @override
  String get homeDownloadingDecks => 'Deine Decks werden vorbereitet…';

  @override
  String get badgeFree => 'Gratis';

  @override
  String get badgeUnlocked => 'Freigeschaltet';

  @override
  String get badgePurchased => 'Gekauft';

  @override
  String get badgePaidDeck => 'Kostenpflichtiges Deck';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Karten',
      one: '1 Karte',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards Karten',
      one: '1 Karte',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs Sprachen',
      one: '1 Sprache',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count gewusst';
  }

  @override
  String legendLearning(int count) {
    return '$count am Lernen';
  }

  @override
  String legendUnknown(int count) {
    return '$count unbekannt';
  }

  @override
  String get storeTitle => 'Deck-Shop';

  @override
  String get storeRestorePurchases => 'Käufe wiederherstellen';

  @override
  String get storeSearchHint => 'Decks suchen…';

  @override
  String storeLoadError(String error) {
    return 'Decks konnten nicht geladen werden: $error';
  }

  @override
  String get storeNoDecks => 'Keine Decks verfügbar.';

  @override
  String get storeNothingFound => 'Nichts gefunden.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get buy => 'Kaufen';

  @override
  String buyFor(String price) {
    return 'Für $price kaufen';
  }

  @override
  String get add => 'Hinzufügen';

  @override
  String get addFree => 'Gratis hinzufügen';

  @override
  String get back => 'Zurück';

  @override
  String get previous => 'Zurück';

  @override
  String get next => 'Weiter';

  @override
  String get study => 'Lernen';

  @override
  String get download => 'Laden';

  @override
  String get confirmLanguagesLabel => 'Sprachen';

  @override
  String get styleSectionTitle => 'Bildstil';

  @override
  String get confirmBuyNote =>
      'Mit dem Kauf schaltest du das ganze Deck frei – alle Sprachen und alle Stile. Diese Kombination wird zu deinem Startbildschirm hinzugefügt.';

  @override
  String get confirmAddNote =>
      'Diese Kombination wird zu deinem Startbildschirm hinzugefügt. Du kannst jederzeit eine weitere Sprache oder einen weiteren Stil hinzufügen.';

  @override
  String get purchaseFailedToStart => 'Der Kauf konnte nicht gestartet werden.';

  @override
  String get addedToHome => 'Zum Startbildschirm hinzugefügt.';

  @override
  String get downloadFailed =>
      'Download fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get deckNotPurchased => 'Dieses Deck wurde noch nicht gekauft.';

  @override
  String downloading(int percent) {
    return 'Wird geladen… $percent %';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktiv',
      one: '1 aktiv',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Kann ich';

  @override
  String get pickerLearning => 'Am Lernen';

  @override
  String get reportIssue => 'Problem melden';

  @override
  String get issueTranslation => 'Übersetzung';

  @override
  String get issueImage => 'Bild';

  @override
  String get issuePronunciation => 'Aussprache';

  @override
  String get issueMeaning => 'Bedeutung / Fakten';

  @override
  String get issueOther => 'Sonstiges';

  @override
  String get feedbackCommentHint => 'Was stimmt nicht? (optional)';

  @override
  String get feedbackSend => 'Per E-Mail senden';

  @override
  String feedbackNoMailApp(String email) {
    return 'Keine E-Mail-App verfügbar. Die Meldung wurde in die Zwischenablage kopiert – bitte sende sie an $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Problem mit Karte $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Deck: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Karte: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Sprachen: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Angezeigt: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Stil: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Art des Problems: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'An: $email';
  }

  @override
  String get pronounce => 'Aussprechen';

  @override
  String get installVoice => 'Stimme installieren';

  @override
  String noVoiceInstalled(String lang) {
    return 'Für „$lang“ ist keine Stimme installiert. Füge eine unter Einstellungen → Bedienungshilfen → Gesprochene Inhalte → Stimmen hinzu und versuche es dann erneut.';
  }

  @override
  String get playPronunciation => 'Aussprache abspielen';

  @override
  String get swipeNext => 'WEITER';

  @override
  String get swipeBack => 'ZURÜCK';

  @override
  String get showTranslation => 'Übersetzung zeigen';

  @override
  String get showOriginal => 'Original zeigen';

  @override
  String get noCards => 'Keine Karten';

  @override
  String get deckHasNoCards => 'Dieses Deck hat keine Karten.';

  @override
  String get flashcards => 'Karteikarten';

  @override
  String get stylePhoto => 'Foto';

  @override
  String get stylePhotoDesc => 'Scharfes Foto, ganz nah an der Wirklichkeit';

  @override
  String get styleInk => 'Pinsel und Tusche';

  @override
  String get styleInkDesc => 'Pinselstriche, blankes Papier, ein Farbakzent';

  @override
  String get stylePastel => 'Pastell';

  @override
  String get stylePastelDesc => 'Trockenpastell auf getöntem Papier';

  @override
  String get styleWatercolor => 'Aquarell';

  @override
  String get styleWatercolorDesc =>
      'Fließende Farbflächen, durchscheinendes Papier';

  @override
  String get styleFlag => 'Flaggen';

  @override
  String get styleFlagDesc => 'Die echten Nationalflaggen';

  @override
  String get stylePonyCartoon => 'Cartoon';

  @override
  String get stylePonyCartoonDesc => 'Bunte Cartoon-Illustration';

  @override
  String get styleStorybook => 'Bilderbuch';

  @override
  String get styleStorybookDesc => 'Sanfte Buchillustration';

  @override
  String get stylePonyWatercolor => 'Aquarell – sanft';

  @override
  String get stylePonyWatercolorDesc => 'Sanfte Aquarellmalerei';

  @override
  String get stylePonyOil => 'Ölgemälde';

  @override
  String get stylePonyOilDesc => 'Kräftige Pinselstriche auf Leinwand';

  @override
  String get styleIllustriousOil => 'Öl – Impasto';

  @override
  String get styleIllustriousOilDesc => 'Dicker Farbauftrag, Hell-Dunkel';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Japanischer Anime-Zeichenstil';

  @override
  String get styleFlat => 'Flat Design';

  @override
  String get styleFlatDesc => 'Flächige Farben und klare Formen';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Japanischer Farbholzschnitt';

  @override
  String get styleMucha => 'Jugendstil (Mucha)';

  @override
  String get styleMuchaDesc => 'Ornamentaler Jugendstil mit Goldakzenten';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc =>
      'Postimpressionistische, wirbelnde Pinselstriche';

  @override
  String get langAr => 'Arabisch';

  @override
  String get langCs => 'Tschechisch';

  @override
  String get langDe => 'Deutsch';

  @override
  String get langEl => 'Griechisch';

  @override
  String get langEn => 'Englisch';

  @override
  String get langEs419 => 'Spanisch';

  @override
  String get langFr => 'Französisch';

  @override
  String get langHe => 'Hebräisch';

  @override
  String get langHi => 'Hindi';

  @override
  String get langId => 'Indonesisch';

  @override
  String get langJa => 'Japanisch';

  @override
  String get langKo => 'Koreanisch';

  @override
  String get langPtBR => 'Portugiesisch';

  @override
  String get langRu => 'Russisch';

  @override
  String get langTr => 'Türkisch';

  @override
  String get langVi => 'Vietnamesisch';

  @override
  String get langZhCN => 'Chinesisch';
}
