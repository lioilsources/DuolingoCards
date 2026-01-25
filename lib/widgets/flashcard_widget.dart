import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/flashcard.dart';

class FlashcardWidget extends StatefulWidget {
  final Flashcard card;
  final bool showFront;
  final VoidCallback? onTap;

  const FlashcardWidget({
    super.key,
    required this.card,
    required this.showFront,
    this.onTap,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showingFront = true;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _showingFront = widget.showFront;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _flip() {
    if (_controller.isAnimating) return;

    if (_showingFront) {
      _controller.forward().then((_) {
        setState(() => _showingFront = false);
      });
    } else {
      _controller.reverse().then((_) {
        setState(() => _showingFront = true);
      });
    }
  }

  Future<void> _playAudio() async {
    final audioUrl = widget.showFront
        ? widget.card.audioFrontUrl
        : widget.card.audioBackUrl;

    if (audioUrl == null || audioUrl.isEmpty) return;

    setState(() => _isPlayingAudio = true);

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(_getAudioSource(audioUrl));
    } catch (e) {
      // Silently fail if audio unavailable
    } finally {
      if (mounted) {
        setState(() => _isPlayingAudio = false);
      }
    }
  }

  Source _getAudioSource(String audioUrl) {
    if (audioUrl.startsWith('http')) {
      return UrlSource(audioUrl);
    } else if (audioUrl.startsWith('assets/')) {
      // Remove 'assets/' prefix for AssetSource as it's added automatically
      return AssetSource(audioUrl.substring(7));
    } else {
      // Local file path
      return DeviceFileSource(audioUrl);
    }
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) =>
            const Icon(Icons.image_not_supported),
      );
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported),
      );
    } else {
      // Local file path
      return Image.file(
        File(imageUrl),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        _flip();
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isFrontVisible = angle < pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFrontVisible
                ? _buildCardFace(
                    text: widget.showFront
                        ? widget.card.frontText
                        : widget.card.backText,
                    subtext: widget.showFront ? widget.card.reading : null,
                    imageUrl: widget.card.imageUrlResolved,
                    hasAudio: (widget.showFront
                            ? widget.card.audioFrontUrl
                            : widget.card.audioBackUrl) !=
                        null,
                    color: Colors.white,
                  )
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildCardFace(
                      text: widget.showFront
                          ? widget.card.backText
                          : widget.card.frontText,
                      subtext: !widget.showFront ? widget.card.reading : null,
                      imageUrl: null, // Only show image on front
                      hasAudio: (!widget.showFront
                              ? widget.card.audioFrontUrl
                              : widget.card.audioBackUrl) !=
                          null,
                      color: Colors.blue.shade50,
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCardFace({
    required String text,
    String? subtext,
    String? imageUrl,
    bool hasAudio = false,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(20),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image
                      Expanded(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildImage(imageUrl),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Text content with image
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              text,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (subtext != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                subtext,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Text only - centered
                        Text(
                          text,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (subtext != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            subtext,
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
          // Audio button (top right)
          if (hasAudio)
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                onPressed: _isPlayingAudio ? null : _playAudio,
                icon: Icon(
                  _isPlayingAudio ? Icons.volume_up : Icons.volume_up_outlined,
                  color: _isPlayingAudio
                      ? Colors.blue
                      : Colors.grey.shade600,
                  size: 28,
                ),
                tooltip: 'Play pronunciation',
              ),
            ),
        ],
      ),
    );
  }
}
