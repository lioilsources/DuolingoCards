// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Obchod s balíčky';

  @override
  String get homeEmptyTitle => 'Zatím žádné balíčky';

  @override
  String get homeBrowseStore => 'Otevřít obchod';

  @override
  String get badgeFree => 'Zdarma';

  @override
  String get badgeUnlocked => 'Odemčeno';

  @override
  String get badgePurchased => 'Zakoupeno';

  @override
  String get badgePaidDeck => 'Placený balíček';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count karet',
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
      other: '$cards karet',
      few: '$cards karty',
      one: '1 karta',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs jazyků',
      few: '$langs jazyky',
      one: '1 jazyk',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count umím';
  }

  @override
  String legendLearning(int count) {
    return '$count učím se';
  }

  @override
  String legendUnknown(int count) {
    return '$count neznám';
  }

  @override
  String get storeTitle => 'Obchod s balíčky';

  @override
  String get storeRestorePurchases => 'Obnovit nákupy';

  @override
  String get storeSearchHint => 'Hledat balíčky…';

  @override
  String storeLoadError(String error) {
    return 'Balíčky se nepodařilo načíst: $error';
  }

  @override
  String get storeNoDecks => 'Žádné balíčky nejsou k dispozici.';

  @override
  String get storeNothingFound => 'Nic nenalezeno.';

  @override
  String get retry => 'Zkusit znovu';

  @override
  String get buy => 'Koupit';

  @override
  String buyFor(String price) {
    return 'Koupit za $price';
  }

  @override
  String get add => 'Přidat';

  @override
  String get addFree => 'Přidat zdarma';

  @override
  String get back => 'Zpět';

  @override
  String get previous => 'Předchozí';

  @override
  String get next => 'Další';

  @override
  String get study => 'Studovat';

  @override
  String get download => 'Stáhnout';

  @override
  String get confirmLanguagesLabel => 'Jazyky';

  @override
  String get styleSectionTitle => 'Styl obrázků';

  @override
  String get confirmBuyNote =>
      'Nákup odemkne celý balíček — všechny jazyky i styly. Tahle kombinace se přidá na domovskou obrazovku.';

  @override
  String get confirmAddNote =>
      'Tahle kombinace se přidá na domovskou obrazovku. Kdykoli později můžeš přidat další jazyk nebo styl.';

  @override
  String get purchaseFailedToStart => 'Nákup se nepodařilo zahájit.';

  @override
  String get addedToHome => 'Přidáno na domovskou obrazovku.';

  @override
  String get downloadFailed => 'Stahování selhalo. Zkus to znovu.';

  @override
  String get deckNotPurchased => 'Tento balíček není zakoupený.';

  @override
  String downloading(int percent) {
    return 'Stahuji… $percent %';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktivních',
      few: '$count aktivní',
      one: '1 aktivní',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Znám';

  @override
  String get pickerLearning => 'Učím se';

  @override
  String get reportIssue => 'Nahlásit chybu';

  @override
  String get issueTranslation => 'Překlad';

  @override
  String get issueImage => 'Obrázek';

  @override
  String get issuePronunciation => 'Výslovnost';

  @override
  String get issueMeaning => 'Význam / fakta';

  @override
  String get issueOther => 'Jiné';

  @override
  String get feedbackCommentHint => 'Co je špatně? (nepovinné)';

  @override
  String get feedbackSend => 'Odeslat e-mailem';

  @override
  String feedbackNoMailApp(String email) {
    return 'E-mailová aplikace není k dispozici. Hlášení je zkopírované do schránky — pošli ho prosím na $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Chyba na kartě $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Balíček: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Karta: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Jazyky: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Zobrazeno: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Styl: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Typ chyby: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'Komu: $email';
  }

  @override
  String get pronounce => 'Vyslovit';

  @override
  String get installVoice => 'Nainstalovat hlas';

  @override
  String noVoiceInstalled(String lang) {
    return 'Hlas pro „$lang“ není nainstalovaný. Přidej ho v Nastavení → Zpřístupnění → Předčítaný obsah → Hlasy a zkus to znovu.';
  }

  @override
  String get playPronunciation => 'Přehrát výslovnost';

  @override
  String get swipeNext => 'DALŠÍ';

  @override
  String get swipeBack => 'ZPĚT';

  @override
  String get showTranslation => 'Zobrazit překlad';

  @override
  String get showOriginal => 'Zobrazit originál';

  @override
  String get noCards => 'Žádné karty';

  @override
  String get deckHasNoCards => 'Tento balíček nemá žádné karty.';

  @override
  String get flashcards => 'Kartičky';

  @override
  String get stylePhoto => 'Fotografie';

  @override
  String get stylePhotoDesc => 'Ostrá fotografie, nejblíž skutečnosti';

  @override
  String get styleInk => 'Štětec a tuš';

  @override
  String get styleInkDesc => 'Tahy štětcem, prázdný papír, barevný akcent';

  @override
  String get stylePastel => 'Pastel';

  @override
  String get stylePastelDesc => 'Suchý pastel na tónovaném papíře';

  @override
  String get styleWatercolor => 'Akvarel';

  @override
  String get styleWatercolorDesc => 'Rozpité lazury, prosvítající papír';

  @override
  String get stylePonyCartoon => 'Kreslený';

  @override
  String get stylePonyCartoonDesc => 'Barevná kreslená ilustrace';

  @override
  String get styleStorybook => 'Pohádková kniha';

  @override
  String get styleStorybookDesc => 'Jemná knižní ilustrace';

  @override
  String get stylePonyWatercolor => 'Akvarel – měkký';

  @override
  String get stylePonyWatercolorDesc => 'Měkká malba vodovkami';

  @override
  String get stylePonyOil => 'Olejomalba';

  @override
  String get stylePonyOilDesc => 'Hutné tahy štětcem na plátně';

  @override
  String get styleIllustriousOil => 'Olej – impasto';

  @override
  String get styleIllustriousOilDesc => 'Nanesená pastózní barva, šerosvit';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Japonská anime kresba';

  @override
  String get styleFlat => 'Plochý vektor';

  @override
  String get styleFlatDesc => 'Ploché barvy a čisté tvary';

  @override
  String get styleUkiyoe => 'Ukijo-e';

  @override
  String get styleUkiyoeDesc => 'Japonský dřevoryt';

  @override
  String get styleMucha => 'Secese (Mucha)';

  @override
  String get styleMuchaDesc => 'Ornamentální art nouveau se zlatými akcenty';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc => 'Postimpresionistické vířivé tahy';

  @override
  String get langAr => 'Arabština';

  @override
  String get langCs => 'Čeština';

  @override
  String get langDe => 'Němčina';

  @override
  String get langEl => 'Řečtina';

  @override
  String get langEn => 'Angličtina';

  @override
  String get langEs419 => 'Španělština';

  @override
  String get langFr => 'Francouzština';

  @override
  String get langHe => 'Hebrejština';

  @override
  String get langHi => 'Hindština';

  @override
  String get langId => 'Indonéština';

  @override
  String get langJa => 'Japonština';

  @override
  String get langKo => 'Korejština';

  @override
  String get langPtBR => 'Portugalština';

  @override
  String get langRu => 'Ruština';

  @override
  String get langTr => 'Turečtina';

  @override
  String get langVi => 'Vietnamština';

  @override
  String get langZhCN => 'Čínština';
}
