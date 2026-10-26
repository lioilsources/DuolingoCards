// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Магазин колод';

  @override
  String get homeEmptyTitle => 'Колод пока нет';

  @override
  String get homeReorderHint =>
      'Удерживайте колоду и перетащите, чтобы изменить порядок';

  @override
  String get homeBrowseStore => 'Открыть магазин колод';

  @override
  String get homeDownloadingDecks => 'Готовим ваши колоды…';

  @override
  String get badgeFree => 'Бесплатно';

  @override
  String get badgeUnlocked => 'Открыто';

  @override
  String get badgePurchased => 'Куплено';

  @override
  String get badgePaidDeck => 'Платная колода';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count карточки',
      many: '$count карточек',
      few: '$count карточки',
      one: '$count карточка',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards карточки',
      many: '$cards карточек',
      few: '$cards карточки',
      one: '$cards карточка',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs языка',
      many: '$langs языков',
      few: '$langs языка',
      one: '$langs язык',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return 'Знаю: $count';
  }

  @override
  String legendLearning(int count) {
    return 'Учу: $count';
  }

  @override
  String legendUnknown(int count) {
    return 'Не знаю: $count';
  }

  @override
  String get storeTitle => 'Магазин колод';

  @override
  String get storeRestorePurchases => 'Восстановить покупки';

  @override
  String get storeSearchHint => 'Поиск колод…';

  @override
  String storeLoadError(String error) {
    return 'Не удалось загрузить колоды: $error';
  }

  @override
  String get storeNoDecks => 'Нет доступных колод.';

  @override
  String get storeNothingFound => 'Ничего не найдено.';

  @override
  String get retry => 'Повторить';

  @override
  String get buy => 'Купить';

  @override
  String buyFor(String price) {
    return 'Купить за $price';
  }

  @override
  String get add => 'Добавить';

  @override
  String get addFree => 'Добавить бесплатно';

  @override
  String get back => 'Назад';

  @override
  String get previous => 'Назад';

  @override
  String get next => 'Далее';

  @override
  String get study => 'Учить';

  @override
  String get download => 'Скачать';

  @override
  String get confirmLanguagesLabel => 'Языки';

  @override
  String get styleSectionTitle => 'Стиль картинок';

  @override
  String get confirmBuyNote =>
      'Покупка открывает всю колоду — все языки и все стили. Эта комбинация появится на главном экране.';

  @override
  String get confirmAddNote =>
      'Эта комбинация появится на главном экране. Другой язык или стиль можно добавить в любое время.';

  @override
  String get purchaseFailedToStart => 'Не удалось начать покупку.';

  @override
  String get addedToHome => 'Добавлено на главный экран.';

  @override
  String get downloadFailed => 'Не удалось скачать. Попробуйте ещё раз.';

  @override
  String get deckNotPurchased => 'Эта колода не куплена.';

  @override
  String downloading(int percent) {
    return 'Загрузка… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count активны',
      many: '$count активны',
      few: '$count активны',
      one: '$count активна',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Знаю';

  @override
  String get pickerLearning => 'Учу';

  @override
  String get reportIssue => 'Сообщить о проблеме';

  @override
  String get issueTranslation => 'Перевод';

  @override
  String get issueImage => 'Картинка';

  @override
  String get issuePronunciation => 'Произношение';

  @override
  String get issueMeaning => 'Значение / факты';

  @override
  String get issueOther => 'Другое';

  @override
  String get feedbackCommentHint => 'Что не так? (необязательно)';

  @override
  String get feedbackSend => 'Отправить по почте';

  @override
  String feedbackNoMailApp(String email) {
    return 'Нет почтового приложения. Сообщение скопировано в буфер обмена — отправьте его на $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Проблема с карточкой $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Колода: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Карточка: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Языки: $l1 → $l2';
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
    return 'Тип проблемы: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'Кому: $email';
  }

  @override
  String get pronounce => 'Произнести';

  @override
  String get installVoice => 'Установить голос';

  @override
  String noVoiceInstalled(String lang) {
    return 'Голос для языка «$lang» не установлен. Добавьте его в «Настройки» → «Универсальный доступ» → «Устный контент» → «Голоса» и попробуйте снова.';
  }

  @override
  String get playPronunciation => 'Воспроизвести произношение';

  @override
  String get swipeNext => 'ДАЛЕЕ';

  @override
  String get swipeBack => 'НАЗАД';

  @override
  String get showTranslation => 'Показать перевод';

  @override
  String get showOriginal => 'Показать оригинал';

  @override
  String get noCards => 'Нет карточек';

  @override
  String get deckHasNoCards => 'В этой колоде нет карточек.';

  @override
  String get flashcards => 'Карточки';

  @override
  String get stylePhoto => 'Фото';

  @override
  String get stylePhotoDesc => 'Чёткая фотография, ближе всего к жизни';

  @override
  String get styleInk => 'Кисть и тушь';

  @override
  String get styleInkDesc => 'Мазки кисти, чистая бумага, один цветной акцент';

  @override
  String get stylePastel => 'Пастель';

  @override
  String get stylePastelDesc => 'Сухая пастель на тонированной бумаге';

  @override
  String get styleWatercolor => 'Акварель';

  @override
  String get styleWatercolorDesc =>
      'Растекающиеся заливки, сквозь них видна бумага';

  @override
  String get styleFlag => 'Флаги';

  @override
  String get styleFlagDesc => 'Настоящие государственные флаги';

  @override
  String get stylePonyCartoon => 'Мультяшный';

  @override
  String get stylePonyCartoonDesc => 'Яркая мультяшная иллюстрация';

  @override
  String get styleStorybook => 'Книжка с картинками';

  @override
  String get styleStorybookDesc => 'Мягкая книжная иллюстрация';

  @override
  String get stylePonyWatercolor => 'Акварель – мягкая';

  @override
  String get stylePonyWatercolorDesc => 'Нежная акварельная живопись';

  @override
  String get stylePonyOil => 'Масляная живопись';

  @override
  String get stylePonyOilDesc => 'Густые мазки на холсте';

  @override
  String get styleIllustriousOil => 'Масло – импасто';

  @override
  String get styleIllustriousOilDesc => 'Плотная пастозная краска, светотень';

  @override
  String get styleAnime => 'Аниме';

  @override
  String get styleAnimeDesc => 'Японский рисунок в стиле аниме';

  @override
  String get styleFlat => 'Плоский вектор';

  @override
  String get styleFlatDesc => 'Плоские цвета и чистые формы';

  @override
  String get styleUkiyoe => 'Укиё-э';

  @override
  String get styleUkiyoeDesc => 'Японская ксилография';

  @override
  String get styleMucha => 'Модерн (Муха)';

  @override
  String get styleMuchaDesc => 'Орнаментальный модерн с золотыми акцентами';

  @override
  String get styleVanGogh => 'Ван Гог';

  @override
  String get styleVanGoghDesc => 'Постимпрессионистские вихревые мазки';

  @override
  String get langAr => 'Арабский';

  @override
  String get langCs => 'Чешский';

  @override
  String get langDe => 'Немецкий';

  @override
  String get langEl => 'Греческий';

  @override
  String get langEn => 'Английский';

  @override
  String get langEs419 => 'Испанский';

  @override
  String get langFr => 'Французский';

  @override
  String get langHe => 'Иврит';

  @override
  String get langHi => 'Хинди';

  @override
  String get langId => 'Индонезийский';

  @override
  String get langJa => 'Японский';

  @override
  String get langKo => 'Корейский';

  @override
  String get langPtBR => 'Португальский';

  @override
  String get langRu => 'Русский';

  @override
  String get langTr => 'Турецкий';

  @override
  String get langVi => 'Вьетнамский';

  @override
  String get langZhCN => 'Китайский';
}
