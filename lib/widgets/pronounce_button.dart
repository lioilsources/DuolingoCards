import 'package:flutter/material.dart';

import '../services/tts_service.dart';

/// Speaker button that pronounces [text] in [lang] using on-device TTS.
///
/// Implements the chosen no-backend fallback: when the OS has no voice for the
/// language, tapping offers to install one (Android opens the engine's install
/// flow; iOS shows guidance toward Settings), rather than silently failing.
class PronounceButton extends StatefulWidget {
  final String text;
  final String lang;
  final double size;

  const PronounceButton({
    super.key,
    required this.text,
    required this.lang,
    this.size = 28,
  });

  @override
  State<PronounceButton> createState() => _PronounceButtonState();
}

class _PronounceButtonState extends State<PronounceButton> {
  final TtsService _tts = TtsService.instance;
  bool _checking = true;
  bool _available = false;

  @override
  void initState() {
    super.initState();
    _refreshAvailability();
  }

  @override
  void didUpdateWidget(PronounceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lang != widget.lang) _refreshAvailability();
  }

  Future<void> _refreshAvailability() async {
    setState(() => _checking = true);
    final ok = await _tts.isLanguageAvailable(widget.lang);
    if (mounted) {
      setState(() {
        _available = ok;
        _checking = false;
      });
    }
  }

  Future<void> _onTap() async {
    if (_available) {
      await _tts.speak(widget.text, widget.lang);
      return;
    }
    // No voice installed → offer to install (the chosen fallback).
    final messenger = ScaffoldMessenger.of(context);
    final started = await _tts.promptInstallVoice(widget.lang);
    if (!started && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'No "${widget.lang}" voice installed. Add one in Settings → '
            'Accessibility → Spoken Content → Voices, then try again.',
          ),
        ),
      );
    }
    await _refreshAvailability();
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return IconButton(
      iconSize: widget.size,
      tooltip: _available ? 'Pronounce' : 'Install voice',
      icon: Icon(_available ? Icons.volume_up : Icons.volume_off_outlined),
      color: _available ? null : Theme.of(context).disabledColor,
      onPressed: widget.text.isEmpty ? null : _onTap,
    );
  }
}
