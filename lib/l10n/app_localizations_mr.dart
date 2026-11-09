// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'डेक स्टोअर';

  @override
  String get homeEmptyTitle => 'अजून एकही डेक नाही';

  @override
  String get homeReorderHint => 'क्रम बदलण्यासाठी डेक दाबून धरा आणि ओढा';

  @override
  String get homeBrowseStore => 'डेक स्टोअर पाहा';

  @override
  String get homeDownloadingDecks => 'तुमचे डेक तयार करत आहोत…';

  @override
  String get badgeFree => 'मोफत';

  @override
  String get badgeUnlocked => 'अनलॉक केलेले';

  @override
  String get badgePurchased => 'खरेदी केलेले';

  @override
  String get badgePaidDeck => 'सशुल्क डेक';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कार्ड',
      one: '1 कार्ड',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards कार्ड',
      one: '1 कार्ड',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs भाषा',
      one: '1 भाषा',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count माहीत';
  }

  @override
  String legendLearning(int count) {
    return '$count शिकत आहे';
  }

  @override
  String legendUnknown(int count) {
    return '$count अनोळखी';
  }

  @override
  String get storeTitle => 'डेक स्टोअर';

  @override
  String get storeRestorePurchases => 'खरेदी पुनर्संचयित करा';

  @override
  String get storeSearchHint => 'डेक शोधा…';

  @override
  String storeLoadError(String error) {
    return 'डेक लोड करता आले नाहीत: $error';
  }

  @override
  String get storeNoDecks => 'कोणतेही डेक उपलब्ध नाहीत.';

  @override
  String get storeNothingFound => 'काहीही सापडले नाही.';

  @override
  String get retry => 'पुन्हा प्रयत्न करा';

  @override
  String get buy => 'खरेदी करा';

  @override
  String buyFor(String price) {
    return '$price ला खरेदी करा';
  }

  @override
  String get add => 'जोडा';

  @override
  String get addFree => 'मोफत जोडा';

  @override
  String get back => 'मागे';

  @override
  String get previous => 'मागील';

  @override
  String get next => 'पुढील';

  @override
  String get study => 'अभ्यास करा';

  @override
  String get download => 'डाउनलोड करा';

  @override
  String get confirmLanguagesLabel => 'भाषा';

  @override
  String get styleSectionTitle => 'चित्र शैली';

  @override
  String get confirmBuyNote =>
      'खरेदीमुळे संपूर्ण डेक अनलॉक होतो — प्रत्येक भाषा आणि प्रत्येक शैली. हे संयोजन तुमच्या होम स्क्रीनवर जोडले जाईल.';

  @override
  String get confirmAddNote =>
      'हे संयोजन तुमच्या होम स्क्रीनवर जोडले जाईल. तुम्ही कधीही दुसरी भाषा किंवा शैली जोडू शकता.';

  @override
  String get purchaseFailedToStart => 'खरेदी सुरू करता आली नाही.';

  @override
  String get addedToHome => 'होम स्क्रीनवर जोडले.';

  @override
  String get downloadFailed =>
      'डाउनलोड अयशस्वी झाले. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get deckNotPurchased => 'हा डेक खरेदी केलेला नाही.';

  @override
  String downloading(int percent) {
    return 'डाउनलोड होत आहे… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सक्रिय',
      one: '1 सक्रिय',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'मला माहीत आहे';

  @override
  String get pickerLearning => 'शिकत आहे';

  @override
  String get reportIssue => 'समस्या कळवा';

  @override
  String get issueTranslation => 'भाषांतर';

  @override
  String get issueImage => 'चित्र';

  @override
  String get issuePronunciation => 'उच्चार';

  @override
  String get issueMeaning => 'अर्थ / तथ्ये';

  @override
  String get issueOther => 'इतर';

  @override
  String get feedbackCommentHint => 'काय चुकले आहे? (पर्यायी)';

  @override
  String get feedbackSend => 'ई-मेलने पाठवा';

  @override
  String feedbackNoMailApp(String email) {
    return 'कोणतेही ई-मेल अ‍ॅप उपलब्ध नाही. अहवाल क्लिपबोर्डवर कॉपी केला आहे — कृपया तो $email वर पाठवा.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] कार्डमध्ये समस्या $key ($slug)';
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
    return 'भाषा: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'दाखवले: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'शैली: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'समस्येचा प्रकार: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'प्रति: $email';
  }

  @override
  String get pronounce => 'उच्चार करा';

  @override
  String get installVoice => 'आवाज इंस्टॉल करा';

  @override
  String noVoiceInstalled(String lang) {
    return '\"$lang\" साठी कोणताही आवाज इंस्टॉल केलेला नाही. सेटिंग्ज → अ‍ॅक्सेसिबिलिटी → स्पोकन कंटेंट → व्हॉइसेस मध्ये एक जोडा आणि पुन्हा प्रयत्न करा.';
  }

  @override
  String get playPronunciation => 'उच्चार ऐका';

  @override
  String get swipeNext => 'पुढील';

  @override
  String get swipeBack => 'मागे';

  @override
  String get showTranslation => 'भाषांतर दाखवा';

  @override
  String get showOriginal => 'मूळ दाखवा';

  @override
  String get noCards => 'कार्ड नाहीत';

  @override
  String get deckHasNoCards => 'या डेकमध्ये कार्ड नाहीत.';

  @override
  String get flashcards => 'फ्लॅशकार्ड';

  @override
  String get stylePhoto => 'फोटो';

  @override
  String get stylePhotoDesc => 'स्पष्ट छायाचित्र, वास्तवाच्या सर्वात जवळ';

  @override
  String get styleInk => 'ब्रश आणि शाई';

  @override
  String get styleInkDesc => 'ब्रशचे फटकारे, कोरा कागद, एका रंगाची छटा';

  @override
  String get stylePastel => 'पेस्टल';

  @override
  String get stylePastelDesc => 'रंगीत कागदावर कोरडे पेस्टल';

  @override
  String get styleWatercolor => 'जलरंग';

  @override
  String get styleWatercolorDesc => 'पसरणारे जलरंग, कागद दिसतो';

  @override
  String get styleFlag => 'ध्वज';

  @override
  String get styleFlagDesc => 'खरे राष्ट्रीय ध्वज';

  @override
  String get stylePonyCartoon => 'कार्टून';

  @override
  String get stylePonyCartoonDesc => 'रंगीबेरंगी कार्टून चित्र';

  @override
  String get styleStorybook => 'गोष्टींचे पुस्तक';

  @override
  String get styleStorybookDesc => 'मृदू पुस्तक चित्र';

  @override
  String get stylePonyWatercolor => 'जलरंग – मृदू';

  @override
  String get stylePonyWatercolorDesc => 'मृदू जलरंग चित्र';

  @override
  String get stylePonyOil => 'तैलचित्र';

  @override
  String get stylePonyOilDesc => 'कॅनव्हासवर जाड ब्रश फटकारे';

  @override
  String get styleIllustriousOil => 'तैलरंग – इम्पास्टो';

  @override
  String get styleIllustriousOilDesc => 'जाड इम्पास्टो रंग, प्रकाश-छाया';

  @override
  String get styleAnime => 'अ‍ॅनिमे';

  @override
  String get styleAnimeDesc => 'जपानी अ‍ॅनिमे चित्र';

  @override
  String get styleFlat => 'फ्लॅट व्हेक्टर';

  @override
  String get styleFlatDesc => 'सपाट रंग आणि स्वच्छ आकार';

  @override
  String get styleUkiyoe => 'उकियो-ए';

  @override
  String get styleUkiyoeDesc => 'जपानी लाकडी ठसा';

  @override
  String get styleMucha => 'आर्ट नूवो (मुखा)';

  @override
  String get styleMuchaDesc => 'सोनेरी छटांसह अलंकारिक आर्ट नूवो';

  @override
  String get styleVanGogh => 'व्हॅन गॉग';

  @override
  String get styleVanGoghDesc => 'पोस्ट-इम्प्रेशनिस्ट भोवऱ्यासारखे फटकारे';

  @override
  String get langAr => 'अरबी';

  @override
  String get langCs => 'चेक';

  @override
  String get langDe => 'जर्मन';

  @override
  String get langEl => 'ग्रीक';

  @override
  String get langEn => 'इंग्रजी';

  @override
  String get langEs419 => 'स्पॅनिश';

  @override
  String get langFr => 'फ्रेंच';

  @override
  String get langHe => 'हिब्रू';

  @override
  String get langHi => 'हिंदी';

  @override
  String get langId => 'इंडोनेशियन';

  @override
  String get langJa => 'जपानी';

  @override
  String get langKo => 'कोरियन';

  @override
  String get langPtBR => 'पोर्तुगीज';

  @override
  String get langRu => 'रशियन';

  @override
  String get langTr => 'तुर्की';

  @override
  String get langVi => 'व्हिएतनामी';

  @override
  String get langZhCN => 'चिनी';
}
