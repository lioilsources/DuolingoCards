// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'డెక్ స్టోర్';

  @override
  String get homeEmptyTitle => 'ఇంకా డెక్‌లు లేవు';

  @override
  String get homeReorderHint =>
      'క్రమం మార్చడానికి డెక్‌ను నొక్కి పట్టుకుని లాగండి';

  @override
  String get homeBrowseStore => 'డెక్ స్టోర్‌ను చూడండి';

  @override
  String get homeDownloadingDecks => 'మీ డెక్‌లను సిద్ధం చేస్తున్నాం…';

  @override
  String get badgeFree => 'ఉచితం';

  @override
  String get badgeUnlocked => 'అన్‌లాక్ అయింది';

  @override
  String get badgePurchased => 'కొనుగోలు చేశారు';

  @override
  String get badgePaidDeck => 'చెల్లింపు డెక్';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count కార్డ్‌లు',
      one: '1 కార్డ్',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards కార్డ్‌లు',
      one: '1 కార్డ్',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs భాషలు',
      one: '1 భాష',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count తెలిసినవి';
  }

  @override
  String legendLearning(int count) {
    return '$count నేర్చుకుంటున్నవి';
  }

  @override
  String legendUnknown(int count) {
    return '$count తెలియనివి';
  }

  @override
  String get storeTitle => 'డెక్ స్టోర్';

  @override
  String get storeRestorePurchases => 'కొనుగోళ్లను పునరుద్ధరించు';

  @override
  String get storeSearchHint => 'డెక్‌లను వెతకండి…';

  @override
  String storeLoadError(String error) {
    return 'డెక్‌లను లోడ్ చేయలేకపోయాం: $error';
  }

  @override
  String get storeNoDecks => 'డెక్‌లు అందుబాటులో లేవు.';

  @override
  String get storeNothingFound => 'ఏమీ కనబడలేదు.';

  @override
  String get retry => 'మళ్లీ ప్రయత్నించు';

  @override
  String get buy => 'కొను';

  @override
  String buyFor(String price) {
    return '$priceకు కొను';
  }

  @override
  String get add => 'జోడించు';

  @override
  String get addFree => 'ఉచితంగా జోడించు';

  @override
  String get back => 'వెనుకకు';

  @override
  String get previous => 'మునుపటి';

  @override
  String get next => 'తదుపరి';

  @override
  String get study => 'నేర్చుకో';

  @override
  String get download => 'డౌన్‌లోడ్';

  @override
  String get confirmLanguagesLabel => 'భాషలు';

  @override
  String get styleSectionTitle => 'చిత్ర శైలి';

  @override
  String get confirmBuyNote =>
      'కొనుగోలుతో మొత్తం డెక్ అన్‌లాక్ అవుతుంది — అన్ని భాషలు, అన్ని శైలులు. ఈ కలయిక మీ హోమ్ స్క్రీన్‌కు జోడించబడుతుంది.';

  @override
  String get confirmAddNote =>
      'ఈ కలయిక మీ హోమ్ స్క్రీన్‌కు జోడించబడుతుంది. మీరు ఎప్పుడైనా మరో భాష లేదా శైలిని జోడించవచ్చు.';

  @override
  String get purchaseFailedToStart => 'కొనుగోలును ప్రారంభించలేకపోయాం.';

  @override
  String get addedToHome => 'హోమ్ స్క్రీన్‌కు జోడించబడింది.';

  @override
  String get downloadFailed =>
      'డౌన్‌లోడ్ విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get deckNotPurchased => 'ఈ డెక్‌ను కొనుగోలు చేయలేదు.';

  @override
  String downloading(int percent) {
    return 'డౌన్‌లోడ్ అవుతోంది… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count యాక్టివ్',
      one: '1 యాక్టివ్',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'నాకు తెలుసు';

  @override
  String get pickerLearning => 'నేర్చుకుంటున్నాను';

  @override
  String get reportIssue => 'సమస్యను నివేదించు';

  @override
  String get issueTranslation => 'అనువాదం';

  @override
  String get issueImage => 'చిత్రం';

  @override
  String get issuePronunciation => 'ఉచ్చారణ';

  @override
  String get issueMeaning => 'అర్థం / వాస్తవాలు';

  @override
  String get issueOther => 'ఇతర';

  @override
  String get feedbackCommentHint => 'ఏమి తప్పు ఉంది? (ఐచ్ఛికం)';

  @override
  String get feedbackSend => 'ఇ-మెయిల్ ద్వారా పంపు';

  @override
  String feedbackNoMailApp(String email) {
    return 'ఇ-మెయిల్ యాప్ అందుబాటులో లేదు. నివేదిక క్లిప్‌బోర్డ్‌కు కాపీ అయింది — దయచేసి దాన్ని $emailకు పంపండి.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] కార్డ్ సమస్య $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'డెక్: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'కార్డ్: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'భాషలు: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'చూపినది: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'శైలి: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'సమస్య రకం: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'వీరికి: $email';
  }

  @override
  String get pronounce => 'ఉచ్చరించు';

  @override
  String get installVoice => 'వాయిస్ ఇన్‌స్టాల్ చేయి';

  @override
  String noVoiceInstalled(String lang) {
    return '\"$lang\" కోసం వాయిస్ ఇన్‌స్టాల్ కాలేదు. సెట్టింగ్‌లు → యాక్సెసిబిలిటీ → స్పోకెన్ కంటెంట్ → వాయిస్‌లలో ఒకటి జోడించి మళ్లీ ప్రయత్నించండి.';
  }

  @override
  String get playPronunciation => 'ఉచ్చారణ వినిపించు';

  @override
  String get swipeNext => 'తదుపరి';

  @override
  String get swipeBack => 'వెనుకకు';

  @override
  String get showTranslation => 'అనువాదం చూపు';

  @override
  String get showOriginal => 'మూలం చూపు';

  @override
  String get noCards => 'కార్డ్‌లు లేవు';

  @override
  String get deckHasNoCards => 'ఈ డెక్‌లో కార్డ్‌లు లేవు.';

  @override
  String get flashcards => 'ఫ్లాష్‌కార్డ్‌లు';

  @override
  String get stylePhoto => 'ఫోటో';

  @override
  String get stylePhotoDesc => 'స్పష్టమైన ఫోటో, వాస్తవానికి అత్యంత దగ్గరగా';

  @override
  String get styleInk => 'కుంచె మరియు సిరా';

  @override
  String get styleInkDesc => 'కుంచె గీతలు, ఖాళీ కాగితం, ఒక రంగు మెరుపు';

  @override
  String get stylePastel => 'పాస్టెల్';

  @override
  String get stylePastelDesc => 'రంగు కాగితంపై పొడి పాస్టెల్';

  @override
  String get styleWatercolor => 'జలవర్ణం';

  @override
  String get styleWatercolorDesc => 'వ్యాపించే జలవర్ణాలు, కాగితం కనిపిస్తుంది';

  @override
  String get styleFlag => 'జెండాలు';

  @override
  String get styleFlagDesc => 'నిజమైన జాతీయ జెండాలు';

  @override
  String get stylePonyCartoon => 'కార్టూన్';

  @override
  String get stylePonyCartoonDesc => 'రంగురంగుల కార్టూన్ చిత్రం';

  @override
  String get styleStorybook => 'కథల పుస్తకం';

  @override
  String get styleStorybookDesc => 'మృదువైన పుస్తక చిత్రం';

  @override
  String get stylePonyWatercolor => 'జలవర్ణం – మృదువు';

  @override
  String get stylePonyWatercolorDesc => 'మృదువైన జలవర్ణ చిత్రం';

  @override
  String get stylePonyOil => 'తైలవర్ణ చిత్రం';

  @override
  String get stylePonyOilDesc => 'కాన్వాస్‌పై మందపాటి కుంచె గీతలు';

  @override
  String get styleIllustriousOil => 'తైలం – ఇంపాస్టో';

  @override
  String get styleIllustriousOilDesc => 'చిక్కటి ఇంపాస్టో రంగు, వెలుగు-నీడ';

  @override
  String get styleAnime => 'అనిమే';

  @override
  String get styleAnimeDesc => 'జపనీస్ అనిమే చిత్రం';

  @override
  String get styleFlat => 'ఫ్లాట్ వెక్టర్';

  @override
  String get styleFlatDesc => 'సమతల రంగులు, శుభ్రమైన ఆకారాలు';

  @override
  String get styleUkiyoe => 'ఉకియో-ఎ';

  @override
  String get styleUkiyoeDesc => 'జపనీస్ చెక్క అచ్చు';

  @override
  String get styleMucha => 'ఆర్ట్ నూవో (ముఖా)';

  @override
  String get styleMuchaDesc => 'బంగారు మెరుపులతో అలంకార ఆర్ట్ నూవో';

  @override
  String get styleVanGogh => 'వాన్ గో';

  @override
  String get styleVanGoghDesc => 'పోస్ట్-ఇంప్రెషనిస్ట్ సుడి గీతలు';

  @override
  String get langAr => 'అరబిక్';

  @override
  String get langCs => 'చెక్';

  @override
  String get langDe => 'జర్మన్';

  @override
  String get langEl => 'గ్రీక్';

  @override
  String get langEn => 'ఇంగ్లీష్';

  @override
  String get langEs419 => 'స్పానిష్';

  @override
  String get langFr => 'ఫ్రెంచ్';

  @override
  String get langHe => 'హీబ్రూ';

  @override
  String get langHi => 'హిందీ';

  @override
  String get langId => 'ఇండోనేషియన్';

  @override
  String get langJa => 'జపనీస్';

  @override
  String get langKo => 'కొరియన్';

  @override
  String get langPtBR => 'పోర్చుగీస్';

  @override
  String get langRu => 'రష్యన్';

  @override
  String get langTr => 'టర్కిష్';

  @override
  String get langVi => 'వియత్నామీస్';

  @override
  String get langZhCN => 'చైనీస్';
}
