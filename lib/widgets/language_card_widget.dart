import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../config/cdn_config.dart';
import '../models/language_deck.dart';
import '../utils/locale_direction.dart';
import 'pronounce_button.dart';

class LanguageCardWidget extends StatefulWidget {
  final LanguageCard card;
  final String l1;
  final String l2;
  final String slug;
  final String style;
  final bool showFront;
  final VoidCallback? onTap;

  /// When set, a small flag button sits in the card's corner and reports a
  /// problem with this card (wrong translation, image, ...).
  final VoidCallback? onReport;
  /// Path to the app documents directory. When provided, images are loaded
  /// from `docsDir/decks/slug/images/style/` if the file exists; otherwise
  /// the bundled asset is used with a CDN fallback.
  final String? docsDir;

  const LanguageCardWidget({
    super.key,
    required this.card,
    required this.l1,
    required this.l2,
    required this.slug,
    required this.style,
    required this.showFront,
    this.onTap,
    this.onReport,
    this.docsDir,
  });

  @override
  State<LanguageCardWidget> createState() => _LanguageCardWidgetState();
}

class _LanguageCardWidgetState extends State<LanguageCardWidget>
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
    // When starting on the back face, position animation at end so the
    // back face is visible immediately (angle = π > π/2 → isFrontVisible=false).
    if (!_showingFront) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(LanguageCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showFront != widget.showFront) {
      _doFlip();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Returns the card image from the best available source:
  /// 1. Local file in docsDir (downloaded deck)
  /// 2. Bundled asset (tier-0 or legacy deck)
  /// 3. CDN via CachedNetworkImage (fallback for CDN-only decks)
  Widget _buildCardImage() {
    final image = widget.card.image;
    if (image.isEmpty) return const SizedBox.shrink();

    final docsDir = widget.docsDir;
    if (docsDir != null) {
      final file = File(
          '$docsDir/decks/${widget.slug}/images/${widget.style}/$image');
      if (file.existsSync()) {
        return Image.file(file,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => _imagePlaceholder());
      }
    }

    // Try bundled asset, fall back to CDN.
    return Image.asset(
      'decks/${widget.slug}/images/${widget.style}/$image',
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => CachedNetworkImage(
        imageUrl:
            '$kCdnBaseUrl/decks/${widget.slug}/images/${widget.style}/$image',
        fit: BoxFit.contain,
        placeholder: (_, _) => const Center(child: CircularProgressIndicator()),
        errorWidget: (_, _, _) => _imagePlaceholder(),
      ),
    );
  }

  Widget _imagePlaceholder() =>
      Icon(Icons.image_outlined, size: 80, color: Colors.grey.shade300);

  void _doFlip() {
    if (_controller.isAnimating) return;
    if (_showingFront) {
      _controller.forward().then((_) {
        if (mounted) setState(() => _showingFront = false);
      });
    } else {
      _controller.reverse().then((_) {
        if (mounted) setState(() => _showingFront = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final flipCard = AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final angle = _animation.value * pi;
        final isFrontVisible = angle < pi / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: isFrontVisible
              ? _buildFront()
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: _buildBack(),
                ),
        );
      },
    );

    return GestureDetector(
      onLongPress: widget.onTap, // parent toggles showFront → didUpdateWidget → _doFlip
      child: widget.onReport == null
          ? flipCard
          // The button lives outside the flip Transform: it must not mirror
          // with the card, and IconButton swallows its own taps so swipes and
          // long-press elsewhere on the card are unaffected.
          : Stack(
              children: [
                flipCard,
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    onPressed: widget.onReport,
                    tooltip: 'Nahlásit chybu',
                    icon: Icon(
                      Icons.flag_outlined,
                      size: 18,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFront() {
    final label = widget.card.foreignLabel(widget.l2) ?? '—';
    final summary = widget.card.foreignSummary(widget.l2) ?? '';
    final theme = Theme.of(context);

    return _CardFace(
      color: Colors.white,
      child: Column(
        children: [
          if (widget.card.image.isNotEmpty)
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildCardImage(),
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: DirectionalText(
                        label,
                        lang: widget.l2,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PronounceButton(text: label, lang: widget.l2),
                  ],
                ),
                if (summary.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  DirectionalText(
                    summary,
                    lang: widget.l2,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    final label = widget.card.nativeLabel(widget.l1) ?? '—';
    final info = widget.card.nativeInfo(widget.l1) ?? '';
    final theme = Theme.of(context);

    return _CardFace(
      color: Colors.blue.shade50,
      child: Column(
        children: [
          if (widget.card.image.isNotEmpty)
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildCardImage(),
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: DirectionalText(
                        label,
                        lang: widget.l1,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PronounceButton(text: label, lang: widget.l1),
                  ],
                ),
                if (info.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DirectionalText(
                    info,
                    lang: widget.l1,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final Color color;
  final Widget child;

  const _CardFace({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: child,
    );
  }
}
