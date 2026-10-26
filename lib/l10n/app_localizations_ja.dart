// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'デッキストア';

  @override
  String get homeEmptyTitle => 'まだデッキがありません';

  @override
  String get homeReorderHint => 'デッキを長押ししてドラッグすると並べ替えられます';

  @override
  String get homeBrowseStore => 'デッキストアを見る';

  @override
  String get homeDownloadingDecks => 'デッキを準備しています…';

  @override
  String get badgeFree => '無料';

  @override
  String get badgeUnlocked => '解放済み';

  @override
  String get badgePurchased => '購入済み';

  @override
  String get badgePaidDeck => '有料デッキ';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count枚',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards枚',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs言語',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '覚えた $count';
  }

  @override
  String legendLearning(int count) {
    return '学習中 $count';
  }

  @override
  String legendUnknown(int count) {
    return '未学習 $count';
  }

  @override
  String get storeTitle => 'デッキストア';

  @override
  String get storeRestorePurchases => '購入を復元';

  @override
  String get storeSearchHint => 'デッキを検索…';

  @override
  String storeLoadError(String error) {
    return 'デッキを読み込めませんでした: $error';
  }

  @override
  String get storeNoDecks => '利用できるデッキがありません。';

  @override
  String get storeNothingFound => '見つかりませんでした。';

  @override
  String get retry => '再試行';

  @override
  String get buy => '購入';

  @override
  String buyFor(String price) {
    return '$priceで購入';
  }

  @override
  String get add => '追加';

  @override
  String get addFree => '無料で追加';

  @override
  String get back => '戻る';

  @override
  String get previous => '前へ';

  @override
  String get next => '次へ';

  @override
  String get study => '学習する';

  @override
  String get download => 'ダウンロード';

  @override
  String get confirmLanguagesLabel => '言語';

  @override
  String get styleSectionTitle => '画像スタイル';

  @override
  String get confirmBuyNote =>
      '購入するとデッキ全体が解放されます。すべての言語とすべてのスタイルが使えます。この組み合わせはホーム画面に追加されます。';

  @override
  String get confirmAddNote => 'この組み合わせはホーム画面に追加されます。ほかの言語やスタイルはいつでも追加できます。';

  @override
  String get purchaseFailedToStart => '購入を開始できませんでした。';

  @override
  String get addedToHome => 'ホーム画面に追加しました。';

  @override
  String get downloadFailed => 'ダウンロードに失敗しました。もう一度お試しください。';

  @override
  String get deckNotPurchased => 'このデッキはまだ購入されていません。';

  @override
  String downloading(int percent) {
    return 'ダウンロード中… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件使用中',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => '知ってる';

  @override
  String get pickerLearning => '学習中';

  @override
  String get reportIssue => '問題を報告';

  @override
  String get issueTranslation => '翻訳';

  @override
  String get issueImage => '画像';

  @override
  String get issuePronunciation => '発音';

  @override
  String get issueMeaning => '意味・事実';

  @override
  String get issueOther => 'その他';

  @override
  String get feedbackCommentHint => 'どこが間違っていますか？（任意）';

  @override
  String get feedbackSend => 'メールで送信';

  @override
  String feedbackNoMailApp(String email) {
    return 'メールアプリがありません。報告内容をクリップボードにコピーしました。$email 宛てに送ってください。';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] カードの問題 $key（$slug）';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'デッキ: $slug v$version（$title）';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'カード: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return '言語: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return '表示内容: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'スタイル: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return '問題の種類: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return '宛先: $email';
  }

  @override
  String get pronounce => '発音する';

  @override
  String get installVoice => '音声をインストール';

  @override
  String noVoiceInstalled(String lang) {
    return '「$lang」の音声がインストールされていません。「設定」→「アクセシビリティ」→「読み上げコンテンツ」→「声」で追加してから、もう一度お試しください。';
  }

  @override
  String get playPronunciation => '発音を再生';

  @override
  String get swipeNext => '次へ';

  @override
  String get swipeBack => '戻る';

  @override
  String get showTranslation => '訳を表示';

  @override
  String get showOriginal => '原文を表示';

  @override
  String get noCards => 'カードがありません';

  @override
  String get deckHasNoCards => 'このデッキにはカードがありません。';

  @override
  String get flashcards => 'フラッシュカード';

  @override
  String get stylePhoto => '写真';

  @override
  String get stylePhotoDesc => 'くっきりした写真。いちばん本物に近い';

  @override
  String get styleInk => '墨と筆';

  @override
  String get styleInkDesc => '筆のタッチと白い紙、差し色はひとつだけ';

  @override
  String get stylePastel => 'パステル';

  @override
  String get stylePastelDesc => '色紙に描いたソフトパステル';

  @override
  String get styleWatercolor => '水彩';

  @override
  String get styleWatercolorDesc => 'にじむ色と透ける紙';

  @override
  String get styleFlag => '国旗';

  @override
  String get styleFlagDesc => '本物の国旗';

  @override
  String get stylePonyCartoon => 'カートゥーン';

  @override
  String get stylePonyCartoonDesc => 'カラフルなカートゥーンイラスト';

  @override
  String get styleStorybook => '絵本';

  @override
  String get styleStorybookDesc => 'やわらかい絵本のイラスト';

  @override
  String get stylePonyWatercolor => '水彩（やわらか）';

  @override
  String get stylePonyWatercolorDesc => 'やさしい水彩画';

  @override
  String get stylePonyOil => '油絵';

  @override
  String get stylePonyOilDesc => 'キャンバスに厚い筆づかい';

  @override
  String get styleIllustriousOil => '油絵（厚塗り）';

  @override
  String get styleIllustriousOilDesc => '厚塗りの絵の具と明暗のコントラスト';

  @override
  String get styleAnime => 'アニメ';

  @override
  String get styleAnimeDesc => '日本のアニメ風イラスト';

  @override
  String get styleFlat => 'フラットデザイン';

  @override
  String get styleFlatDesc => 'ベタ塗りとすっきりした形';

  @override
  String get styleUkiyoe => '浮世絵';

  @override
  String get styleUkiyoeDesc => '日本の木版画';

  @override
  String get styleMucha => 'アール・ヌーヴォー（ミュシャ）';

  @override
  String get styleMuchaDesc => '金色をあしらった装飾的なアール・ヌーヴォー';

  @override
  String get styleVanGogh => 'ゴッホ';

  @override
  String get styleVanGoghDesc => 'うねるような後期印象派の筆づかい';

  @override
  String get langAr => 'アラビア語';

  @override
  String get langCs => 'チェコ語';

  @override
  String get langDe => 'ドイツ語';

  @override
  String get langEl => 'ギリシャ語';

  @override
  String get langEn => '英語';

  @override
  String get langEs419 => 'スペイン語';

  @override
  String get langFr => 'フランス語';

  @override
  String get langHe => 'ヘブライ語';

  @override
  String get langHi => 'ヒンディー語';

  @override
  String get langId => 'インドネシア語';

  @override
  String get langJa => '日本語';

  @override
  String get langKo => '韓国語';

  @override
  String get langPtBR => 'ポルトガル語';

  @override
  String get langRu => 'ロシア語';

  @override
  String get langTr => 'トルコ語';

  @override
  String get langVi => 'ベトナム語';

  @override
  String get langZhCN => '中国語';
}
