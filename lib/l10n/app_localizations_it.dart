// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Negozio dei mazzi';

  @override
  String get homeEmptyTitle => 'Ancora nessun mazzo';

  @override
  String get homeReorderHint =>
      'Tieni premuto un mazzo e trascinalo per riordinare';

  @override
  String get homeBrowseStore => 'Sfoglia il negozio dei mazzi';

  @override
  String get homeDownloadingDecks => 'Stiamo preparando i tuoi mazzi…';

  @override
  String get badgeFree => 'Gratis';

  @override
  String get badgeUnlocked => 'Sbloccato';

  @override
  String get badgePurchased => 'Acquistato';

  @override
  String get badgePaidDeck => 'Mazzo a pagamento';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count carte',
      one: '1 carta',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards carte',
      one: '1 carta',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs lingue',
      one: '1 lingua',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count conosciute';
  }

  @override
  String legendLearning(int count) {
    return '$count da imparare';
  }

  @override
  String legendUnknown(int count) {
    return '$count sconosciute';
  }

  @override
  String get storeTitle => 'Negozio dei mazzi';

  @override
  String get storeRestorePurchases => 'Ripristina acquisti';

  @override
  String get storeSearchHint => 'Cerca mazzi…';

  @override
  String storeLoadError(String error) {
    return 'Impossibile caricare i mazzi: $error';
  }

  @override
  String get storeNoDecks => 'Nessun mazzo disponibile.';

  @override
  String get storeNothingFound => 'Nessun risultato.';

  @override
  String get retry => 'Riprova';

  @override
  String get buy => 'Acquista';

  @override
  String buyFor(String price) {
    return 'Acquista a $price';
  }

  @override
  String get add => 'Aggiungi';

  @override
  String get addFree => 'Aggiungi gratis';

  @override
  String get back => 'Indietro';

  @override
  String get previous => 'Precedente';

  @override
  String get next => 'Avanti';

  @override
  String get study => 'Studia';

  @override
  String get download => 'Scarica';

  @override
  String get confirmLanguagesLabel => 'Lingue';

  @override
  String get styleSectionTitle => 'Stile delle immagini';

  @override
  String get confirmBuyNote =>
      'L\'acquisto sblocca l\'intero mazzo: tutte le lingue e tutti gli stili. Questa combinazione verrà aggiunta alla schermata Home.';

  @override
  String get confirmAddNote =>
      'Questa combinazione verrà aggiunta alla schermata Home. Puoi aggiungere un\'altra lingua o un altro stile in qualsiasi momento.';

  @override
  String get purchaseFailedToStart => 'Impossibile avviare l\'acquisto.';

  @override
  String get addedToHome => 'Aggiunto alla schermata Home.';

  @override
  String get downloadFailed => 'Download non riuscito. Riprova.';

  @override
  String get deckNotPurchased => 'Questo mazzo non è stato acquistato.';

  @override
  String downloading(int percent) {
    return 'Download… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attive',
      one: '1 attiva',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Lo so';

  @override
  String get pickerLearning => 'Sto imparando';

  @override
  String get reportIssue => 'Segnala un problema';

  @override
  String get issueTranslation => 'Traduzione';

  @override
  String get issueImage => 'Immagine';

  @override
  String get issuePronunciation => 'Pronuncia';

  @override
  String get issueMeaning => 'Significato / fatti';

  @override
  String get issueOther => 'Altro';

  @override
  String get feedbackCommentHint => 'Che cosa non va? (facoltativo)';

  @override
  String get feedbackSend => 'Invia per e-mail';

  @override
  String feedbackNoMailApp(String email) {
    return 'Nessuna app di posta disponibile. La segnalazione è stata copiata negli appunti: inviala a $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Problema con la carta $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Mazzo: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Carta: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Lingue: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Mostrato: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Stile: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Tipo di problema: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'A: $email';
  }

  @override
  String get pronounce => 'Pronuncia';

  @override
  String get installVoice => 'Installa voce';

  @override
  String noVoiceInstalled(String lang) {
    return 'Nessuna voce installata per \"$lang\". Aggiungine una in Impostazioni → Accessibilità → Contenuto letto ad alta voce → Voci, poi riprova.';
  }

  @override
  String get playPronunciation => 'Ascolta la pronuncia';

  @override
  String get swipeNext => 'AVANTI';

  @override
  String get swipeBack => 'INDIETRO';

  @override
  String get showTranslation => 'Mostra traduzione';

  @override
  String get showOriginal => 'Mostra originale';

  @override
  String get noCards => 'Nessuna carta';

  @override
  String get deckHasNoCards => 'Questo mazzo non ha carte.';

  @override
  String get flashcards => 'Flashcard';

  @override
  String get stylePhoto => 'Foto';

  @override
  String get stylePhotoDesc => 'Fotografia nitida, la più vicina alla realtà';

  @override
  String get styleInk => 'Pennello e inchiostro';

  @override
  String get styleInkDesc =>
      'Pennellate, carta bianca, un solo accento di colore';

  @override
  String get stylePastel => 'Pastello';

  @override
  String get stylePastelDesc => 'Pastello secco su carta colorata';

  @override
  String get styleWatercolor => 'Acquerello';

  @override
  String get styleWatercolorDesc => 'Velature sfumate, carta che traspare';

  @override
  String get styleFlag => 'Bandiere';

  @override
  String get styleFlagDesc => 'Le vere bandiere nazionali';

  @override
  String get stylePonyCartoon => 'Cartone animato';

  @override
  String get stylePonyCartoonDesc => 'Illustrazione colorata in stile cartoon';

  @override
  String get styleStorybook => 'Libro illustrato';

  @override
  String get styleStorybookDesc => 'Morbida illustrazione da libro';

  @override
  String get stylePonyWatercolor => 'Acquerello – morbido';

  @override
  String get stylePonyWatercolorDesc => 'Delicato dipinto ad acquerello';

  @override
  String get stylePonyOil => 'Pittura a olio';

  @override
  String get stylePonyOilDesc => 'Pennellate spesse su tela';

  @override
  String get styleIllustriousOil => 'Olio – impasto';

  @override
  String get styleIllustriousOilDesc => 'Colore denso a impasto, chiaroscuro';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Disegno anime giapponese';

  @override
  String get styleFlat => 'Vettoriale piatto';

  @override
  String get styleFlatDesc => 'Colori piatti e forme pulite';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Xilografia giapponese';

  @override
  String get styleMucha => 'Art Nouveau (Mucha)';

  @override
  String get styleMuchaDesc => 'Liberty ornamentale con accenti dorati';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc => 'Pennellate vorticose post-impressioniste';

  @override
  String get langAr => 'Arabo';

  @override
  String get langCs => 'Ceco';

  @override
  String get langDe => 'Tedesco';

  @override
  String get langEl => 'Greco';

  @override
  String get langEn => 'Inglese';

  @override
  String get langEs419 => 'Spagnolo';

  @override
  String get langFr => 'Francese';

  @override
  String get langHe => 'Ebraico';

  @override
  String get langHi => 'Hindi';

  @override
  String get langId => 'Indonesiano';

  @override
  String get langJa => 'Giapponese';

  @override
  String get langKo => 'Coreano';

  @override
  String get langPtBR => 'Portoghese';

  @override
  String get langRu => 'Russo';

  @override
  String get langTr => 'Turco';

  @override
  String get langVi => 'Vietnamita';

  @override
  String get langZhCN => 'Cinese';
}
