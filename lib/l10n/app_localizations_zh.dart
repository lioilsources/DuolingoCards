// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => '卡组商店';

  @override
  String get homeEmptyTitle => '还没有卡组';

  @override
  String get homeReorderHint => '长按卡组并拖动即可调整顺序';

  @override
  String get homeBrowseStore => '逛逛卡组商店';

  @override
  String get homeDownloadingDecks => '正在准备你的卡组…';

  @override
  String get badgeFree => '免费';

  @override
  String get badgeUnlocked => '已解锁';

  @override
  String get badgePurchased => '已购买';

  @override
  String get badgePaidDeck => '付费卡组';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 张卡片',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards 张卡片',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs 种语言',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '已掌握 $count';
  }

  @override
  String legendLearning(int count) {
    return '学习中 $count';
  }

  @override
  String legendUnknown(int count) {
    return '未学 $count';
  }

  @override
  String get storeTitle => '卡组商店';

  @override
  String get storeRestorePurchases => '恢复购买';

  @override
  String get storeSearchHint => '搜索卡组…';

  @override
  String storeLoadError(String error) {
    return '无法加载卡组：$error';
  }

  @override
  String get storeNoDecks => '暂无可用卡组。';

  @override
  String get storeNothingFound => '没有找到结果。';

  @override
  String get retry => '重试';

  @override
  String get buy => '购买';

  @override
  String buyFor(String price) {
    return '$price 购买';
  }

  @override
  String get add => '添加';

  @override
  String get addFree => '免费添加';

  @override
  String get back => '返回';

  @override
  String get previous => '上一张';

  @override
  String get next => '下一张';

  @override
  String get study => '学习';

  @override
  String get download => '下载';

  @override
  String get confirmLanguagesLabel => '语言';

  @override
  String get styleSectionTitle => '图片风格';

  @override
  String get confirmBuyNote => '购买后将解锁整个卡组——所有语言和所有风格。这个组合会添加到你的主屏幕。';

  @override
  String get confirmAddNote => '这个组合会添加到你的主屏幕。你可以随时再添加其他语言或风格。';

  @override
  String get purchaseFailedToStart => '无法开始购买。';

  @override
  String get addedToHome => '已添加到主屏幕。';

  @override
  String get downloadFailed => '下载失败，请重试。';

  @override
  String get deckNotPurchased => '尚未购买此卡组。';

  @override
  String downloading(int percent) {
    return '正在下载… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个使用中',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => '我会了';

  @override
  String get pickerLearning => '学习中';

  @override
  String get reportIssue => '报告问题';

  @override
  String get issueTranslation => '翻译';

  @override
  String get issueImage => '图片';

  @override
  String get issuePronunciation => '发音';

  @override
  String get issueMeaning => '含义 / 事实';

  @override
  String get issueOther => '其他';

  @override
  String get feedbackCommentHint => '哪里有问题？（选填）';

  @override
  String get feedbackSend => '通过邮件发送';

  @override
  String feedbackNoMailApp(String email) {
    return '没有可用的邮件应用。报告已复制到剪贴板，请发送至 $email。';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] 卡片问题 $key（$slug）';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return '卡组：$slug v$version（$title）';
  }

  @override
  String feedbackBodyCard(String key) {
    return '卡片：$key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return '语言：$l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return '显示内容：$foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return '风格：$style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return '问题类型：$issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return '收件人：$email';
  }

  @override
  String get pronounce => '发音';

  @override
  String get installVoice => '安装语音';

  @override
  String noVoiceInstalled(String lang) {
    return '尚未安装“$lang”语音。请前往“设置”→“辅助功能”→“朗读内容”→“声音”添加，然后重试。';
  }

  @override
  String get playPronunciation => '播放发音';

  @override
  String get swipeNext => '下一张';

  @override
  String get swipeBack => '返回';

  @override
  String get showTranslation => '显示译文';

  @override
  String get showOriginal => '显示原文';

  @override
  String get noCards => '没有卡片';

  @override
  String get deckHasNoCards => '此卡组没有卡片。';

  @override
  String get flashcards => '抽认卡';

  @override
  String get stylePhoto => '照片';

  @override
  String get stylePhotoDesc => '清晰的照片，最接近真实';

  @override
  String get styleInk => '水墨';

  @override
  String get styleInkDesc => '笔触、留白，一点色彩点缀';

  @override
  String get stylePastel => '色粉画';

  @override
  String get stylePastelDesc => '彩色纸上的干色粉';

  @override
  String get styleWatercolor => '水彩';

  @override
  String get styleWatercolorDesc => '晕染的色彩，透出纸张';

  @override
  String get styleFlag => '国旗';

  @override
  String get styleFlagDesc => '真实的国旗';

  @override
  String get stylePonyCartoon => '卡通';

  @override
  String get stylePonyCartoonDesc => '色彩缤纷的卡通插画';

  @override
  String get styleStorybook => '绘本';

  @override
  String get styleStorybookDesc => '柔和的绘本插画';

  @override
  String get stylePonyWatercolor => '水彩 – 柔和';

  @override
  String get stylePonyWatercolorDesc => '柔和的水彩画';

  @override
  String get stylePonyOil => '油画';

  @override
  String get stylePonyOilDesc => '画布上的厚重笔触';

  @override
  String get styleIllustriousOil => '油画 – 厚涂';

  @override
  String get styleIllustriousOilDesc => '厚涂颜料，明暗对比';

  @override
  String get styleAnime => '动漫';

  @override
  String get styleAnimeDesc => '日本动漫画风';

  @override
  String get styleFlat => '扁平矢量';

  @override
  String get styleFlatDesc => '纯色块，简洁造型';

  @override
  String get styleUkiyoe => '浮世绘';

  @override
  String get styleUkiyoeDesc => '日本木版画';

  @override
  String get styleMucha => '新艺术（慕夏）';

  @override
  String get styleMuchaDesc => '带金色点缀的装饰性新艺术风格';

  @override
  String get styleVanGogh => '梵高';

  @override
  String get styleVanGoghDesc => '后印象派的旋转笔触';

  @override
  String get langAr => '阿拉伯语';

  @override
  String get langCs => '捷克语';

  @override
  String get langDe => '德语';

  @override
  String get langEl => '希腊语';

  @override
  String get langEn => '英语';

  @override
  String get langEs419 => '西班牙语';

  @override
  String get langFr => '法语';

  @override
  String get langHe => '希伯来语';

  @override
  String get langHi => '印地语';

  @override
  String get langId => '印度尼西亚语';

  @override
  String get langJa => '日语';

  @override
  String get langKo => '韩语';

  @override
  String get langPtBR => '葡萄牙语';

  @override
  String get langRu => '俄语';

  @override
  String get langTr => '土耳其语';

  @override
  String get langVi => '越南语';

  @override
  String get langZhCN => '中文';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => '卡組商店';

  @override
  String get homeEmptyTitle => '還沒有卡組';

  @override
  String get homeReorderHint => '長按卡組並拖曳即可調整順序';

  @override
  String get homeBrowseStore => '逛逛卡組商店';

  @override
  String get homeDownloadingDecks => '正在準備你的卡組…';

  @override
  String get badgeFree => '免費';

  @override
  String get badgeUnlocked => '已解鎖';

  @override
  String get badgePurchased => '已購買';

  @override
  String get badgePaidDeck => '付費卡組';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 張卡片',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards 張卡片',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs 種語言',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '已學會 $count';
  }

  @override
  String legendLearning(int count) {
    return '學習中 $count';
  }

  @override
  String legendUnknown(int count) {
    return '未學 $count';
  }

  @override
  String get storeTitle => '卡組商店';

  @override
  String get storeRestorePurchases => '回復購買項目';

  @override
  String get storeSearchHint => '搜尋卡組…';

  @override
  String storeLoadError(String error) {
    return '無法載入卡組：$error';
  }

  @override
  String get storeNoDecks => '目前沒有可用的卡組。';

  @override
  String get storeNothingFound => '找不到結果。';

  @override
  String get retry => '重試';

  @override
  String get buy => '購買';

  @override
  String buyFor(String price) {
    return '以 $price 購買';
  }

  @override
  String get add => '加入';

  @override
  String get addFree => '免費加入';

  @override
  String get back => '返回';

  @override
  String get previous => '上一張';

  @override
  String get next => '下一張';

  @override
  String get study => '學習';

  @override
  String get download => '下載';

  @override
  String get confirmLanguagesLabel => '語言';

  @override
  String get styleSectionTitle => '圖片風格';

  @override
  String get confirmBuyNote => '購買後會解鎖整個卡組——所有語言和所有風格。這個組合會加入你的主畫面。';

  @override
  String get confirmAddNote => '這個組合會加入你的主畫面。你隨時都能再加入其他語言或風格。';

  @override
  String get purchaseFailedToStart => '無法開始購買。';

  @override
  String get addedToHome => '已加入主畫面。';

  @override
  String get downloadFailed => '下載失敗，請再試一次。';

  @override
  String get deckNotPurchased => '尚未購買這個卡組。';

  @override
  String downloading(int percent) {
    return '正在下載… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個使用中',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => '我會了';

  @override
  String get pickerLearning => '學習中';

  @override
  String get reportIssue => '回報問題';

  @override
  String get issueTranslation => '翻譯';

  @override
  String get issueImage => '圖片';

  @override
  String get issuePronunciation => '發音';

  @override
  String get issueMeaning => '意思 / 事實';

  @override
  String get issueOther => '其他';

  @override
  String get feedbackCommentHint => '哪裡有問題？（選填）';

  @override
  String get feedbackSend => '以電子郵件傳送';

  @override
  String feedbackNoMailApp(String email) {
    return '沒有可用的郵件 App。回報內容已拷貝到剪貼板，請寄到 $email。';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] 卡片問題 $key（$slug）';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return '卡組：$slug v$version（$title）';
  }

  @override
  String feedbackBodyCard(String key) {
    return '卡片：$key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return '語言：$l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return '顯示內容：$foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return '風格：$style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return '問題類型：$issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return '收件人：$email';
  }

  @override
  String get pronounce => '發音';

  @override
  String get installVoice => '安裝語音';

  @override
  String noVoiceInstalled(String lang) {
    return '尚未安裝「$lang」語音。請前往「設定」→「輔助使用」→「語音內容」→「聲音」加入，然後再試一次。';
  }

  @override
  String get playPronunciation => '播放發音';

  @override
  String get swipeNext => '下一張';

  @override
  String get swipeBack => '返回';

  @override
  String get showTranslation => '顯示譯文';

  @override
  String get showOriginal => '顯示原文';

  @override
  String get noCards => '沒有卡片';

  @override
  String get deckHasNoCards => '這個卡組沒有卡片。';

  @override
  String get flashcards => '字卡';

  @override
  String get stylePhoto => '照片';

  @override
  String get stylePhotoDesc => '清晰的照片，最接近真實';

  @override
  String get styleInk => '水墨';

  @override
  String get styleInkDesc => '筆觸、留白，一點色彩點綴';

  @override
  String get stylePastel => '粉彩';

  @override
  String get stylePastelDesc => '色紙上的乾粉彩';

  @override
  String get styleWatercolor => '水彩';

  @override
  String get styleWatercolorDesc => '暈染的色彩，透出紙張';

  @override
  String get styleFlag => '國旗';

  @override
  String get styleFlagDesc => '真實的國旗';

  @override
  String get stylePonyCartoon => '卡通';

  @override
  String get stylePonyCartoonDesc => '色彩繽紛的卡通插畫';

  @override
  String get styleStorybook => '繪本';

  @override
  String get styleStorybookDesc => '柔和的繪本插畫';

  @override
  String get stylePonyWatercolor => '水彩 – 柔和';

  @override
  String get stylePonyWatercolorDesc => '柔和的水彩畫';

  @override
  String get stylePonyOil => '油畫';

  @override
  String get stylePonyOilDesc => '畫布上的厚重筆觸';

  @override
  String get styleIllustriousOil => '油畫 – 厚塗';

  @override
  String get styleIllustriousOilDesc => '厚塗顏料，明暗對比';

  @override
  String get styleAnime => '動漫';

  @override
  String get styleAnimeDesc => '日本動漫畫風';

  @override
  String get styleFlat => '扁平向量';

  @override
  String get styleFlatDesc => '純色塊，簡潔造型';

  @override
  String get styleUkiyoe => '浮世繪';

  @override
  String get styleUkiyoeDesc => '日本木刻版畫';

  @override
  String get styleMucha => '新藝術（慕夏）';

  @override
  String get styleMuchaDesc => '帶金色點綴的裝飾性新藝術風格';

  @override
  String get styleVanGogh => '梵谷';

  @override
  String get styleVanGoghDesc => '後印象派的漩渦筆觸';

  @override
  String get langAr => '阿拉伯文';

  @override
  String get langCs => '捷克文';

  @override
  String get langDe => '德文';

  @override
  String get langEl => '希臘文';

  @override
  String get langEn => '英文';

  @override
  String get langEs419 => '西班牙文';

  @override
  String get langFr => '法文';

  @override
  String get langHe => '希伯來文';

  @override
  String get langHi => '印地文';

  @override
  String get langId => '印尼文';

  @override
  String get langJa => '日文';

  @override
  String get langKo => '韓文';

  @override
  String get langPtBR => '葡萄牙文';

  @override
  String get langRu => '俄文';

  @override
  String get langTr => '土耳其文';

  @override
  String get langVi => '越南文';

  @override
  String get langZhCN => '中文';
}
