import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import 'flashcard_widget.dart';

class CardStack extends StatefulWidget {
  final Flashcard card;
  final bool showFront;
  final Function(SwipeDirection) onSwipe;
  final VoidCallback onDoubleTap;

  const CardStack({
    super.key,
    required this.card,
    required this.showFront,
    required this.onSwipe,
    required this.onDoubleTap,
  });

  @override
  State<CardStack> createState() => _CardStackState();
}

enum SwipeDirection { up, down, left, right }

class _CardStackState extends State<CardStack>
    with SingleTickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final screenSize = MediaQuery.of(context).size;
    final threshold = screenSize.width * 0.3;

    SwipeDirection? direction;

    if (_dragOffset.dy < -threshold) {
      direction = SwipeDirection.up;
    } else if (_dragOffset.dy > threshold) {
      direction = SwipeDirection.down;
    } else if (_dragOffset.dx < -threshold) {
      direction = SwipeDirection.left;
    } else if (_dragOffset.dx > threshold) {
      direction = SwipeDirection.right;
    }

    if (direction != null) {
      _animateOut(direction);
    } else {
      _animateBack();
    }
  }

  void _animateOut(SwipeDirection direction) {
    final screenSize = MediaQuery.of(context).size;
    Offset endOffset;

    switch (direction) {
      case SwipeDirection.up:
        endOffset = Offset(0, -screenSize.height);
        break;
      case SwipeDirection.down:
        endOffset = Offset(0, screenSize.height);
        break;
      case SwipeDirection.left:
        endOffset = Offset(-screenSize.width, 0);
        break;
      case SwipeDirection.right:
        endOffset = Offset(screenSize.width, 0);
        break;
    }

    _animation = Tween<Offset>(
      begin: _dragOffset,
      end: endOffset,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward(from: 0).then((_) {
      widget.onSwipe(direction);
      setState(() {
        _dragOffset = Offset.zero;
      });
      _animationController.reset();
    });
  }

  void _animateBack() {
    _animation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward(from: 0).then((_) {
      setState(() {
        _dragOffset = Offset.zero;
      });
      _animationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final offset =
            _animationController.isAnimating ? _animation.value : _dragOffset;
        final rotation = offset.dx / 500;

        return Transform.translate(
          offset: offset,
          child: Transform.rotate(
            angle: rotation,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: _buildCardWithIndicators(),
      ),
    );
  }

  Widget _buildCardWithIndicators() {
    final opacity = (_dragOffset.distance / 150).clamp(0.0, 1.0);

    return Stack(
      children: [
        FlashcardWidget(
          card: widget.card,
          showFront: widget.showFront,
          onTap: widget.onDoubleTap,
        ),
        // Indikátor "Znám" (nahoru)
        if (_dragOffset.dy < -30)
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Opacity(
                opacity: opacity,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'ZNÁM ✓',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        // Indikátor "Neznám" (dolů)
        if (_dragOffset.dy > 30)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Opacity(
                opacity: opacity,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'NEZNÁM ✗',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
