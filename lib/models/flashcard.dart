class CardMedia {
  final String? image;
  final String? audioFront;
  final String? audioBack;
  final String? video;

  CardMedia({
    this.image,
    this.audioFront,
    this.audioBack,
    this.video,
  });

  factory CardMedia.fromJson(Map<String, dynamic> json) {
    return CardMedia(
      image: json['image'] as String?,
      audioFront: json['audioFront'] as String?,
      audioBack: json['audioBack'] as String?,
      video: json['video'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'audioFront': audioFront,
      'audioBack': audioBack,
      'video': video,
    };
  }
}

class Flashcard {
  final String id;
  final String frontText;
  final String backText;
  final String? reading;
  final CardMedia? media;
  final String? mediaStatus;

  // Legacy fields for backwards compatibility
  final String? frontAudio;
  final String? backAudio;
  final String? imageUrl;

  int priority;
  DateTime? lastSeen;

  Flashcard({
    required this.id,
    required this.frontText,
    required this.backText,
    this.reading,
    this.media,
    this.mediaStatus,
    this.frontAudio,
    this.backAudio,
    this.imageUrl,
    this.priority = 5,
    this.lastSeen,
  });

  // Helper getters that check both new and legacy fields
  String? get audioFrontUrl => media?.audioFront ?? frontAudio;
  String? get audioBackUrl => media?.audioBack ?? backAudio;
  String? get imageUrlResolved => media?.image ?? imageUrl;

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String,
      frontText: json['frontText'] as String,
      backText: json['backText'] as String,
      reading: json['reading'] as String?,
      media: json['media'] != null
          ? CardMedia.fromJson(json['media'] as Map<String, dynamic>)
          : null,
      mediaStatus: json['mediaStatus'] as String?,
      frontAudio: json['frontAudio'] as String?,
      backAudio: json['backAudio'] as String?,
      imageUrl: json['imageUrl'] as String?,
      priority: json['priority'] as int? ?? 5,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'frontText': frontText,
      'backText': backText,
      'reading': reading,
      'media': media?.toJson(),
      'mediaStatus': mediaStatus,
      'frontAudio': frontAudio,
      'backAudio': backAudio,
      'imageUrl': imageUrl,
      'priority': priority,
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }

  void increasePriority() {
    if (priority < 10) priority++;
    lastSeen = DateTime.now();
  }

  void decreasePriority() {
    if (priority > 1) priority--;
    lastSeen = DateTime.now();
  }
}
