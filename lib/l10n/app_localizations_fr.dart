// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Boutique de decks';

  @override
  String get homeEmptyTitle => 'Aucun deck pour l’instant';

  @override
  String get homeReorderHint =>
      'Appuie longuement sur un deck et fais-le glisser pour le déplacer';

  @override
  String get homeBrowseStore => 'Voir la boutique';

  @override
  String get homeDownloadingDecks => 'Préparation de tes decks…';

  @override
  String get badgeFree => 'Gratuit';

  @override
  String get badgeUnlocked => 'Débloqué';

  @override
  String get badgePurchased => 'Acheté';

  @override
  String get badgePaidDeck => 'Deck payant';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartes',
      one: '1 carte',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards cartes',
      one: '1 carte',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs langues',
      one: '1 langue',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count connus';
  }

  @override
  String legendLearning(int count) {
    return '$count en cours';
  }

  @override
  String legendUnknown(int count) {
    return '$count inconnus';
  }

  @override
  String get storeTitle => 'Boutique de decks';

  @override
  String get storeRestorePurchases => 'Restaurer les achats';

  @override
  String get storeSearchHint => 'Rechercher un deck…';

  @override
  String storeLoadError(String error) {
    return 'Impossible de charger les decks : $error';
  }

  @override
  String get storeNoDecks => 'Aucun deck disponible.';

  @override
  String get storeNothingFound => 'Aucun résultat.';

  @override
  String get retry => 'Réessayer';

  @override
  String get buy => 'Acheter';

  @override
  String buyFor(String price) {
    return 'Acheter pour $price';
  }

  @override
  String get add => 'Ajouter';

  @override
  String get addFree => 'Ajouter gratuitement';

  @override
  String get back => 'Retour';

  @override
  String get previous => 'Précédent';

  @override
  String get next => 'Suivant';

  @override
  String get study => 'Apprendre';

  @override
  String get download => 'Télécharger';

  @override
  String get confirmLanguagesLabel => 'Langues';

  @override
  String get styleSectionTitle => 'Style d’image';

  @override
  String get confirmBuyNote =>
      'L’achat débloque tout le deck : toutes les langues et tous les styles. Cette combinaison sera ajoutée à ton écran d’accueil.';

  @override
  String get confirmAddNote =>
      'Cette combinaison sera ajoutée à ton écran d’accueil. Tu peux ajouter une autre langue ou un autre style à tout moment.';

  @override
  String get purchaseFailedToStart => 'Impossible de lancer l’achat.';

  @override
  String get addedToHome => 'Ajouté à ton écran d’accueil.';

  @override
  String get downloadFailed => 'Échec du téléchargement. Réessaie.';

  @override
  String get deckNotPurchased => 'Ce deck n’a pas été acheté.';

  @override
  String downloading(int percent) {
    return 'Téléchargement… $percent %';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actifs',
      one: '1 actif',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Je connais';

  @override
  String get pickerLearning => 'J’apprends';

  @override
  String get reportIssue => 'Signaler un problème';

  @override
  String get issueTranslation => 'Traduction';

  @override
  String get issueImage => 'Image';

  @override
  String get issuePronunciation => 'Prononciation';

  @override
  String get issueMeaning => 'Sens / faits';

  @override
  String get issueOther => 'Autre';

  @override
  String get feedbackCommentHint => 'Qu’est-ce qui ne va pas ? (facultatif)';

  @override
  String get feedbackSend => 'Envoyer par e-mail';

  @override
  String feedbackNoMailApp(String email) {
    return 'Aucune app de messagerie disponible. Le signalement a été copié dans le presse-papiers : envoie-le à $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Problème de carte $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Deck : $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Carte : $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Langues : $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Affiché : $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Style : $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Type de problème : $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'À : $email';
  }

  @override
  String get pronounce => 'Prononcer';

  @override
  String get installVoice => 'Installer une voix';

  @override
  String noVoiceInstalled(String lang) {
    return 'Aucune voix n’est installée pour « $lang ». Ajoutes-en une dans Réglages → Accessibilité → Contenu énoncé → Voix, puis réessaie.';
  }

  @override
  String get playPronunciation => 'Écouter la prononciation';

  @override
  String get swipeNext => 'SUIVANT';

  @override
  String get swipeBack => 'RETOUR';

  @override
  String get showTranslation => 'Voir la traduction';

  @override
  String get showOriginal => 'Voir l’original';

  @override
  String get noCards => 'Aucune carte';

  @override
  String get deckHasNoCards => 'Ce deck ne contient aucune carte.';

  @override
  String get flashcards => 'Cartes mémoire';

  @override
  String get stylePhoto => 'Photo';

  @override
  String get stylePhotoDesc => 'Photo nette, au plus près de la réalité';

  @override
  String get styleInk => 'Pinceau et encre';

  @override
  String get styleInkDesc =>
      'Coups de pinceau, papier nu, une touche de couleur';

  @override
  String get stylePastel => 'Pastel';

  @override
  String get stylePastelDesc => 'Pastel sec sur papier teinté';

  @override
  String get styleWatercolor => 'Aquarelle';

  @override
  String get styleWatercolorDesc => 'Lavis qui s’épanouissent, papier apparent';

  @override
  String get styleFlag => 'Drapeaux';

  @override
  String get styleFlagDesc => 'Les vrais drapeaux nationaux';

  @override
  String get stylePonyCartoon => 'Dessin animé';

  @override
  String get stylePonyCartoonDesc => 'Illustration colorée façon dessin animé';

  @override
  String get styleStorybook => 'Livre illustré';

  @override
  String get styleStorybookDesc => 'Douce illustration de livre';

  @override
  String get stylePonyWatercolor => 'Aquarelle douce';

  @override
  String get stylePonyWatercolorDesc =>
      'Peinture à l’aquarelle tout en douceur';

  @override
  String get stylePonyOil => 'Peinture à l’huile';

  @override
  String get stylePonyOilDesc => 'Coups de pinceau épais sur toile';

  @override
  String get styleIllustriousOil => 'Huile – empâtement';

  @override
  String get styleIllustriousOilDesc => 'Peinture épaisse, clair-obscur';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Dessin d’anime japonais';

  @override
  String get styleFlat => 'Vectoriel plat';

  @override
  String get styleFlatDesc => 'Aplats de couleur et formes nettes';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Estampe japonaise sur bois';

  @override
  String get styleMucha => 'Art nouveau (Mucha)';

  @override
  String get styleMuchaDesc => 'Art nouveau ornemental aux touches dorées';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc =>
      'Touches tourbillonnantes post-impressionnistes';

  @override
  String get langAr => 'Arabe';

  @override
  String get langCs => 'Tchèque';

  @override
  String get langDe => 'Allemand';

  @override
  String get langEl => 'Grec';

  @override
  String get langEn => 'Anglais';

  @override
  String get langEs419 => 'Espagnol';

  @override
  String get langFr => 'Français';

  @override
  String get langHe => 'Hébreu';

  @override
  String get langHi => 'Hindi';

  @override
  String get langId => 'Indonésien';

  @override
  String get langJa => 'Japonais';

  @override
  String get langKo => 'Coréen';

  @override
  String get langPtBR => 'Portugais';

  @override
  String get langRu => 'Russe';

  @override
  String get langTr => 'Turc';

  @override
  String get langVi => 'Vietnamien';

  @override
  String get langZhCN => 'Chinois';
}
