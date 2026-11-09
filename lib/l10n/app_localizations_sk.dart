// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Obchod s balíčkami';

  @override
  String get homeEmptyTitle => 'Zatiaľ žiadne balíčky';

  @override
  String get homeReorderHint => 'Podrž balíček a presuň ho inam';

  @override
  String get homeBrowseStore => 'Otvoriť obchod';

  @override
  String get homeDownloadingDecks => 'Pripravujem tvoje balíčky…';

  @override
  String get badgeFree => 'Zadarmo';

  @override
  String get badgeUnlocked => 'Odomknuté';

  @override
  String get badgePurchased => 'Zakúpené';

  @override
  String get badgePaidDeck => 'Platený balíček';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kariet',
      many: '$count karty',
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
      other: '$cards kariet',
      many: '$cards karty',
      few: '$cards karty',
      one: '1 karta',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs jazykov',
      many: '$langs jazyka',
      few: '$langs jazyky',
      one: '1 jazyk',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return 'Viem: $count';
  }

  @override
  String legendLearning(int count) {
    return 'Učím sa: $count';
  }

  @override
  String legendUnknown(int count) {
    return 'Neviem: $count';
  }

  @override
  String get storeTitle => 'Obchod s balíčkami';

  @override
  String get storeRestorePurchases => 'Obnoviť nákupy';

  @override
  String get storeSearchHint => 'Hľadať balíčky…';

  @override
  String storeLoadError(String error) {
    return 'Balíčky sa nepodarilo načítať: $error';
  }

  @override
  String get storeNoDecks => 'Nie sú dostupné žiadne balíčky.';

  @override
  String get storeNothingFound => 'Nič sa nenašlo.';

  @override
  String get retry => 'Skúsiť znova';

  @override
  String get buy => 'Kúpiť';

  @override
  String buyFor(String price) {
    return 'Kúpiť za $price';
  }

  @override
  String get add => 'Pridať';

  @override
  String get addFree => 'Pridať zadarmo';

  @override
  String get back => 'Späť';

  @override
  String get previous => 'Predchádzajúca';

  @override
  String get next => 'Ďalej';

  @override
  String get study => 'Učiť sa';

  @override
  String get download => 'Stiahnuť';

  @override
  String get confirmLanguagesLabel => 'Jazyky';

  @override
  String get styleSectionTitle => 'Štýl obrázkov';

  @override
  String get confirmBuyNote =>
      'Nákup odomkne celý balíček — všetky jazyky a všetky štýly. Táto kombinácia sa pridá na tvoju domovskú obrazovku.';

  @override
  String get confirmAddNote =>
      'Táto kombinácia sa pridá na tvoju domovskú obrazovku. Iný jazyk alebo štýl môžeš pridať kedykoľvek.';

  @override
  String get purchaseFailedToStart => 'Nákup sa nepodarilo spustiť.';

  @override
  String get addedToHome => 'Pridané na domovskú obrazovku.';

  @override
  String get downloadFailed => 'Sťahovanie zlyhalo. Skús to znova.';

  @override
  String get deckNotPurchased => 'Tento balíček nie je zakúpený.';

  @override
  String downloading(int percent) {
    return 'Sťahujem… $percent %';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktívnych',
      many: '$count aktívnej',
      few: '$count aktívne',
      one: '1 aktívna',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Viem';

  @override
  String get pickerLearning => 'Učím sa';

  @override
  String get reportIssue => 'Nahlásiť problém';

  @override
  String get issueTranslation => 'Preklad';

  @override
  String get issueImage => 'Obrázok';

  @override
  String get issuePronunciation => 'Výslovnosť';

  @override
  String get issueMeaning => 'Význam / fakty';

  @override
  String get issueOther => 'Iné';

  @override
  String get feedbackCommentHint => 'Čo je zle? (nepovinné)';

  @override
  String get feedbackSend => 'Poslať e-mailom';

  @override
  String feedbackNoMailApp(String email) {
    return 'Nie je k dispozícii žiadna e-mailová aplikácia. Hlásenie sa skopírovalo do schránky — pošli ho na $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Problém s kartou $key ($slug)';
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
    return 'Zobrazené: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Štýl: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Typ problému: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'Komu: $email';
  }

  @override
  String get pronounce => 'Vysloviť';

  @override
  String get installVoice => 'Nainštalovať hlas';

  @override
  String noVoiceInstalled(String lang) {
    return 'Pre „$lang“ nie je nainštalovaný žiadny hlas. Pridaj ho v Nastaveniach → Prístupnosť → Hovorený obsah → Hlasy a skús to znova.';
  }

  @override
  String get playPronunciation => 'Prehrať výslovnosť';

  @override
  String get swipeNext => 'ĎALEJ';

  @override
  String get swipeBack => 'SPÄŤ';

  @override
  String get showTranslation => 'Zobraziť preklad';

  @override
  String get showOriginal => 'Zobraziť originál';

  @override
  String get noCards => 'Žiadne karty';

  @override
  String get deckHasNoCards => 'Tento balíček nemá žiadne karty.';

  @override
  String get flashcards => 'Kartičky';

  @override
  String get stylePhoto => 'Fotografia';

  @override
  String get stylePhotoDesc => 'Ostrá fotografia, najbližšie realite';

  @override
  String get styleInk => 'Štetec a tuš';

  @override
  String get styleInkDesc => 'Ťahy štetcom, holý papier, jeden farebný akcent';

  @override
  String get stylePastel => 'Pastel';

  @override
  String get stylePastelDesc => 'Suchý pastel na tónovanom papieri';

  @override
  String get styleWatercolor => 'Akvarel';

  @override
  String get styleWatercolorDesc => 'Rozpíjané farby, presvitajúci papier';

  @override
  String get styleFlag => 'Vlajky';

  @override
  String get styleFlagDesc => 'Skutočné štátne vlajky';

  @override
  String get stylePonyCartoon => 'Kreslený';

  @override
  String get stylePonyCartoonDesc => 'Farebná kreslená ilustrácia';

  @override
  String get styleStorybook => 'Rozprávková kniha';

  @override
  String get styleStorybookDesc => 'Jemná knižná ilustrácia';

  @override
  String get stylePonyWatercolor => 'Akvarel – jemný';

  @override
  String get stylePonyWatercolorDesc => 'Jemná akvarelová maľba';

  @override
  String get stylePonyOil => 'Olejomaľba';

  @override
  String get stylePonyOilDesc => 'Husté ťahy štetcom na plátne';

  @override
  String get styleIllustriousOil => 'Olej – impasto';

  @override
  String get styleIllustriousOilDesc => 'Hrubá impastová farba, šerosvit';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Japonská anime kresba';

  @override
  String get styleFlat => 'Plochá grafika';

  @override
  String get styleFlatDesc => 'Ploché farby a čisté tvary';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Japonský drevorez';

  @override
  String get styleMucha => 'Secesia (Mucha)';

  @override
  String get styleMuchaDesc => 'Ornamentálna secesia so zlatými akcentmi';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc => 'Postimpresionistické vírivé ťahy';

  @override
  String get langAr => 'Arabčina';

  @override
  String get langCs => 'Čeština';

  @override
  String get langDe => 'Nemčina';

  @override
  String get langEl => 'Gréčtina';

  @override
  String get langEn => 'Angličtina';

  @override
  String get langEs419 => 'Španielčina';

  @override
  String get langFr => 'Francúzština';

  @override
  String get langHe => 'Hebrejčina';

  @override
  String get langHi => 'Hindčina';

  @override
  String get langId => 'Indonézština';

  @override
  String get langJa => 'Japončina';

  @override
  String get langKo => 'Kórejčina';

  @override
  String get langPtBR => 'Portugalčina';

  @override
  String get langRu => 'Ruština';

  @override
  String get langTr => 'Turečtina';

  @override
  String get langVi => 'Vietnamčina';

  @override
  String get langZhCN => 'Čínština';
}
