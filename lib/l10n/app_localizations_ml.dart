// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'ഡെക്ക് സ്റ്റോർ';

  @override
  String get homeEmptyTitle => 'ഇതുവരെ ഡെക്കുകളൊന്നുമില്ല';

  @override
  String get homeReorderHint =>
      'ക്രമം മാറ്റാൻ ഒരു ഡെക്ക് അമർത്തിപ്പിടിച്ച് വലിക്കുക';

  @override
  String get homeBrowseStore => 'ഡെക്ക് സ്റ്റോർ കാണുക';

  @override
  String get homeDownloadingDecks => 'നിങ്ങളുടെ ഡെക്കുകൾ തയ്യാറാക്കുന്നു…';

  @override
  String get badgeFree => 'സൗജന്യം';

  @override
  String get badgeUnlocked => 'അൺലോക്ക് ചെയ്തു';

  @override
  String get badgePurchased => 'വാങ്ങിയത്';

  @override
  String get badgePaidDeck => 'പണമടച്ചുള്ള ഡെക്ക്';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count കാർഡുകൾ',
      one: '1 കാർഡ്',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards കാർഡുകൾ',
      one: '1 കാർഡ്',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs ഭാഷകൾ',
      one: '1 ഭാഷ',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count അറിയാവുന്നവ';
  }

  @override
  String legendLearning(int count) {
    return '$count പഠിക്കുന്നവ';
  }

  @override
  String legendUnknown(int count) {
    return '$count അറിയാത്തവ';
  }

  @override
  String get storeTitle => 'ഡെക്ക് സ്റ്റോർ';

  @override
  String get storeRestorePurchases => 'വാങ്ങലുകൾ പുനഃസ്ഥാപിക്കുക';

  @override
  String get storeSearchHint => 'ഡെക്കുകൾ തിരയുക…';

  @override
  String storeLoadError(String error) {
    return 'ഡെക്കുകൾ ലോഡ് ചെയ്യാനായില്ല: $error';
  }

  @override
  String get storeNoDecks => 'ഡെക്കുകളൊന്നും ലഭ്യമല്ല.';

  @override
  String get storeNothingFound => 'ഒന്നും കണ്ടെത്തിയില്ല.';

  @override
  String get retry => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String get buy => 'വാങ്ങുക';

  @override
  String buyFor(String price) {
    return '$price-ന് വാങ്ങുക';
  }

  @override
  String get add => 'ചേർക്കുക';

  @override
  String get addFree => 'സൗജന്യമായി ചേർക്കുക';

  @override
  String get back => 'തിരികെ';

  @override
  String get previous => 'മുമ്പത്തേത്';

  @override
  String get next => 'അടുത്തത്';

  @override
  String get study => 'പഠിക്കുക';

  @override
  String get download => 'ഡൗൺലോഡ്';

  @override
  String get confirmLanguagesLabel => 'ഭാഷകൾ';

  @override
  String get styleSectionTitle => 'ചിത്ര ശൈലി';

  @override
  String get confirmBuyNote =>
      'വാങ്ങുന്നതോടെ മുഴുവൻ ഡെക്കും അൺലോക്ക് ആകും — എല്ലാ ഭാഷകളും എല്ലാ ശൈലികളും. ഈ സംയോജനം നിങ്ങളുടെ ഹോം സ്ക്രീനിൽ ചേർക്കും.';

  @override
  String get confirmAddNote =>
      'ഈ സംയോജനം നിങ്ങളുടെ ഹോം സ്ക്രീനിൽ ചേർക്കും. എപ്പോൾ വേണമെങ്കിലും മറ്റൊരു ഭാഷയോ ശൈലിയോ ചേർക്കാം.';

  @override
  String get purchaseFailedToStart => 'വാങ്ങൽ ആരംഭിക്കാനായില്ല.';

  @override
  String get addedToHome => 'ഹോം സ്ക്രീനിൽ ചേർത്തു.';

  @override
  String get downloadFailed =>
      'ഡൗൺലോഡ് പരാജയപ്പെട്ടു. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get deckNotPurchased => 'ഈ ഡെക്ക് വാങ്ങിയിട്ടില്ല.';

  @override
  String downloading(int percent) {
    return 'ഡൗൺലോഡ് ചെയ്യുന്നു… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count സജീവം',
      one: '1 സജീവം',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'എനിക്കറിയാം';

  @override
  String get pickerLearning => 'പഠിക്കുന്നു';

  @override
  String get reportIssue => 'പ്രശ്നം റിപ്പോർട്ട് ചെയ്യുക';

  @override
  String get issueTranslation => 'വിവർത്തനം';

  @override
  String get issueImage => 'ചിത്രം';

  @override
  String get issuePronunciation => 'ഉച്ചാരണം';

  @override
  String get issueMeaning => 'അർത്ഥം / വസ്തുതകൾ';

  @override
  String get issueOther => 'മറ്റുള്ളവ';

  @override
  String get feedbackCommentHint => 'എന്താണ് തെറ്റ്? (ഓപ്ഷണൽ)';

  @override
  String get feedbackSend => 'ഇ-മെയിൽ വഴി അയയ്ക്കുക';

  @override
  String feedbackNoMailApp(String email) {
    return 'ഇ-മെയിൽ ആപ്പൊന്നും ലഭ്യമല്ല. റിപ്പോർട്ട് ക്ലിപ്പ്ബോർഡിലേക്ക് പകർത്തി — ദയവായി അത് $email-ലേക്ക് അയയ്ക്കുക.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] കാർഡ് പ്രശ്നം $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'ഡെക്ക്: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'കാർഡ്: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'ഭാഷകൾ: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'കാണിച്ചത്: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'ശൈലി: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'പ്രശ്നത്തിന്റെ തരം: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'സ്വീകർത്താവ്: $email';
  }

  @override
  String get pronounce => 'ഉച്ചരിക്കുക';

  @override
  String get installVoice => 'ശബ്ദം ഇൻസ്റ്റാൾ ചെയ്യുക';

  @override
  String noVoiceInstalled(String lang) {
    return '\"$lang\"-നായി ശബ്ദമൊന്നും ഇൻസ്റ്റാൾ ചെയ്തിട്ടില്ല. ക്രമീകരണങ്ങൾ → പ്രവേശനക്ഷമത → സംസാരിക്കുന്ന ഉള്ളടക്കം → ശബ്ദങ്ങൾ എന്നതിൽ ഒന്ന് ചേർത്ത് വീണ്ടും ശ്രമിക്കുക.';
  }

  @override
  String get playPronunciation => 'ഉച്ചാരണം കേൾക്കുക';

  @override
  String get swipeNext => 'അടുത്തത്';

  @override
  String get swipeBack => 'തിരികെ';

  @override
  String get showTranslation => 'വിവർത്തനം കാണിക്കുക';

  @override
  String get showOriginal => 'മൂലം കാണിക്കുക';

  @override
  String get noCards => 'കാർഡുകളില്ല';

  @override
  String get deckHasNoCards => 'ഈ ഡെക്കിൽ കാർഡുകളില്ല.';

  @override
  String get flashcards => 'ഫ്ലാഷ് കാർഡുകൾ';

  @override
  String get stylePhoto => 'ഫോട്ടോ';

  @override
  String get stylePhotoDesc =>
      'വ്യക്തമായ ഫോട്ടോ, യാഥാർത്ഥ്യത്തോട് ഏറ്റവും അടുത്ത്';

  @override
  String get styleInk => 'ബ്രഷും മഷിയും';

  @override
  String get styleInkDesc =>
      'ബ്രഷ് വരകൾ, ഒഴിഞ്ഞ കടലാസ്, ഒരു നിറത്തിന്റെ സ്പർശം';

  @override
  String get stylePastel => 'പാസ്റ്റൽ';

  @override
  String get stylePastelDesc => 'നിറമുള്ള കടലാസിൽ ഉണങ്ങിയ പാസ്റ്റൽ';

  @override
  String get styleWatercolor => 'ജലച്ചായം';

  @override
  String get styleWatercolorDesc => 'പടരുന്ന ജലച്ചായം, കടലാസ് തെളിയുന്നു';

  @override
  String get styleFlag => 'പതാകകൾ';

  @override
  String get styleFlagDesc => 'യഥാർത്ഥ ദേശീയ പതാകകൾ';

  @override
  String get stylePonyCartoon => 'കാർട്ടൂൺ';

  @override
  String get stylePonyCartoonDesc => 'വർണ്ണാഭമായ കാർട്ടൂൺ ചിത്രം';

  @override
  String get styleStorybook => 'കഥാപുസ്തകം';

  @override
  String get styleStorybookDesc => 'മൃദുവായ പുസ്തക ചിത്രീകരണം';

  @override
  String get stylePonyWatercolor => 'ജലച്ചായം – മൃദു';

  @override
  String get stylePonyWatercolorDesc => 'മൃദുവായ ജലച്ചായ ചിത്രം';

  @override
  String get stylePonyOil => 'എണ്ണച്ചായ ചിത്രം';

  @override
  String get stylePonyOilDesc => 'ക്യാൻവാസിൽ കട്ടിയുള്ള ബ്രഷ് വരകൾ';

  @override
  String get styleIllustriousOil => 'എണ്ണ – ഇംപാസ്റ്റോ';

  @override
  String get styleIllustriousOilDesc =>
      'കട്ടിയുള്ള ഇംപാസ്റ്റോ ചായം, വെളിച്ചവും നിഴലും';

  @override
  String get styleAnime => 'ആനിമെ';

  @override
  String get styleAnimeDesc => 'ജാപ്പനീസ് ആനിമെ ചിത്രം';

  @override
  String get styleFlat => 'ഫ്ലാറ്റ് വെക്ടർ';

  @override
  String get styleFlatDesc => 'പരന്ന നിറങ്ങൾ, വൃത്തിയുള്ള രൂപങ്ങൾ';

  @override
  String get styleUkiyoe => 'ഉകിയോ-എ';

  @override
  String get styleUkiyoeDesc => 'ജാപ്പനീസ് മരയച്ച്';

  @override
  String get styleMucha => 'ആർട്ട് നൂവോ (മുഹ)';

  @override
  String get styleMuchaDesc => 'സ്വർണ്ണ സ്പർശമുള്ള അലങ്കാര ആർട്ട് നൂവോ';

  @override
  String get styleVanGogh => 'വാൻ ഗോഗ്';

  @override
  String get styleVanGoghDesc => 'പോസ്റ്റ്-ഇംപ്രഷനിസ്റ്റ് ചുഴി വരകൾ';

  @override
  String get langAr => 'അറബിക്';

  @override
  String get langCs => 'ചെക്ക്';

  @override
  String get langDe => 'ജർമ്മൻ';

  @override
  String get langEl => 'ഗ്രീക്ക്';

  @override
  String get langEn => 'ഇംഗ്ലീഷ്';

  @override
  String get langEs419 => 'സ്പാനിഷ്';

  @override
  String get langFr => 'ഫ്രഞ്ച്';

  @override
  String get langHe => 'ഹീബ്രു';

  @override
  String get langHi => 'ഹിന്ദി';

  @override
  String get langId => 'ഇന്തോനേഷ്യൻ';

  @override
  String get langJa => 'ജാപ്പനീസ്';

  @override
  String get langKo => 'കൊറിയൻ';

  @override
  String get langPtBR => 'പോർച്ചുഗീസ്';

  @override
  String get langRu => 'റഷ്യൻ';

  @override
  String get langTr => 'ടർക്കിഷ്';

  @override
  String get langVi => 'വിയറ്റ്നാമീസ്';

  @override
  String get langZhCN => 'ചൈനീസ്';
}
