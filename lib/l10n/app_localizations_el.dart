// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Κατάστημα τράπουλων';

  @override
  String get homeEmptyTitle => 'Δεν υπάρχουν τράπουλες ακόμα';

  @override
  String get homeReorderHint =>
      'Πατήστε παρατεταμένα μια τράπουλα και σύρετέ τη για αλλαγή σειράς';

  @override
  String get homeBrowseStore => 'Δείτε το κατάστημα τράπουλων';

  @override
  String get homeDownloadingDecks => 'Ετοιμάζουμε τις τράπουλές σας…';

  @override
  String get badgeFree => 'Δωρεάν';

  @override
  String get badgeUnlocked => 'Ξεκλειδωμένη';

  @override
  String get badgePurchased => 'Αγορασμένη';

  @override
  String get badgePaidDeck => 'Επί πληρωμή';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count κάρτες',
      one: '1 κάρτα',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards κάρτες',
      one: '1 κάρτα',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs γλώσσες',
      one: '1 γλώσσα',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count γνωστές';
  }

  @override
  String legendLearning(int count) {
    return '$count σε εκμάθηση';
  }

  @override
  String legendUnknown(int count) {
    return '$count άγνωστες';
  }

  @override
  String get storeTitle => 'Κατάστημα τράπουλων';

  @override
  String get storeRestorePurchases => 'Επαναφορά αγορών';

  @override
  String get storeSearchHint => 'Αναζήτηση τράπουλων…';

  @override
  String storeLoadError(String error) {
    return 'Δεν ήταν δυνατή η φόρτωση των τράπουλων: $error';
  }

  @override
  String get storeNoDecks => 'Δεν υπάρχουν διαθέσιμες τράπουλες.';

  @override
  String get storeNothingFound => 'Δεν βρέθηκε τίποτα.';

  @override
  String get retry => 'Ξανά';

  @override
  String get buy => 'Αγορά';

  @override
  String buyFor(String price) {
    return 'Αγορά για $price';
  }

  @override
  String get add => 'Προσθήκη';

  @override
  String get addFree => 'Δωρεάν προσθήκη';

  @override
  String get back => 'Πίσω';

  @override
  String get previous => 'Προηγούμενη';

  @override
  String get next => 'Επόμενη';

  @override
  String get study => 'Μελέτη';

  @override
  String get download => 'Λήψη';

  @override
  String get confirmLanguagesLabel => 'Γλώσσες';

  @override
  String get styleSectionTitle => 'Στυλ εικόνων';

  @override
  String get confirmBuyNote =>
      'Η αγορά ξεκλειδώνει όλη την τράπουλα — κάθε γλώσσα και κάθε στυλ. Αυτός ο συνδυασμός θα προστεθεί στην αρχική οθόνη.';

  @override
  String get confirmAddNote =>
      'Αυτός ο συνδυασμός θα προστεθεί στην αρχική οθόνη. Μπορείτε να προσθέσετε άλλη γλώσσα ή στυλ οποιαδήποτε στιγμή.';

  @override
  String get purchaseFailedToStart => 'Δεν ήταν δυνατή η έναρξη της αγοράς.';

  @override
  String get addedToHome => 'Προστέθηκε στην αρχική οθόνη.';

  @override
  String get downloadFailed => 'Η λήψη απέτυχε. Δοκιμάστε ξανά.';

  @override
  String get deckNotPurchased => 'Αυτή η τράπουλα δεν έχει αγοραστεί.';

  @override
  String downloading(int percent) {
    return 'Λήψη… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ενεργοί',
      one: '1 ενεργός',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Το ξέρω';

  @override
  String get pickerLearning => 'Το μαθαίνω';

  @override
  String get reportIssue => 'Αναφορά προβλήματος';

  @override
  String get issueTranslation => 'Μετάφραση';

  @override
  String get issueImage => 'Εικόνα';

  @override
  String get issuePronunciation => 'Προφορά';

  @override
  String get issueMeaning => 'Σημασία / στοιχεία';

  @override
  String get issueOther => 'Άλλο';

  @override
  String get feedbackCommentHint => 'Τι δεν πάει καλά; (προαιρετικά)';

  @override
  String get feedbackSend => 'Αποστολή με e-mail';

  @override
  String feedbackNoMailApp(String email) {
    return 'Δεν υπάρχει εφαρμογή e-mail. Η αναφορά αντιγράφηκε στο πρόχειρο — στείλτε την στο $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Πρόβλημα κάρτας $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Τράπουλα: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Κάρτα: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Γλώσσες: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Εμφανίστηκε: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Στυλ: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Είδος προβλήματος: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'Προς: $email';
  }

  @override
  String get pronounce => 'Προφορά';

  @override
  String get installVoice => 'Εγκατάσταση φωνής';

  @override
  String noVoiceInstalled(String lang) {
    return 'Δεν υπάρχει εγκατεστημένη φωνή για «$lang». Προσθέστε μία στις Ρυθμίσεις → Προσβασιμότητα → Εκφώνηση περιεχομένου → Φωνές και δοκιμάστε ξανά.';
  }

  @override
  String get playPronunciation => 'Αναπαραγωγή προφοράς';

  @override
  String get swipeNext => 'ΕΠΟΜΕΝΗ';

  @override
  String get swipeBack => 'ΠΙΣΩ';

  @override
  String get showTranslation => 'Εμφάνιση μετάφρασης';

  @override
  String get showOriginal => 'Εμφάνιση πρωτοτύπου';

  @override
  String get noCards => 'Καμία κάρτα';

  @override
  String get deckHasNoCards => 'Αυτή η τράπουλα δεν έχει κάρτες.';

  @override
  String get flashcards => 'Κάρτες';

  @override
  String get stylePhoto => 'Φωτογραφία';

  @override
  String get stylePhotoDesc =>
      'Καθαρή φωτογραφία, πιο κοντά στην πραγματικότητα';

  @override
  String get styleInk => 'Πινέλο και μελάνι';

  @override
  String get styleInkDesc => 'Πινελιές, γυμνό χαρτί, μία χρωματική πινελιά';

  @override
  String get stylePastel => 'Παστέλ';

  @override
  String get stylePastelDesc => 'Ξηρό παστέλ σε χρωματιστό χαρτί';

  @override
  String get styleWatercolor => 'Ακουαρέλα';

  @override
  String get styleWatercolorDesc =>
      'Απλωμένα χρώματα, το χαρτί φαίνεται από κάτω';

  @override
  String get styleFlag => 'Σημαίες';

  @override
  String get styleFlagDesc => 'Οι πραγματικές εθνικές σημαίες';

  @override
  String get stylePonyCartoon => 'Καρτούν';

  @override
  String get stylePonyCartoonDesc => 'Πολύχρωμη εικονογράφηση καρτούν';

  @override
  String get styleStorybook => 'Παραμύθι';

  @override
  String get styleStorybookDesc => 'Απαλή εικονογράφηση βιβλίου';

  @override
  String get stylePonyWatercolor => 'Ακουαρέλα – απαλή';

  @override
  String get stylePonyWatercolorDesc => 'Απαλός πίνακας ακουαρέλας';

  @override
  String get stylePonyOil => 'Ελαιογραφία';

  @override
  String get stylePonyOilDesc => 'Παχιές πινελιές σε καμβά';

  @override
  String get styleIllustriousOil => 'Λάδι – ιμπάστο';

  @override
  String get styleIllustriousOilDesc => 'Πυκνό χρώμα ιμπάστο, φωτοσκίαση';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Ιαπωνικό σχέδιο anime';

  @override
  String get styleFlat => 'Επίπεδο διανυσματικό';

  @override
  String get styleFlatDesc => 'Επίπεδα χρώματα και καθαρά σχήματα';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Ιαπωνική ξυλογραφία';

  @override
  String get styleMucha => 'Αρ Νουβό (Mucha)';

  @override
  String get styleMuchaDesc => 'Διακοσμητικό αρ νουβό με χρυσές λεπτομέρειες';

  @override
  String get styleVanGogh => 'Βαν Γκογκ';

  @override
  String get styleVanGoghDesc => 'Μετα-ιμπρεσιονιστικές στροβιλιστές πινελιές';

  @override
  String get langAr => 'Αραβικά';

  @override
  String get langCs => 'Τσεχικά';

  @override
  String get langDe => 'Γερμανικά';

  @override
  String get langEl => 'Ελληνικά';

  @override
  String get langEn => 'Αγγλικά';

  @override
  String get langEs419 => 'Ισπανικά';

  @override
  String get langFr => 'Γαλλικά';

  @override
  String get langHe => 'Εβραϊκά';

  @override
  String get langHi => 'Χίντι';

  @override
  String get langId => 'Ινδονησιακά';

  @override
  String get langJa => 'Ιαπωνικά';

  @override
  String get langKo => 'Κορεατικά';

  @override
  String get langPtBR => 'Πορτογαλικά';

  @override
  String get langRu => 'Ρωσικά';

  @override
  String get langTr => 'Τουρκικά';

  @override
  String get langVi => 'Βιετναμικά';

  @override
  String get langZhCN => 'Κινεζικά';
}
