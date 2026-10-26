// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'डेक स्टोर';

  @override
  String get homeEmptyTitle => 'अभी कोई डेक नहीं';

  @override
  String get homeReorderHint =>
      'क्रम बदलने के लिए डेक को देर तक दबाएँ और खींचें';

  @override
  String get homeBrowseStore => 'डेक स्टोर देखें';

  @override
  String get homeDownloadingDecks => 'आपके डेक तैयार हो रहे हैं…';

  @override
  String get badgeFree => 'मुफ़्त';

  @override
  String get badgeUnlocked => 'अनलॉक';

  @override
  String get badgePurchased => 'खरीदा गया';

  @override
  String get badgePaidDeck => 'पेड डेक';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कार्ड',
      one: '$count कार्ड',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards कार्ड',
      one: '$cards कार्ड',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs भाषाएँ',
      one: '$langs भाषा',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count आते हैं';
  }

  @override
  String legendLearning(int count) {
    return '$count सीख रहे हैं';
  }

  @override
  String legendUnknown(int count) {
    return '$count नहीं आते';
  }

  @override
  String get storeTitle => 'डेक स्टोर';

  @override
  String get storeRestorePurchases => 'खरीदारी बहाल करें';

  @override
  String get storeSearchHint => 'डेक खोजें…';

  @override
  String storeLoadError(String error) {
    return 'डेक लोड नहीं हो सके: $error';
  }

  @override
  String get storeNoDecks => 'कोई डेक उपलब्ध नहीं है।';

  @override
  String get storeNothingFound => 'कुछ नहीं मिला।';

  @override
  String get retry => 'फिर से कोशिश करें';

  @override
  String get buy => 'खरीदें';

  @override
  String buyFor(String price) {
    return '$price में खरीदें';
  }

  @override
  String get add => 'जोड़ें';

  @override
  String get addFree => 'मुफ़्त में जोड़ें';

  @override
  String get back => 'वापस';

  @override
  String get previous => 'पिछला';

  @override
  String get next => 'अगला';

  @override
  String get study => 'सीखें';

  @override
  String get download => 'डाउनलोड करें';

  @override
  String get confirmLanguagesLabel => 'भाषाएँ';

  @override
  String get styleSectionTitle => 'चित्र शैली';

  @override
  String get confirmBuyNote =>
      'खरीदने पर पूरा डेक अनलॉक हो जाता है — हर भाषा और हर शैली। यह संयोजन आपकी होम स्क्रीन पर जोड़ दिया जाएगा।';

  @override
  String get confirmAddNote =>
      'यह संयोजन आपकी होम स्क्रीन पर जोड़ दिया जाएगा। आप कभी भी कोई और भाषा या शैली जोड़ सकते हैं।';

  @override
  String get purchaseFailedToStart => 'खरीदारी शुरू नहीं हो सकी।';

  @override
  String get addedToHome => 'आपकी होम स्क्रीन पर जोड़ दिया गया।';

  @override
  String get downloadFailed => 'डाउनलोड नहीं हो सका। कृपया फिर से कोशिश करें।';

  @override
  String get deckNotPurchased => 'यह डेक अभी खरीदा नहीं गया है।';

  @override
  String downloading(int percent) {
    return 'डाउनलोड हो रहा है… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सक्रिय',
      one: '$count सक्रिय',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'आता है';

  @override
  String get pickerLearning => 'सीख रहे हैं';

  @override
  String get reportIssue => 'समस्या बताएँ';

  @override
  String get issueTranslation => 'अनुवाद';

  @override
  String get issueImage => 'चित्र';

  @override
  String get issuePronunciation => 'उच्चारण';

  @override
  String get issueMeaning => 'अर्थ / जानकारी';

  @override
  String get issueOther => 'अन्य';

  @override
  String get feedbackCommentHint => 'क्या गलत है? (वैकल्पिक)';

  @override
  String get feedbackSend => 'ईमेल से भेजें';

  @override
  String feedbackNoMailApp(String email) {
    return 'कोई ईमेल ऐप उपलब्ध नहीं है। रिपोर्ट क्लिपबोर्ड पर कॉपी कर दी गई है — कृपया इसे $email पर भेजें।';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] कार्ड में समस्या $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'डेक: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'कार्ड: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'भाषाएँ: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'दिखाया गया: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'शैली: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'समस्या का प्रकार: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'प्रति: $email';
  }

  @override
  String get pronounce => 'उच्चारण सुनें';

  @override
  String get installVoice => 'आवाज़ इंस्टॉल करें';

  @override
  String noVoiceInstalled(String lang) {
    return '\"$lang\" के लिए कोई आवाज़ इंस्टॉल नहीं है। सेटिंग्ज़ → ऐक्सेसिबिलिटी → बोली गई सामग्री → आवाज़ें में जाकर एक आवाज़ जोड़ें, फिर से कोशिश करें।';
  }

  @override
  String get playPronunciation => 'उच्चारण चलाएँ';

  @override
  String get swipeNext => 'अगला';

  @override
  String get swipeBack => 'वापस';

  @override
  String get showTranslation => 'अनुवाद दिखाएँ';

  @override
  String get showOriginal => 'मूल दिखाएँ';

  @override
  String get noCards => 'कोई कार्ड नहीं';

  @override
  String get deckHasNoCards => 'इस डेक में कोई कार्ड नहीं है।';

  @override
  String get flashcards => 'फ़्लैशकार्ड';

  @override
  String get stylePhoto => 'फ़ोटो';

  @override
  String get stylePhotoDesc => 'साफ़ तस्वीर, असली जैसी';

  @override
  String get styleInk => 'ब्रश और स्याही';

  @override
  String get styleInkDesc => 'ब्रश के स्ट्रोक, खाली कागज़, एक रंग की झलक';

  @override
  String get stylePastel => 'पेस्टल';

  @override
  String get stylePastelDesc => 'रंगीन कागज़ पर सूखे पेस्टल';

  @override
  String get styleWatercolor => 'जलरंग';

  @override
  String get styleWatercolorDesc => 'फैलते रंग, जिनसे कागज़ झाँकता है';

  @override
  String get styleFlag => 'झंडे';

  @override
  String get styleFlagDesc => 'देशों के असली झंडे';

  @override
  String get stylePonyCartoon => 'कार्टून';

  @override
  String get stylePonyCartoonDesc => 'रंग-बिरंगा कार्टून चित्र';

  @override
  String get styleStorybook => 'कहानी की किताब';

  @override
  String get styleStorybookDesc => 'किताब जैसा कोमल चित्र';

  @override
  String get stylePonyWatercolor => 'जलरंग – कोमल';

  @override
  String get stylePonyWatercolorDesc => 'कोमल जलरंग चित्र';

  @override
  String get stylePonyOil => 'तैलचित्र';

  @override
  String get stylePonyOilDesc => 'कैनवास पर मोटे ब्रश स्ट्रोक';

  @override
  String get styleIllustriousOil => 'तैल – इम्पास्टो';

  @override
  String get styleIllustriousOilDesc => 'गाढ़ा रंग, गहरी रोशनी और छाया';

  @override
  String get styleAnime => 'एनीमे';

  @override
  String get styleAnimeDesc => 'जापानी एनीमे चित्र';

  @override
  String get styleFlat => 'फ़्लैट वेक्टर';

  @override
  String get styleFlatDesc => 'सपाट रंग और साफ़ आकार';

  @override
  String get styleUkiyoe => 'उकियो-ए';

  @override
  String get styleUkiyoeDesc => 'जापानी लकड़ी के ठप्पे की छपाई';

  @override
  String get styleMucha => 'आर्ट नूवो (मूखा)';

  @override
  String get styleMuchaDesc => 'सुनहरी झलक वाला सजावटी आर्ट नूवो';

  @override
  String get styleVanGogh => 'वैन गॉग';

  @override
  String get styleVanGoghDesc => 'पोस्ट-इम्प्रेशनिस्ट घुमावदार स्ट्रोक';

  @override
  String get langAr => 'अरबी';

  @override
  String get langCs => 'चेक';

  @override
  String get langDe => 'जर्मन';

  @override
  String get langEl => 'यूनानी';

  @override
  String get langEn => 'अंग्रेज़ी';

  @override
  String get langEs419 => 'स्पेनिश';

  @override
  String get langFr => 'फ़्रेंच';

  @override
  String get langHe => 'हिब्रू';

  @override
  String get langHi => 'हिन्दी';

  @override
  String get langId => 'इंडोनेशियाई';

  @override
  String get langJa => 'जापानी';

  @override
  String get langKo => 'कोरियाई';

  @override
  String get langPtBR => 'पुर्तगाली';

  @override
  String get langRu => 'रूसी';

  @override
  String get langTr => 'तुर्की';

  @override
  String get langVi => 'वियतनामी';

  @override
  String get langZhCN => 'चीनी';
}
