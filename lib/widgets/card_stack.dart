import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum SwipeDirection { up, down, left, right }

class CardStack<T> extends StatefulWidget {
  final List<T> cards;
  final int currentIndex;
  final bool showFront;
  final Widget Function(T card, bool showFront) cardBuilder;
  final Widget Function(T card)? badgeBuilder;
  final Function(SwipeDirection) onSwipe;
  final VoidCallback onDoubleTap;
  final VoidCallback? onPeekNext;

  const CardStack({
    super.key,
    required this.cards,
    required this.currentIndex,
    required this.showFront,
    required this.cardBuilder,
    this.badgeBuilder,
    required this.onSwipe,
    required this.onDoubleTap,
    this.onPeekNext,
  });

  @override
  State<CardStack<T>> createState() => _CardStackState<T>();
}

class _CardStackState<T> extends State<CardStack<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // Vertical film strip offset
  double _verticalOffset = 0;
  Animation<double>? _verticalAnimation;

  // Horizontal swipe for current card (know/don't know)
  double _horizontalOffset = 0;
  double _rotation = 0;
  Animation<Offset>? _horizontalAnimation;

  // Track drag direction
  bool? _isVerticalDrag;

  // Card dimensions
  static const double _cardGap = 20.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.addListener(_onAnimationTick);
  }

  @override
  void dispose() {
    _animationController.removeListener(_onAnimationTick);
    _animationController.dispose();
    super.dispose();
  }

  void _onAnimationTick() {
    setState(() {
      if (_verticalAnimation != null) {
        _verticalOffset = _verticalAnimation!.value;
      }
      if (_horizontalAnimation != null) {
        _horizontalOffset = _horizontalAnimation!.value.dx;
        _rotation = _horizontalAnimation!.value.dy;
      }
    });
  }

  double? _availableHeight;

  void _onPanStart(DragStartDetails details) {
    _animationController.stop();
    _isVerticalDrag = null;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isVerticalDrag == null) {
      final dx = details.delta.dx.abs();
      final dy = details.delta.dy.abs();
      if (dx > 2 || dy > 2) {
        _isVerticalDrag = dy > dx;
      }
    }

    if (_isVerticalDrag == true) {
      setState(() {
        _verticalOffset += details.delta.dy;
      });
      if (_verticalOffset < -50 && widget.onPeekNext != null) {
        widget.onPeekNext!();
      }
    } else if (_isVerticalDrag == false) {
      setState(() {
        _horizontalOffset += details.delta.dx;
        _rotation = _horizontalOffset / 500;
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    final cardHeight = _availableHeight ?? 400;
    final velocity = details.velocity.pixelsPerSecond;
    final velocityThreshold = 500.0;

    if (_isVerticalDrag == true) {
      if (_verticalOffset < -cardHeight * 0.25 || velocity.dy < -velocityThreshold) {
        if (widget.currentIndex < widget.cards.length - 1 || widget.onPeekNext != null) {
          _animateVerticalSnap(SwipeDirection.up);
        } else {
          _animateVerticalBack();
        }
      } else if (_verticalOffset > cardHeight * 0.25 || velocity.dy > velocityThreshold) {
        if (widget.currentIndex > 0) {
          _animateVerticalSnap(SwipeDirection.down);
        } else {
          _animateVerticalBack();
        }
      } else {
        _animateVerticalBack();
      }
    } else if (_isVerticalDrag == false) {
      final screenWidth = MediaQuery.of(context).size.width;
      final threshold = screenWidth * 0.25;

      if (_horizontalOffset > threshold || velocity.dx > velocityThreshold) {
        _animateHorizontalOut(SwipeDirection.right);
      } else if (_horizontalOffset < -threshold || velocity.dx < -velocityThreshold) {
        _animateHorizontalOut(SwipeDirection.left);
      } else {
        _animateHorizontalBack();
      }
    }

    _isVerticalDrag = null;
  }

  void _animateVerticalSnap(SwipeDirection direction) {
    final cardHeight = (_availableHeight ?? 400) + _cardGap;
    final targetOffset = direction == SwipeDirection.up ? -cardHeight : cardHeight;

    _verticalAnimation = Tween<double>(
      begin: _verticalOffset,
      end: targetOffset,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward(from: 0).then((_) {
      widget.onSwipe(direction);
      setState(() {
        _verticalOffset = 0;
        _verticalAnimation = null;
      });
      _animationController.reset();
    });
  }

  void _animateVerticalBack() {
    _verticalAnimation = Tween<double>(
      begin: _verticalOffset,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward(from: 0).then((_) {
      setState(() {
        _verticalOffset = 0;
        _verticalAnimation = null;
      });
      _animationController.reset();
    });
  }

  void _animateHorizontalOut(SwipeDirection direction) {
    final screenWidth = MediaQuery.of(context).size.width;
    final targetX = direction == SwipeDirection.right ? screenWidth * 1.5 : -screenWidth * 1.5;
    final targetRotation = direction == SwipeDirection.right ? 0.3 : -0.3;

    _horizontalAnimation = Tween<Offset>(
      begin: Offset(_horizontalOffset, _rotation),
      end: Offset(targetX, targetRotation),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward(from: 0).then((_) {
      widget.onSwipe(direction);
      setState(() {
        _horizontalOffset = 0;
        _rotation = 0;
        _horizontalAnimation = null;
      });
      _animationController.reset();
    });
  }

  void _animateHorizontalBack() {
    _horizontalAnimation = Tween<Offset>(
      begin: Offset(_horizontalOffset, _rotation),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward(from: 0).then((_) {
      setState(() {
        _horizontalOffset = 0;
        _rotation = 0;
        _horizontalAnimation = null;
      });
      _animationController.reset();
    });
  }

  // Film strip perforation dimensions
  static const double _perforationWidth = 16.0;
  static const double _perforationHeight = 12.0;
  static const double _perforationGap = 24.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight = constraints.maxHeight;
        _availableHeight = cardHeight;

        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Stack(
            children: [
              ClipRect(
                child: SizedBox(
                  width: double.infinity,
                  height: cardHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (widget.currentIndex > 0)
                        Positioned(
                          top: _verticalOffset - cardHeight - _cardGap,
                          left: 0,
                          right: 0,
                          height: cardHeight,
                          child: _buildCard(
                            widget.cards[widget.currentIndex - 1],
                            cardHeight: cardHeight,
                          ),
                        ),
                      Positioned(
                        top: _verticalOffset,
                        left: 0,
                        right: 0,
                        height: cardHeight,
                        child: _buildCurrentCard(cardHeight),
                      ),
                      if (widget.currentIndex < widget.cards.length - 1)
                        Positioned(
                          top: _verticalOffset + cardHeight + _cardGap,
                          left: 0,
                          right: 0,
                          height: cardHeight,
                          child: _buildCard(
                            widget.cards[widget.currentIndex + 1],
                            cardHeight: cardHeight,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              _buildFilmStripOverlay(cardHeight),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilmStripOverlay(double height) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: height,
      child: IgnorePointer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPerforations(height),
            _buildPerforations(height),
          ],
        ),
      ),
    );
  }

  Widget _buildPerforations(double height) {
    final count = (height / (_perforationHeight + _perforationGap)).floor();
    return SizedBox(
      width: _perforationWidth,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(count, (_) => Container(
          width: 10,
          height: _perforationHeight,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(2),
          ),
        )),
      ),
    );
  }

  Widget _buildCurrentCard(double cardHeight) {
    return Transform.translate(
      offset: Offset(_horizontalOffset, 0),
      child: Transform.rotate(
        angle: _rotation,
        child: _buildCardWithIndicators(
          card: widget.cards[widget.currentIndex],
          cardHeight: cardHeight,
        ),
      ),
    );
  }

  Widget _buildCard(T card, {required double cardHeight}) {
    return Opacity(
      opacity: 0.7,
      child: widget.cardBuilder(card, widget.showFront),
    );
  }

  Widget _buildCardWithIndicators({required T card, required double cardHeight}) {
    final horizontalOpacity = (_horizontalOffset.abs() / 100).clamp(0.0, 1.0);
    final verticalOpacity = (_verticalOffset.abs() / 100).clamp(0.0, 1.0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.cardBuilder(card, widget.showFront),

        if (widget.badgeBuilder != null)
          Positioned(
            top: 12,
            left: 12,
            child: widget.badgeBuilder!(card),
          ),

        if (_verticalOffset < -30)
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Opacity(
                opacity: verticalOpacity,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_upward, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context).swipeNext,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ),

        if (_verticalOffset > 30)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Opacity(
                opacity: verticalOpacity,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_downward, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context).swipeBack,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ),

        if (_horizontalOffset > 30)
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: horizontalOpacity,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade100,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.pink.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 2)],
                  ),
                  child: const Icon(Icons.favorite, color: Colors.pink, size: 60),
                ),
              ),
            ),
          ),

        if (_horizontalOffset < -30)
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: horizontalOpacity,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 2)],
                  ),
                  child: const Icon(Icons.eco, color: Colors.green, size: 60),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
