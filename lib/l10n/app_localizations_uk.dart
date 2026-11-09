// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Магазин колод';

  @override
  String get homeEmptyTitle => 'Колод поки немає';

  @override
  String get homeReorderHint =>
      'Утримуйте колоду й перетягніть, щоб змінити порядок';

  @override
  String get homeBrowseStore => 'Відкрити магазин колод';

  @override
  String get homeDownloadingDecks => 'Готуємо ваші колоди…';

  @override
  String get badgeFree => 'Безкоштовно';

  @override
  String get badgeUnlocked => 'Розблоковано';

  @override
  String get badgePurchased => 'Придбано';

  @override
  String get badgePaidDeck => 'Платна колода';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count картки',
      many: '$count карток',
      few: '$count картки',
      one: '$count картка',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards картки',
      many: '$cards карток',
      few: '$cards картки',
      one: '$cards картка',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs мови',
      many: '$langs мов',
      few: '$langs мови',
      one: '$langs мова',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return 'Знаю: $count';
  }

  @override
  String legendLearning(int count) {
    return 'Вивчаю: $count';
  }

  @override
  String legendUnknown(int count) {
    return 'Не знаю: $count';
  }

  @override
  String get storeTitle => 'Магазин колод';

  @override
  String get storeRestorePurchases => 'Відновити покупки';

  @override
  String get storeSearchHint => 'Пошук колод…';

  @override
  String storeLoadError(String error) {
    return 'Не вдалося завантажити колоди: $error';
  }

  @override
  String get storeNoDecks => 'Немає доступних колод.';

  @override
  String get storeNothingFound => 'Нічого не знайдено.';

  @override
  String get retry => 'Повторити';

  @override
  String get buy => 'Купити';

  @override
  String buyFor(String price) {
    return 'Купити за $price';
  }

  @override
  String get add => 'Додати';

  @override
  String get addFree => 'Додати безкоштовно';

  @override
  String get back => 'Назад';

  @override
  String get previous => 'Попередня';

  @override
  String get next => 'Далі';

  @override
  String get study => 'Вчити';

  @override
  String get download => 'Завантажити';

  @override
  String get confirmLanguagesLabel => 'Мови';

  @override
  String get styleSectionTitle => 'Стиль зображень';

  @override
  String get confirmBuyNote =>
      'Покупка відкриває всю колоду — усі мови й усі стилі. Ця комбінація з’явиться на головному екрані.';

  @override
  String get confirmAddNote =>
      'Ця комбінація з’явиться на головному екрані. Іншу мову чи стиль можна додати будь-коли.';

  @override
  String get purchaseFailedToStart => 'Не вдалося розпочати покупку.';

  @override
  String get addedToHome => 'Додано на головний екран.';

  @override
  String get downloadFailed => 'Не вдалося завантажити. Спробуйте ще раз.';

  @override
  String get deckNotPurchased => 'Цю колоду не придбано.';

  @override
  String downloading(int percent) {
    return 'Завантаження… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count активної',
      many: '$count активних',
      few: '$count активні',
      one: '$count активна',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Знаю';

  @override
  String get pickerLearning => 'Вивчаю';

  @override
  String get reportIssue => 'Повідомити про проблему';

  @override
  String get issueTranslation => 'Переклад';

  @override
  String get issueImage => 'Зображення';

  @override
  String get issuePronunciation => 'Вимова';

  @override
  String get issueMeaning => 'Значення / факти';

  @override
  String get issueOther => 'Інше';

  @override
  String get feedbackCommentHint => 'Що не так? (необов’язково)';

  @override
  String get feedbackSend => 'Надіслати e-mail';

  @override
  String feedbackNoMailApp(String email) {
    return 'Немає поштового застосунку. Звіт скопійовано в буфер обміну — надішліть його на $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Проблема з карткою $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Колода: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Картка: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Мови: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Показано: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Стиль: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Тип проблеми: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'Кому: $email';
  }

  @override
  String get pronounce => 'Вимовити';

  @override
  String get installVoice => 'Установити голос';

  @override
  String noVoiceInstalled(String lang) {
    return 'Голос для «$lang» не встановлено. Додайте його в Параметрах → Доступність → Мовлення → Голоси й спробуйте ще раз.';
  }

  @override
  String get playPronunciation => 'Відтворити вимову';

  @override
  String get swipeNext => 'ДАЛІ';

  @override
  String get swipeBack => 'НАЗАД';

  @override
  String get showTranslation => 'Показати переклад';

  @override
  String get showOriginal => 'Показати оригінал';

  @override
  String get noCards => 'Немає карток';

  @override
  String get deckHasNoCards => 'У цій колоді немає карток.';

  @override
  String get flashcards => 'Картки';

  @override
  String get stylePhoto => 'Фото';

  @override
  String get stylePhotoDesc => 'Чітка фотографія, найближча до реальності';

  @override
  String get styleInk => 'Пензель і туш';

  @override
  String get styleInkDesc =>
      'Мазки пензля, чистий папір, один кольоровий акцент';

  @override
  String get stylePastel => 'Пастель';

  @override
  String get stylePastelDesc => 'Суха пастель на тонованому папері';

  @override
  String get styleWatercolor => 'Акварель';

  @override
  String get styleWatercolorDesc => 'Розмиті плями, крізь які видно папір';

  @override
  String get styleFlag => 'Прапори';

  @override
  String get styleFlagDesc => 'Справжні державні прапори';

  @override
  String get stylePonyCartoon => 'Мультфільм';

  @override
  String get stylePonyCartoonDesc => 'Яскрава мультяшна ілюстрація';

  @override
  String get styleStorybook => 'Казкова книжка';

  @override
  String get styleStorybookDesc => 'М’яка книжкова ілюстрація';

  @override
  String get stylePonyWatercolor => 'Акварель – м’яка';

  @override
  String get stylePonyWatercolorDesc => 'Ніжний акварельний живопис';

  @override
  String get stylePonyOil => 'Олійний живопис';

  @override
  String get stylePonyOilDesc => 'Густі мазки пензля на полотні';

  @override
  String get styleIllustriousOil => 'Олія – імпасто';

  @override
  String get styleIllustriousOilDesc => 'Щільна фактурна фарба, світлотінь';

  @override
  String get styleAnime => 'Аніме';

  @override
  String get styleAnimeDesc => 'Японський аніме-малюнок';

  @override
  String get styleFlat => 'Плаский вектор';

  @override
  String get styleFlatDesc => 'Пласкі кольори й чисті форми';

  @override
  String get styleUkiyoe => 'Укійо-е';

  @override
  String get styleUkiyoeDesc => 'Японська гравюра на дереві';

  @override
  String get styleMucha => 'Модерн (Муха)';

  @override
  String get styleMuchaDesc => 'Орнаментальний модерн із золотими акцентами';

  @override
  String get styleVanGogh => 'Ван Гог';

  @override
  String get styleVanGoghDesc => 'Постімпресіоністські закручені мазки';

  @override
  String get langAr => 'Арабська';

  @override
  String get langCs => 'Чеська';

  @override
  String get langDe => 'Німецька';

  @override
  String get langEl => 'Грецька';

  @override
  String get langEn => 'Англійська';

  @override
  String get langEs419 => 'Іспанська';

  @override
  String get langFr => 'Французька';

  @override
  String get langHe => 'Іврит';

  @override
  String get langHi => 'Гінді';

  @override
  String get langId => 'Індонезійська';

  @override
  String get langJa => 'Японська';

  @override
  String get langKo => 'Корейська';

  @override
  String get langPtBR => 'Португальська';

  @override
  String get langRu => 'Російська';

  @override
  String get langTr => 'Турецька';

  @override
  String get langVi => 'В’єтнамська';

  @override
  String get langZhCN => 'Китайська';
}
