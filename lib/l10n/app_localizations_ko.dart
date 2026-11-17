// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => '덱 스토어';

  @override
  String get homeEmptyTitle => '아직 덱이 없어요';

  @override
  String get homeReorderHint => '덱을 길게 누른 채 끌어서 순서를 바꾸세요';

  @override
  String get homeBrowseStore => '덱 스토어 둘러보기';

  @override
  String get homeDownloadingDecks => '덱을 준비하는 중…';

  @override
  String get badgeFree => '무료';

  @override
  String get badgeUnlocked => '잠금 해제됨';

  @override
  String get badgePurchased => '구입함';

  @override
  String get badgeNew => '신규';

  @override
  String get badgePaidDeck => '유료 덱';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count장',
    );
    return '카드 $_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards장',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs개 언어',
    );
    return '카드 $_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '알아요 $count';
  }

  @override
  String legendLearning(int count) {
    return '학습 중 $count';
  }

  @override
  String legendUnknown(int count) {
    return '몰라요 $count';
  }

  @override
  String get storeTitle => '덱 스토어';

  @override
  String get storeRestorePurchases => '구입 항목 복원';

  @override
  String get storeSearchHint => '덱 검색…';

  @override
  String storeLoadError(String error) {
    return '덱을 불러올 수 없어요: $error';
  }

  @override
  String get storeNoDecks => '이용할 수 있는 덱이 없어요.';

  @override
  String get storeNothingFound => '검색 결과가 없어요.';

  @override
  String get retry => '다시 시도';

  @override
  String get buy => '구입';

  @override
  String buyFor(String price) {
    return '$price에 구입';
  }

  @override
  String get add => '추가';

  @override
  String get addFree => '무료로 추가';

  @override
  String get back => '뒤로';

  @override
  String get previous => '이전';

  @override
  String get next => '다음';

  @override
  String get study => '학습하기';

  @override
  String get download => '다운로드';

  @override
  String get confirmLanguagesLabel => '언어';

  @override
  String get styleSectionTitle => '이미지 스타일';

  @override
  String get confirmBuyNote =>
      '구입하면 덱 전체가 잠금 해제돼요. 모든 언어와 모든 스타일을 쓸 수 있어요. 이 조합은 홈 화면에 추가돼요.';

  @override
  String get confirmAddNote => '이 조합은 홈 화면에 추가돼요. 다른 언어나 스타일은 언제든지 추가할 수 있어요.';

  @override
  String get purchaseFailedToStart => '구입을 시작할 수 없어요.';

  @override
  String get addedToHome => '홈 화면에 추가했어요.';

  @override
  String get downloadFailed => '다운로드에 실패했어요. 다시 시도해 주세요.';

  @override
  String get deckNotPurchased => '아직 구입하지 않은 덱이에요.';

  @override
  String downloading(int percent) {
    return '다운로드 중… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 사용 중',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => '알아요';

  @override
  String get pickerLearning => '학습 중';

  @override
  String get reportIssue => '문제 신고';

  @override
  String get issueTranslation => '번역';

  @override
  String get issueImage => '이미지';

  @override
  String get issuePronunciation => '발음';

  @override
  String get issueMeaning => '의미 / 사실';

  @override
  String get issueOther => '기타';

  @override
  String get feedbackCommentHint => '무엇이 잘못됐나요? (선택)';

  @override
  String get feedbackSend => '이메일로 보내기';

  @override
  String feedbackNoMailApp(String email) {
    return '이메일 앱이 없어요. 신고 내용을 클립보드에 복사했어요. $email(으)로 보내 주세요.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] 카드 문제 $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return '덱: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return '카드: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return '언어: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return '표시된 내용: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return '스타일: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return '문제 유형: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return '받는 사람: $email';
  }

  @override
  String get pronounce => '발음 듣기';

  @override
  String get installVoice => '음성 설치';

  @override
  String noVoiceInstalled(String lang) {
    return '\'$lang\' 음성이 설치되어 있지 않아요. 설정 → 손쉬운 사용 → 말하기 콘텐츠 → 음성에서 추가한 다음 다시 시도해 주세요.';
  }

  @override
  String get playPronunciation => '발음 재생';

  @override
  String get swipeNext => '다음';

  @override
  String get swipeBack => '뒤로';

  @override
  String get showTranslation => '번역 보기';

  @override
  String get showOriginal => '원문 보기';

  @override
  String get noCards => '카드 없음';

  @override
  String get deckHasNoCards => '이 덱에는 카드가 없어요.';

  @override
  String get flashcards => '플래시카드';

  @override
  String get stylePhoto => '사진';

  @override
  String get stylePhotoDesc => '선명한 사진, 실제와 가장 비슷해요';

  @override
  String get styleInk => '붓과 먹';

  @override
  String get styleInkDesc => '붓 터치와 여백, 포인트 색 하나';

  @override
  String get stylePastel => '파스텔';

  @override
  String get stylePastelDesc => '색지 위의 소프트 파스텔';

  @override
  String get styleWatercolor => '수채화';

  @override
  String get styleWatercolorDesc => '번지는 물감, 비치는 종이';

  @override
  String get styleFlag => '국기';

  @override
  String get styleFlagDesc => '실제 국기';

  @override
  String get stylePonyCartoon => '카툰';

  @override
  String get stylePonyCartoonDesc => '알록달록한 카툰 일러스트';

  @override
  String get styleStorybook => '그림책';

  @override
  String get styleStorybookDesc => '부드러운 그림책 일러스트';

  @override
  String get stylePonyWatercolor => '수채화 – 부드럽게';

  @override
  String get stylePonyWatercolorDesc => '부드러운 수채화';

  @override
  String get stylePonyOil => '유화';

  @override
  String get stylePonyOilDesc => '캔버스 위의 두꺼운 붓 터치';

  @override
  String get styleIllustriousOil => '유화 – 임파스토';

  @override
  String get styleIllustriousOilDesc => '두껍게 바른 물감과 명암 대비';

  @override
  String get styleAnime => '애니메이션';

  @override
  String get styleAnimeDesc => '일본 애니메이션 그림체';

  @override
  String get styleFlat => '플랫 벡터';

  @override
  String get styleFlatDesc => '단색 면과 깔끔한 형태';

  @override
  String get styleUkiyoe => '우키요에';

  @override
  String get styleUkiyoeDesc => '일본 목판화';

  @override
  String get styleMucha => '아르누보 (무하)';

  @override
  String get styleMuchaDesc => '금빛 장식이 있는 아르누보';

  @override
  String get styleVanGogh => '반 고흐';

  @override
  String get styleVanGoghDesc => '소용돌이치는 후기 인상주의 붓 터치';

  @override
  String get styleVectorFlat => '플랫 벡터';

  @override
  String get styleVectorFlatDesc => '깔끔한 윤곽의 선명한 평면 도형';

  @override
  String get styleGouache => '과슈';

  @override
  String get styleGouacheDesc => '선명한 색의 불투명하고 매트한 물감';

  @override
  String get styleWatercolorWet => '번지기 수채화';

  @override
  String get styleWatercolorWetDesc => '젖은 종이에 부드럽게 번지는 색';

  @override
  String get styleWatercolorInkLine => '펜 수채화';

  @override
  String get styleWatercolorInkLineDesc => '가는 펜 선과 옅은 수채 물감';

  @override
  String get styleEtching => '에칭';

  @override
  String get styleEtchingDesc => '옛 판화 같은 섬세한 새김 선';

  @override
  String get styleLinocut => '리노컷';

  @override
  String get styleLinocutDesc => '적은 색으로 찍은 굵은 조각 형태';

  @override
  String get styleCrayon => '크레용';

  @override
  String get styleCrayonDesc => '아이 그림 같은 크레용 터치';

  @override
  String get styleLowPoly => '로우 폴리';

  @override
  String get styleLowPolyDesc => '평평한 삼각형으로 만든 모양';

  @override
  String get styleClaymation => '클레이';

  @override
  String get styleClaymationDesc => '말랑한 점토로 빚은 모습';

  @override
  String get styleStickerCollage => '스티커 콜라주';

  @override
  String get styleStickerCollageDesc => '흰 테두리의 오려 붙인 스티커';

  @override
  String get stylePressedFlowers => '압화';

  @override
  String get stylePressedFlowersDesc => '말린 꽃잎과 잎으로 만든 그림';

  @override
  String get stylePaperSculptureLayered => '종이 오리기';

  @override
  String get stylePaperSculptureLayeredDesc => '부드러운 그림자가 있는 겹겹의 종이';

  @override
  String get stylePolishPoster => '레트로 포스터';

  @override
  String get stylePolishPosterDesc => '20세기 중반의 대담한 포스터 아트';

  @override
  String get styleChalkboard => '칠판';

  @override
  String get styleChalkboardDesc => '어두운 칠판에 그린 분필 그림';

  @override
  String get styleBlueprint => '청사진';

  @override
  String get styleBlueprintDesc => '파란 바탕의 하얀 설계선';

  @override
  String get styleIllumination => '채색 필사본';

  @override
  String get styleIlluminationDesc => '금박을 입힌 중세 책 그림';

  @override
  String get styleRackham => '동화풍 펜화';

  @override
  String get styleRackhamDesc => '옛 동화책 같은 섬세한 펜 선과 은은한 색';

  @override
  String get styleMoebius => '만화 선화';

  @override
  String get styleMoebiusDesc => '깔끔한 만화 선과 밝은 단색';

  @override
  String get styleHiroshige => '목판화';

  @override
  String get styleHiroshigeDesc => '부드러운 그러데이션의 일본 풍경 판화';

  @override
  String get langAr => '아랍어';

  @override
  String get langCs => '체코어';

  @override
  String get langDe => '독일어';

  @override
  String get langEl => '그리스어';

  @override
  String get langEn => '영어';

  @override
  String get langEs419 => '스페인어';

  @override
  String get langFr => '프랑스어';

  @override
  String get langHe => '히브리어';

  @override
  String get langHi => '힌디어';

  @override
  String get langId => '인도네시아어';

  @override
  String get langJa => '일본어';

  @override
  String get langKo => '한국어';

  @override
  String get langPtBR => '포르투갈어';

  @override
  String get langRu => '러시아어';

  @override
  String get langTr => '튀르키예어';

  @override
  String get langVi => '베트남어';

  @override
  String get langZhCN => '중국어';
}
