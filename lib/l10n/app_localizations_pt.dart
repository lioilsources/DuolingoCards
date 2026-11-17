// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Loja de baralhos';

  @override
  String get homeEmptyTitle => 'Nenhum baralho ainda';

  @override
  String get homeReorderHint =>
      'Toque e segure um baralho e arraste para reordenar';

  @override
  String get homeBrowseStore => 'Ver a loja de baralhos';

  @override
  String get homeDownloadingDecks => 'Preparando seus baralhos…';

  @override
  String get badgeFree => 'Grátis';

  @override
  String get badgeUnlocked => 'Desbloqueado';

  @override
  String get badgePurchased => 'Comprado';

  @override
  String get badgeNew => 'Novo';

  @override
  String get badgePaidDeck => 'Baralho pago';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartões',
      one: '1 cartão',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards cartões',
      one: '1 cartão',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs idiomas',
      one: '1 idioma',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count sei';
  }

  @override
  String legendLearning(int count) {
    return '$count aprendendo';
  }

  @override
  String legendUnknown(int count) {
    return '$count não sei';
  }

  @override
  String get storeTitle => 'Loja de baralhos';

  @override
  String get storeRestorePurchases => 'Restaurar compras';

  @override
  String get storeSearchHint => 'Buscar baralhos…';

  @override
  String storeLoadError(String error) {
    return 'Não foi possível carregar os baralhos: $error';
  }

  @override
  String get storeNoDecks => 'Nenhum baralho disponível.';

  @override
  String get storeNothingFound => 'Nada encontrado.';

  @override
  String get retry => 'Tentar de novo';

  @override
  String get buy => 'Comprar';

  @override
  String buyFor(String price) {
    return 'Comprar por $price';
  }

  @override
  String get add => 'Adicionar';

  @override
  String get addFree => 'Adicionar grátis';

  @override
  String get back => 'Voltar';

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Próximo';

  @override
  String get study => 'Estudar';

  @override
  String get download => 'Baixar';

  @override
  String get confirmLanguagesLabel => 'Idiomas';

  @override
  String get styleSectionTitle => 'Estilo de imagem';

  @override
  String get confirmBuyNote =>
      'A compra desbloqueia o baralho inteiro — todos os idiomas e todos os estilos. Esta combinação será adicionada à sua tela inicial.';

  @override
  String get confirmAddNote =>
      'Esta combinação será adicionada à sua tela inicial. Você pode adicionar outro idioma ou estilo quando quiser.';

  @override
  String get purchaseFailedToStart => 'Não foi possível iniciar a compra.';

  @override
  String get addedToHome => 'Adicionado à sua tela inicial.';

  @override
  String get downloadFailed => 'Falha no download. Tente de novo.';

  @override
  String get deckNotPurchased => 'Este baralho não foi comprado.';

  @override
  String downloading(int percent) {
    return 'Baixando… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ativos',
      one: '1 ativo',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Eu sei';

  @override
  String get pickerLearning => 'Aprendendo';

  @override
  String get reportIssue => 'Relatar um problema';

  @override
  String get issueTranslation => 'Tradução';

  @override
  String get issueImage => 'Imagem';

  @override
  String get issuePronunciation => 'Pronúncia';

  @override
  String get issueMeaning => 'Significado / fatos';

  @override
  String get issueOther => 'Outro';

  @override
  String get feedbackCommentHint => 'O que está errado? (opcional)';

  @override
  String get feedbackSend => 'Enviar por e-mail';

  @override
  String feedbackNoMailApp(String email) {
    return 'Nenhum app de e-mail disponível. O relato foi copiado para a área de transferência — envie para $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Problema no cartão $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Baralho: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Cartão: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Idiomas: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Exibido: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Estilo: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Tipo de problema: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'Para: $email';
  }

  @override
  String get pronounce => 'Pronunciar';

  @override
  String get installVoice => 'Instalar voz';

  @override
  String noVoiceInstalled(String lang) {
    return 'Nenhuma voz para “$lang” está instalada. Adicione uma em Ajustes → Acessibilidade → Conteúdo Falado → Vozes e tente de novo.';
  }

  @override
  String get playPronunciation => 'Ouvir pronúncia';

  @override
  String get swipeNext => 'PRÓXIMO';

  @override
  String get swipeBack => 'VOLTAR';

  @override
  String get showTranslation => 'Mostrar tradução';

  @override
  String get showOriginal => 'Mostrar original';

  @override
  String get noCards => 'Nenhum cartão';

  @override
  String get deckHasNoCards => 'Este baralho não tem cartões.';

  @override
  String get flashcards => 'Flashcards';

  @override
  String get stylePhoto => 'Foto';

  @override
  String get stylePhotoDesc => 'Foto nítida, o mais próximo da realidade';

  @override
  String get styleInk => 'Pincel e nanquim';

  @override
  String get styleInkDesc => 'Pinceladas, papel em branco, um toque de cor';

  @override
  String get stylePastel => 'Pastel';

  @override
  String get stylePastelDesc => 'Pastel seco em papel colorido';

  @override
  String get styleWatercolor => 'Aquarela';

  @override
  String get styleWatercolorDesc => 'Manchas que se espalham, papel aparente';

  @override
  String get styleFlag => 'Bandeiras';

  @override
  String get styleFlagDesc => 'As bandeiras nacionais de verdade';

  @override
  String get stylePonyCartoon => 'Desenho animado';

  @override
  String get stylePonyCartoonDesc => 'Ilustração colorida de desenho animado';

  @override
  String get styleStorybook => 'Livro ilustrado';

  @override
  String get styleStorybookDesc => 'Ilustração suave de livro';

  @override
  String get stylePonyWatercolor => 'Aquarela suave';

  @override
  String get stylePonyWatercolorDesc => 'Pintura em aquarela delicada';

  @override
  String get stylePonyOil => 'Pintura a óleo';

  @override
  String get stylePonyOilDesc => 'Pinceladas grossas sobre tela';

  @override
  String get styleIllustriousOil => 'Óleo – empaste';

  @override
  String get styleIllustriousOilDesc => 'Tinta espessa, claro-escuro';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Desenho de anime japonês';

  @override
  String get styleFlat => 'Vetor plano';

  @override
  String get styleFlatDesc => 'Cores chapadas e formas limpas';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Xilogravura japonesa';

  @override
  String get styleMucha => 'Art nouveau (Mucha)';

  @override
  String get styleMuchaDesc => 'Art nouveau ornamental com detalhes dourados';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc => 'Pinceladas em espiral pós-impressionistas';

  @override
  String get styleVectorFlat => 'Formas geométricas';

  @override
  String get styleVectorFlatDesc =>
      'Formas planas nítidas com contornos limpos';

  @override
  String get styleGouache => 'Guache';

  @override
  String get styleGouacheDesc => 'Tinta opaca e fosca em cores fortes';

  @override
  String get styleWatercolorWet => 'Aquarela molhada';

  @override
  String get styleWatercolorWetDesc => 'Cores que se espalham no papel molhado';

  @override
  String get styleWatercolorInkLine => 'Nanquim e aquarela';

  @override
  String get styleWatercolorInkLineDesc =>
      'Traços finos de nanquim com aguadas leves';

  @override
  String get styleEtching => 'Gravura em metal';

  @override
  String get styleEtchingDesc =>
      'Linhas finas gravadas, como uma estampa antiga';

  @override
  String get styleLinocut => 'Linogravura';

  @override
  String get styleLinocutDesc => 'Formas entalhadas impressas em poucas cores';

  @override
  String get styleCrayon => 'Giz de cera';

  @override
  String get styleCrayonDesc =>
      'Traços de giz de cera, como um desenho infantil';

  @override
  String get styleLowPoly => 'Low poly';

  @override
  String get styleLowPolyDesc => 'Feito de triângulos com sombreamento plano';

  @override
  String get styleClaymation => 'Massinha';

  @override
  String get styleClaymationDesc => 'Modelado em massinha macia';

  @override
  String get styleStickerCollage => 'Colagem de adesivos';

  @override
  String get styleStickerCollageDesc => 'Adesivos recortados com borda branca';

  @override
  String get stylePressedFlowers => 'Flores prensadas';

  @override
  String get stylePressedFlowersDesc => 'Feito de pétalas e folhas secas';

  @override
  String get stylePaperSculptureLayered => 'Papel recortado';

  @override
  String get stylePaperSculptureLayeredDesc =>
      'Camadas de papel recortado com sombras suaves';

  @override
  String get stylePolishPoster => 'Pôster retrô';

  @override
  String get stylePolishPosterDesc =>
      'Arte de cartaz marcante de meados do século';

  @override
  String get styleChalkboard => 'Lousa';

  @override
  String get styleChalkboardDesc => 'Desenho a giz numa lousa escura';

  @override
  String get styleBlueprint => 'Planta técnica';

  @override
  String get styleBlueprintDesc => 'Linhas técnicas brancas sobre azul';

  @override
  String get styleIllumination => 'Manuscrito iluminado';

  @override
  String get styleIlluminationDesc =>
      'Arte de livro medieval com folha de ouro';

  @override
  String get styleRackham => 'Nanquim de conto de fadas';

  @override
  String get styleRackhamDesc =>
      'Traços delicados de nanquim e aguadas suaves de antigos livros de contos';

  @override
  String get styleMoebius => 'Traço de quadrinhos';

  @override
  String get styleMoebiusDesc =>
      'Traços limpos de quadrinhos e cores chapadas vivas';

  @override
  String get styleHiroshige => 'Xilogravura japonesa';

  @override
  String get styleHiroshigeDesc =>
      'Paisagem japonesa em xilogravura com degradês suaves';

  @override
  String get langAr => 'Árabe';

  @override
  String get langCs => 'Tcheco';

  @override
  String get langDe => 'Alemão';

  @override
  String get langEl => 'Grego';

  @override
  String get langEn => 'Inglês';

  @override
  String get langEs419 => 'Espanhol';

  @override
  String get langFr => 'Francês';

  @override
  String get langHe => 'Hebraico';

  @override
  String get langHi => 'Hindi';

  @override
  String get langId => 'Indonésio';

  @override
  String get langJa => 'Japonês';

  @override
  String get langKo => 'Coreano';

  @override
  String get langPtBR => 'Português';

  @override
  String get langRu => 'Russo';

  @override
  String get langTr => 'Turco';

  @override
  String get langVi => 'Vietnamita';

  @override
  String get langZhCN => 'Chinês';
}

/// The translations for Portuguese, as used in Portugal (`pt_PT`).
class AppLocalizationsPtPt extends AppLocalizationsPt {
  AppLocalizationsPtPt() : super('pt_PT');

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Loja de baralhos';

  @override
  String get homeEmptyTitle => 'Ainda não há baralhos';

  @override
  String get homeReorderHint =>
      'Mantenha premido um baralho e arraste-o para reordenar';

  @override
  String get homeBrowseStore => 'Ver a loja de baralhos';

  @override
  String get homeDownloadingDecks => 'A preparar os seus baralhos…';

  @override
  String get badgeFree => 'Grátis';

  @override
  String get badgeUnlocked => 'Desbloqueado';

  @override
  String get badgePurchased => 'Comprado';

  @override
  String get badgeNew => 'Novo';

  @override
  String get badgePaidDeck => 'Baralho pago';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartões',
      one: '1 cartão',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards cartões',
      one: '1 cartão',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs idiomas',
      one: '1 idioma',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count sei';
  }

  @override
  String legendLearning(int count) {
    return '$count a aprender';
  }

  @override
  String legendUnknown(int count) {
    return '$count não sei';
  }

  @override
  String get storeTitle => 'Loja de baralhos';

  @override
  String get storeRestorePurchases => 'Restaurar compras';

  @override
  String get storeSearchHint => 'Pesquisar baralhos…';

  @override
  String storeLoadError(String error) {
    return 'Não foi possível carregar os baralhos: $error';
  }

  @override
  String get storeNoDecks => 'Nenhum baralho disponível.';

  @override
  String get storeNothingFound => 'Nada encontrado.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get buy => 'Comprar';

  @override
  String buyFor(String price) {
    return 'Comprar por $price';
  }

  @override
  String get add => 'Adicionar';

  @override
  String get addFree => 'Adicionar grátis';

  @override
  String get back => 'Voltar';

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Seguinte';

  @override
  String get study => 'Estudar';

  @override
  String get download => 'Transferir';

  @override
  String get confirmLanguagesLabel => 'Idiomas';

  @override
  String get styleSectionTitle => 'Estilo de imagem';

  @override
  String get confirmBuyNote =>
      'A compra desbloqueia o baralho inteiro — todos os idiomas e todos os estilos. Esta combinação será adicionada ao seu ecrã principal.';

  @override
  String get confirmAddNote =>
      'Esta combinação será adicionada ao seu ecrã principal. Pode adicionar outro idioma ou estilo a qualquer momento.';

  @override
  String get purchaseFailedToStart => 'Não foi possível iniciar a compra.';

  @override
  String get addedToHome => 'Adicionado ao seu ecrã principal.';

  @override
  String get downloadFailed => 'A transferência falhou. Tente novamente.';

  @override
  String get deckNotPurchased => 'Este baralho não foi comprado.';

  @override
  String downloading(int percent) {
    return 'A transferir… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ativos',
      one: '1 ativo',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Já sei';

  @override
  String get pickerLearning => 'A aprender';

  @override
  String get reportIssue => 'Comunicar um problema';

  @override
  String get issueTranslation => 'Tradução';

  @override
  String get issueImage => 'Imagem';

  @override
  String get issuePronunciation => 'Pronúncia';

  @override
  String get issueMeaning => 'Significado / factos';

  @override
  String get issueOther => 'Outro';

  @override
  String get feedbackCommentHint => 'O que está errado? (opcional)';

  @override
  String get feedbackSend => 'Enviar por e-mail';

  @override
  String feedbackNoMailApp(String email) {
    return 'Não há nenhuma app de e-mail disponível. O relatório foi copiado para a área de transferência — envie-o para $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Problema no cartão $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Baralho: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Cartão: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Idiomas: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Apresentado: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Estilo: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Tipo de problema: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'Para: $email';
  }

  @override
  String get pronounce => 'Pronunciar';

  @override
  String get installVoice => 'Instalar voz';

  @override
  String noVoiceInstalled(String lang) {
    return 'Não está instalada nenhuma voz para “$lang”. Adicione uma em Definições → Acessibilidade → Conteúdo falado → Vozes e tente novamente.';
  }

  @override
  String get playPronunciation => 'Ouvir pronúncia';

  @override
  String get swipeNext => 'SEGUINTE';

  @override
  String get swipeBack => 'VOLTAR';

  @override
  String get showTranslation => 'Mostrar tradução';

  @override
  String get showOriginal => 'Mostrar original';

  @override
  String get noCards => 'Sem cartões';

  @override
  String get deckHasNoCards => 'Este baralho não tem cartões.';

  @override
  String get flashcards => 'Cartões de memória';

  @override
  String get stylePhoto => 'Fotografia';

  @override
  String get stylePhotoDesc => 'Fotografia nítida, o mais próxima da realidade';

  @override
  String get styleInk => 'Pincel e tinta-da-china';

  @override
  String get styleInkDesc => 'Pinceladas, papel à vista, um toque de cor';

  @override
  String get stylePastel => 'Pastel';

  @override
  String get stylePastelDesc => 'Pastel seco em papel colorido';

  @override
  String get styleWatercolor => 'Aguarela';

  @override
  String get styleWatercolorDesc => 'Manchas que se espalham, papel à vista';

  @override
  String get styleFlag => 'Bandeiras';

  @override
  String get styleFlagDesc => 'As verdadeiras bandeiras nacionais';

  @override
  String get stylePonyCartoon => 'Desenho animado';

  @override
  String get stylePonyCartoonDesc => 'Ilustração colorida de desenho animado';

  @override
  String get styleStorybook => 'Livro ilustrado';

  @override
  String get styleStorybookDesc => 'Ilustração suave de livro';

  @override
  String get stylePonyWatercolor => 'Aguarela suave';

  @override
  String get stylePonyWatercolorDesc => 'Pintura a aguarela delicada';

  @override
  String get stylePonyOil => 'Pintura a óleo';

  @override
  String get stylePonyOilDesc => 'Pinceladas grossas sobre tela';

  @override
  String get styleIllustriousOil => 'Óleo – empastamento';

  @override
  String get styleIllustriousOilDesc => 'Tinta espessa, claro-escuro';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Desenho de anime japonês';

  @override
  String get styleFlat => 'Vetorial plano';

  @override
  String get styleFlatDesc => 'Cores lisas e formas limpas';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Xilogravura japonesa';

  @override
  String get styleMucha => 'Arte nova (Mucha)';

  @override
  String get styleMuchaDesc => 'Arte nova ornamental com detalhes dourados';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc => 'Pinceladas em espiral pós-impressionistas';

  @override
  String get styleVectorFlat => 'Vetor plano';

  @override
  String get styleVectorFlatDesc =>
      'Formas planas nítidas com contornos limpos';

  @override
  String get styleGouache => 'Guache';

  @override
  String get styleGouacheDesc => 'Tinta opaca e mate em cores fortes';

  @override
  String get styleWatercolorWet => 'Aguarela molhada';

  @override
  String get styleWatercolorWetDesc => 'Cores que se espalham no papel molhado';

  @override
  String get styleWatercolorInkLine => 'Tinta-da-china e aguarela';

  @override
  String get styleWatercolorInkLineDesc =>
      'Traços finos de tinta-da-china com aguadas leves';

  @override
  String get styleEtching => 'Água-forte';

  @override
  String get styleEtchingDesc =>
      'Linhas finas gravadas, como uma estampa antiga';

  @override
  String get styleLinocut => 'Linogravura';

  @override
  String get styleLinocutDesc => 'Formas entalhadas impressas em poucas cores';

  @override
  String get styleCrayon => 'Lápis de cera';

  @override
  String get styleCrayonDesc =>
      'Traços de lápis de cera, como um desenho infantil';

  @override
  String get styleLowPoly => 'Low poly';

  @override
  String get styleLowPolyDesc => 'Feito de triângulos com sombreado plano';

  @override
  String get styleClaymation => 'Plasticina';

  @override
  String get styleClaymationDesc => 'Modelado em plasticina macia';

  @override
  String get styleStickerCollage => 'Colagem de autocolantes';

  @override
  String get styleStickerCollageDesc =>
      'Autocolantes recortados com rebordo branco';

  @override
  String get stylePressedFlowers => 'Flores prensadas';

  @override
  String get stylePressedFlowersDesc => 'Feito de pétalas e folhas secas';

  @override
  String get stylePaperSculptureLayered => 'Papel recortado';

  @override
  String get stylePaperSculptureLayeredDesc =>
      'Camadas de papel recortado com sombras suaves';

  @override
  String get stylePolishPoster => 'Cartaz retro';

  @override
  String get stylePolishPosterDesc =>
      'Arte de cartaz marcante de meados do século';

  @override
  String get styleChalkboard => 'Quadro de ardósia';

  @override
  String get styleChalkboardDesc => 'Desenho a giz num quadro escuro';

  @override
  String get styleBlueprint => 'Planta técnica';

  @override
  String get styleBlueprintDesc => 'Linhas técnicas brancas sobre azul';

  @override
  String get styleIllumination => 'Iluminura';

  @override
  String get styleIlluminationDesc =>
      'Arte de livro medieval com folha de ouro';

  @override
  String get styleRackham => 'Tinta de conto de fadas';

  @override
  String get styleRackhamDesc =>
      'Traços delicados de tinta e aguadas suaves de antigos livros de contos';

  @override
  String get styleMoebius => 'Traço de banda desenhada';

  @override
  String get styleMoebiusDesc => 'Traços limpos de BD e cores lisas vivas';

  @override
  String get styleHiroshige => 'Xilogravura japonesa';

  @override
  String get styleHiroshigeDesc =>
      'Paisagem japonesa em xilogravura com gradientes suaves';

  @override
  String get langAr => 'Árabe';

  @override
  String get langCs => 'Checo';

  @override
  String get langDe => 'Alemão';

  @override
  String get langEl => 'Grego';

  @override
  String get langEn => 'Inglês';

  @override
  String get langEs419 => 'Espanhol';

  @override
  String get langFr => 'Francês';

  @override
  String get langHe => 'Hebraico';

  @override
  String get langHi => 'Hindi';

  @override
  String get langId => 'Indonésio';

  @override
  String get langJa => 'Japonês';

  @override
  String get langKo => 'Coreano';

  @override
  String get langPtBR => 'Português';

  @override
  String get langRu => 'Russo';

  @override
  String get langTr => 'Turco';

  @override
  String get langVi => 'Vietnamita';

  @override
  String get langZhCN => 'Chinês';
}
