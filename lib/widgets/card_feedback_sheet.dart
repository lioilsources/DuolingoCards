import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:url_launcher/url_launcher.dart';

import '../config/support_config.dart';
import '../models/language_deck.dart';

/// Bottom-sheet form for reporting a broken card.
///
/// No backend, so the report is a pre-filled e-mail: the form only picks the
/// issue type and an optional comment, everything needed to find the card
/// (deck, key, language pair, style) is packed into the body automatically.
/// When no mail client is available the same text is copied to the clipboard
/// instead — a report the user typed must never be silently lost.
Future<void> showCardFeedbackSheet(
  BuildContext context, {
  required LanguageDeck deck,
  required LanguageCard card,
  required String l1,
  required String l2,
  required String style,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _FeedbackForm(
        deck: deck,
        card: card,
        l1: l1,
        l2: l2,
        style: style,
      ),
    ),
  );
}

class _FeedbackForm extends StatefulWidget {
  final LanguageDeck deck;
  final LanguageCard card;
  final String l1;
  final String l2;
  final String style;

  const _FeedbackForm({
    required this.deck,
    required this.card,
    required this.l1,
    required this.l2,
    required this.style,
  });

  @override
  State<_FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<_FeedbackForm> {
  static const _issueTypes = [
    'Překlad',
    'Obrázek',
    'Výslovnost',
    'Význam / fakta',
    'Jiné',
  ];

  String _issueType = _issueTypes.first;
  final TextEditingController _comment = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  String get _subject =>
      '[Lexify] Chyba na kartě ${widget.card.key} (${widget.deck.slug})';

  String get _body {
    final c = widget.card;
    return [
      'Deck: ${widget.deck.slug} v${widget.deck.version}'
          ' (${widget.deck.title(widget.l1)})',
      'Karta: ${c.key}',
      'Jazyky: ${widget.l1} → ${widget.l2}',
      'Zobrazeno: ${c.foreignLabel(widget.l2) ?? '—'}'
          ' / ${c.foreignLabel(widget.l1) ?? '—'}',
      'Styl: ${widget.style}',
      'Typ chyby: $_issueType',
      '',
      _comment.text.trim(),
    ].join('\n');
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    final uri = Uri(
      scheme: 'mailto',
      path: kSupportEmail,
      // Uri.queryParameters encodes spaces as '+', which mail clients render
      // literally; encodeComponent keeps them as %20.
      query: {'subject': _subject, 'body': _body}
          .entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&'),
    );

    var launched = false;
    try {
      launched = await launchUrl(uri);
    } catch (_) {}

    if (!mounted) return;
    setState(() => _sending = false);

    if (launched) {
      Navigator.of(context).pop();
      return;
    }

    // No mail client (typical on tablets and simulators) — the report still
    // has to leave the device somehow, so hand it over via the clipboard.
    await Clipboard.setData(
      ClipboardData(text: 'Komu: $kSupportEmail\n\n$_subject\n\n$_body'),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'E-mailová aplikace není k dispozici — hlášení je zkopírované '
          'do schránky, pošli ho prosím na $kSupportEmail.',
        ),
        duration: Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag_outlined, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Nahlásit chybu',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  widget.card.key,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final type in _issueTypes)
                  ChoiceChip(
                    label: Text(type),
                    selected: _issueType == type,
                    onSelected: (_) => setState(() => _issueType = type),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _comment,
              maxLines: 3,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Co je špatně? (nepovinné)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _sending ? null : _send,
                icon: const Icon(Icons.mail_outline),
                label: const Text('Odeslat e-mailem'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
