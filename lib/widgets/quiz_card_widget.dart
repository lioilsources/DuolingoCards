import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/flashcard.dart';

class QuizCardWidget extends StatefulWidget {
  final Flashcard card;
  final bool showFront;
  final VoidCallback? onTap;

  const QuizCardWidget({
    super.key,
    required this.card,
    required this.showFront,
    this.onTap,
  });

  @override
  State<QuizCardWidget> createState() => _QuizCardWidgetState();
}

class _QuizCardWidgetState extends State<QuizCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  void _flip() {
    if (_controller.isAnimating) return;

    if (_controller.value == 0) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    widget.onTap?.call();
  }

  Widget _buildImage(String imageUrl, {BoxFit fit = BoxFit.contain}) {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) =>
            const Icon(Icons.image_not_supported, size: 48),
      );
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported, size: 48),
      );
    } else {
      return Image.file(
        File(imageUrl),
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported, size: 48),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isFrontVisible = angle < pi / 2;

          // Determine what content to show based on:
          // - isFrontVisible: which physical side of the 3D card is showing
          // - widget.showFront: toggle from parent (true = quiz mode, false = answer mode)
          // When both match, show the quiz front (flag only)
          final showQuizFront = isFrontVisible == widget.showFront;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFrontVisible
                ? (showQuizFront ? _buildQuizFront() : _buildQuizBack())
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: showQuizFront ? _buildQuizFront() : _buildQuizBack(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildQuizFront() {
    final imageUrl = widget.card.imageUrlResolved;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: imageUrl != null && imageUrl.isNotEmpty
              ? _buildImage(imageUrl, fit: BoxFit.contain)
              : const Center(
                  child: Icon(Icons.help_outline, size: 80, color: Colors.grey),
                ),
        ),
      ),
    );
  }

  Widget _buildQuizBack() {
    final quizData = widget.card.quizData;
    final imageUrl = widget.card.imageUrlResolved;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Small image at top
            if (imageUrl != null && imageUrl.isNotEmpty)
              SizedBox(
                height: 80,
                child: _buildImage(imageUrl),
              ),
            if (imageUrl != null && imageUrl.isNotEmpty)
              const SizedBox(height: 16),

            // Title (large, bold)
            if (quizData != null) ...[
              Text(
                quizData.title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              // Subtitle
              if (quizData.subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  quizData.subtitle!,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // Dynamic fields
              if (quizData.fields.isNotEmpty) ...[
                const SizedBox(height: 24),
                ...quizData.fields.map((field) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${field.label}: ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            field.value,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ] else ...[
              // Fallback to backText if no quizData
              Text(
                widget.card.backText,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
