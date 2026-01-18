import 'dart:math';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
    );
  }
}
