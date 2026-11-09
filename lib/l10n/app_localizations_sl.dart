// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovenian (`sl`).
class AppLocalizationsSl extends AppLocalizations {
  AppLocalizationsSl([String locale = 'sl']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Trgovina s kompleti';

  @override
  String get homeEmptyTitle => 'Še ni kompletov';

  @override
  String get homeReorderHint =>
      'Dolgo pritisnite komplet in ga povlecite, da spremenite vrstni red';

  @override
  String get homeBrowseStore => 'Prebrskaj trgovino s kompleti';

  @override
  String get homeDownloadingDecks => 'Pripravljamo vaše komplete …';

  @override
  String get badgeFree => 'Brezplačno';

  @override
  String get badgeUnlocked => 'Odklenjeno';

  @override
  String get badgePurchased => 'Kupljeno';

  @override
  String get badgePaidDeck => 'Plačljiv komplet';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kartic',
      few: '$count kartice',
      two: '$count kartici',
      one: '$count kartica',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards kartic',
      few: '$cards kartice',
      two: '$cards kartici',
      one: '$cards kartica',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs jezikov',
      few: '$langs jeziki',
      two: '$langs jezika',
      one: '$langs jezik',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return 'Znam: $count';
  }

  @override
  String legendLearning(int count) {
    return 'Učim se: $count';
  }

  @override
  String legendUnknown(int count) {
    return 'Ne znam: $count';
  }

  @override
  String get storeTitle => 'Trgovina s kompleti';

  @override
  String get storeRestorePurchases => 'Obnovi nakupe';

  @override
  String get storeSearchHint => 'Išči komplete …';

  @override
  String storeLoadError(String error) {
    return 'Kompletov ni bilo mogoče naložiti: $error';
  }

  @override
  String get storeNoDecks => 'Ni razpoložljivih kompletov.';

  @override
  String get storeNothingFound => 'Ni zadetkov.';

  @override
  String get retry => 'Poskusi znova';

  @override
  String get buy => 'Kupi';

  @override
  String buyFor(String price) {
    return 'Kupi za $price';
  }

  @override
  String get add => 'Dodaj';

  @override
  String get addFree => 'Dodaj brezplačno';

  @override
  String get back => 'Nazaj';

  @override
  String get previous => 'Prejšnja';

  @override
  String get next => 'Naprej';

  @override
  String get study => 'Uči se';

  @override
  String get download => 'Prenesi';

  @override
  String get confirmLanguagesLabel => 'Jeziki';

  @override
  String get styleSectionTitle => 'Slog slik';

  @override
  String get confirmBuyNote =>
      'Nakup odklene celoten komplet — vse jezike in vse sloge. Ta kombinacija bo dodana na vaš začetni zaslon.';

  @override
  String get confirmAddNote =>
      'Ta kombinacija bo dodana na vaš začetni zaslon. Drug jezik ali slog lahko dodate kadar koli.';

  @override
  String get purchaseFailedToStart => 'Nakupa ni bilo mogoče začeti.';

  @override
  String get addedToHome => 'Dodano na začetni zaslon.';

  @override
  String get downloadFailed => 'Prenos ni uspel. Poskusite znova.';

  @override
  String get deckNotPurchased => 'Ta komplet ni kupljen.';

  @override
  String downloading(int percent) {
    return 'Prenašanje … $percent %';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktivnih',
      few: '$count aktivne',
      two: '$count aktivni',
      one: '$count aktivna',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Znam';

  @override
  String get pickerLearning => 'Učim se';

  @override
  String get reportIssue => 'Prijavi težavo';

  @override
  String get issueTranslation => 'Prevod';

  @override
  String get issueImage => 'Slika';

  @override
  String get issuePronunciation => 'Izgovorjava';

  @override
  String get issueMeaning => 'Pomen / dejstva';

  @override
  String get issueOther => 'Drugo';

  @override
  String get feedbackCommentHint => 'Kaj je narobe? (neobvezno)';

  @override
  String get feedbackSend => 'Pošlji po e-pošti';

  @override
  String feedbackNoMailApp(String email) {
    return 'Ni na voljo nobene aplikacije za e-pošto. Prijava je kopirana v odložišče — pošljite jo na $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Težava s kartico $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Komplet: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Kartica: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Jeziki: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Prikazano: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Slog: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Vrsta težave: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'Za: $email';
  }

  @override
  String get pronounce => 'Izgovori';

  @override
  String get installVoice => 'Namesti glas';

  @override
  String noVoiceInstalled(String lang) {
    return 'Za »$lang« ni nameščen noben glas. Dodajte ga v Nastavitvah → Dostopnost → Govorjena vsebina → Glasovi in poskusite znova.';
  }

  @override
  String get playPronunciation => 'Predvajaj izgovorjavo';

  @override
  String get swipeNext => 'NAPREJ';

  @override
  String get swipeBack => 'NAZAJ';

  @override
  String get showTranslation => 'Pokaži prevod';

  @override
  String get showOriginal => 'Pokaži izvirnik';

  @override
  String get noCards => 'Ni kartic';

  @override
  String get deckHasNoCards => 'Ta komplet nima kartic.';

  @override
  String get flashcards => 'Učne kartice';

  @override
  String get stylePhoto => 'Fotografija';

  @override
  String get stylePhotoDesc => 'Ostra fotografija, najbližje resničnosti';

  @override
  String get styleInk => 'Čopič in tuš';

  @override
  String get styleInkDesc => 'Poteze čopiča, prazen papir, en barvni poudarek';

  @override
  String get stylePastel => 'Pastel';

  @override
  String get stylePastelDesc => 'Suhi pastel na toniranem papirju';

  @override
  String get styleWatercolor => 'Akvarel';

  @override
  String get styleWatercolorDesc => 'Razlite barve, skozi katere se vidi papir';

  @override
  String get styleFlag => 'Zastave';

  @override
  String get styleFlagDesc => 'Prave državne zastave';

  @override
  String get stylePonyCartoon => 'Risanka';

  @override
  String get stylePonyCartoonDesc => 'Barvita risana ilustracija';

  @override
  String get styleStorybook => 'Slikanica';

  @override
  String get styleStorybookDesc => 'Nežna knjižna ilustracija';

  @override
  String get stylePonyWatercolor => 'Akvarel – nežen';

  @override
  String get stylePonyWatercolorDesc => 'Nežna akvarelna slika';

  @override
  String get stylePonyOil => 'Oljna slika';

  @override
  String get stylePonyOilDesc => 'Debele poteze čopiča na platnu';

  @override
  String get styleIllustriousOil => 'Olje – impasto';

  @override
  String get styleIllustriousOilDesc => 'Gost impasto nanos, chiaroscuro';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Japonska anime risba';

  @override
  String get styleFlat => 'Ploski vektor';

  @override
  String get styleFlatDesc => 'Ploske barve in čiste oblike';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Japonski lesorez';

  @override
  String get styleMucha => 'Secesija (Mucha)';

  @override
  String get styleMuchaDesc => 'Okrasna secesija z zlatimi poudarki';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc => 'Postimpresionistične vrtinčaste poteze';

  @override
  String get langAr => 'Arabščina';

  @override
  String get langCs => 'Češčina';

  @override
  String get langDe => 'Nemščina';

  @override
  String get langEl => 'Grščina';

  @override
  String get langEn => 'Angleščina';

  @override
  String get langEs419 => 'Španščina';

  @override
  String get langFr => 'Francoščina';

  @override
  String get langHe => 'Hebrejščina';

  @override
  String get langHi => 'Hindijščina';

  @override
  String get langId => 'Indonezijščina';

  @override
  String get langJa => 'Japonščina';

  @override
  String get langKo => 'Korejščina';

  @override
  String get langPtBR => 'Portugalščina';

  @override
  String get langRu => 'Ruščina';

  @override
  String get langTr => 'Turščina';

  @override
  String get langVi => 'Vietnamščina';

  @override
  String get langZhCN => 'Kitajščina';
}
