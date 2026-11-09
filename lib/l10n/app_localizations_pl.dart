// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Sklep z taliami';

  @override
  String get homeEmptyTitle => 'Nie masz jeszcze talii';

  @override
  String get homeReorderHint =>
      'Przytrzymaj talię i przeciągnij, aby zmienić kolejność';

  @override
  String get homeBrowseStore => 'Przeglądaj sklep z taliami';

  @override
  String get homeDownloadingDecks => 'Przygotowujemy Twoje talie…';

  @override
  String get badgeFree => 'Za darmo';

  @override
  String get badgeUnlocked => 'Odblokowana';

  @override
  String get badgePurchased => 'Kupiona';

  @override
  String get badgePaidDeck => 'Płatna talia';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count karty',
      many: '$count kart',
      few: '$count karty',
      one: '1 karta',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards karty',
      many: '$cards kart',
      few: '$cards karty',
      one: '1 karta',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs języka',
      many: '$langs języków',
      few: '$langs języki',
      one: '1 język',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return 'Znane: $count';
  }

  @override
  String legendLearning(int count) {
    return 'W nauce: $count';
  }

  @override
  String legendUnknown(int count) {
    return 'Nieznane: $count';
  }

  @override
  String get storeTitle => 'Sklep z taliami';

  @override
  String get storeRestorePurchases => 'Przywróć zakupy';

  @override
  String get storeSearchHint => 'Szukaj talii…';

  @override
  String storeLoadError(String error) {
    return 'Nie udało się wczytać talii: $error';
  }

  @override
  String get storeNoDecks => 'Brak dostępnych talii.';

  @override
  String get storeNothingFound => 'Nic nie znaleziono.';

  @override
  String get retry => 'Spróbuj ponownie';

  @override
  String get buy => 'Kup';

  @override
  String buyFor(String price) {
    return 'Kup za $price';
  }

  @override
  String get add => 'Dodaj';

  @override
  String get addFree => 'Dodaj za darmo';

  @override
  String get back => 'Wstecz';

  @override
  String get previous => 'Poprzednia';

  @override
  String get next => 'Dalej';

  @override
  String get study => 'Ucz się';

  @override
  String get download => 'Pobierz';

  @override
  String get confirmLanguagesLabel => 'Języki';

  @override
  String get styleSectionTitle => 'Styl obrazków';

  @override
  String get confirmBuyNote =>
      'Zakup odblokowuje całą talię — wszystkie języki i wszystkie style. To połączenie zostanie dodane do ekranu głównego.';

  @override
  String get confirmAddNote =>
      'To połączenie zostanie dodane do ekranu głównego. W każdej chwili możesz dodać inny język lub styl.';

  @override
  String get purchaseFailedToStart => 'Nie udało się rozpocząć zakupu.';

  @override
  String get addedToHome => 'Dodano do ekranu głównego.';

  @override
  String get downloadFailed => 'Pobieranie nie powiodło się. Spróbuj ponownie.';

  @override
  String get deckNotPurchased => 'Ta talia nie została kupiona.';

  @override
  String downloading(int percent) {
    return 'Pobieranie… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktywnej',
      many: '$count aktywnych',
      few: '$count aktywne',
      one: '1 aktywna',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Znam';

  @override
  String get pickerLearning => 'Uczę się';

  @override
  String get reportIssue => 'Zgłoś problem';

  @override
  String get issueTranslation => 'Tłumaczenie';

  @override
  String get issueImage => 'Obrazek';

  @override
  String get issuePronunciation => 'Wymowa';

  @override
  String get issueMeaning => 'Znaczenie / fakty';

  @override
  String get issueOther => 'Inne';

  @override
  String get feedbackCommentHint => 'Co jest nie tak? (opcjonalnie)';

  @override
  String get feedbackSend => 'Wyślij e-mailem';

  @override
  String feedbackNoMailApp(String email) {
    return 'Brak aplikacji pocztowej. Zgłoszenie skopiowano do schowka — wyślij je na adres $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Problem z kartą $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Talia: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Karta: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Języki: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Wyświetlono: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Styl: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Rodzaj problemu: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'Do: $email';
  }

  @override
  String get pronounce => 'Wymów';

  @override
  String get installVoice => 'Zainstaluj głos';

  @override
  String noVoiceInstalled(String lang) {
    return 'Nie zainstalowano głosu dla „$lang”. Dodaj go w Ustawieniach → Dostępność → Treść mówiona → Głosy i spróbuj ponownie.';
  }

  @override
  String get playPronunciation => 'Odtwórz wymowę';

  @override
  String get swipeNext => 'DALEJ';

  @override
  String get swipeBack => 'WSTECZ';

  @override
  String get showTranslation => 'Pokaż tłumaczenie';

  @override
  String get showOriginal => 'Pokaż oryginał';

  @override
  String get noCards => 'Brak kart';

  @override
  String get deckHasNoCards => 'Ta talia nie ma kart.';

  @override
  String get flashcards => 'Fiszki';

  @override
  String get stylePhoto => 'Zdjęcie';

  @override
  String get stylePhotoDesc => 'Ostre zdjęcie, najbliżej rzeczywistości';

  @override
  String get styleInk => 'Pędzel i tusz';

  @override
  String get styleInkDesc =>
      'Pociągnięcia pędzla, czysty papier, jeden kolorowy akcent';

  @override
  String get stylePastel => 'Pastel';

  @override
  String get stylePastelDesc => 'Suchy pastel na barwionym papierze';

  @override
  String get styleWatercolor => 'Akwarela';

  @override
  String get styleWatercolorDesc =>
      'Rozlewające się plamy, prześwitujący papier';

  @override
  String get styleFlag => 'Flagi';

  @override
  String get styleFlagDesc => 'Prawdziwe flagi państwowe';

  @override
  String get stylePonyCartoon => 'Kreskówka';

  @override
  String get stylePonyCartoonDesc => 'Kolorowa ilustracja kreskówkowa';

  @override
  String get styleStorybook => 'Bajka';

  @override
  String get styleStorybookDesc => 'Miękka ilustracja książkowa';

  @override
  String get stylePonyWatercolor => 'Akwarela – miękka';

  @override
  String get stylePonyWatercolorDesc => 'Delikatny obraz akwarelowy';

  @override
  String get stylePonyOil => 'Obraz olejny';

  @override
  String get stylePonyOilDesc => 'Grube pociągnięcia pędzla na płótnie';

  @override
  String get styleIllustriousOil => 'Olej – impast';

  @override
  String get styleIllustriousOilDesc => 'Gęsta farba impastowa, światłocień';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Japoński rysunek anime';

  @override
  String get styleFlat => 'Płaska grafika';

  @override
  String get styleFlatDesc => 'Płaskie kolory i czyste kształty';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Japoński drzeworyt';

  @override
  String get styleMucha => 'Secesja (Mucha)';

  @override
  String get styleMuchaDesc => 'Ornamentalna secesja ze złotymi akcentami';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc => 'Postimpresjonistyczne wirujące pociągnięcia';

  @override
  String get langAr => 'Arabski';

  @override
  String get langCs => 'Czeski';

  @override
  String get langDe => 'Niemiecki';

  @override
  String get langEl => 'Grecki';

  @override
  String get langEn => 'Angielski';

  @override
  String get langEs419 => 'Hiszpański';

  @override
  String get langFr => 'Francuski';

  @override
  String get langHe => 'Hebrajski';

  @override
  String get langHi => 'Hindi';

  @override
  String get langId => 'Indonezyjski';

  @override
  String get langJa => 'Japoński';

  @override
  String get langKo => 'Koreański';

  @override
  String get langPtBR => 'Portugalski';

  @override
  String get langRu => 'Rosyjski';

  @override
  String get langTr => 'Turecki';

  @override
  String get langVi => 'Wietnamski';

  @override
  String get langZhCN => 'Chiński';
}
