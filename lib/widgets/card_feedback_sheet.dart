import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:url_launcher/url_launcher.dart';

import '../config/support_config.dart';
import '../l10n/app_localizations.dart';
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

/// What can be wrong with a card. The label is looked up per locale in
/// [_FeedbackFormState._issueLabel]; the enum keeps the choice language-free.
enum _IssueType { translation, image, pronunciation, meaning, other }

class _FeedbackFormState extends State<_FeedbackForm> {
  _IssueType _issueType = _IssueType.translation;
  final TextEditingController _comment = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  String _issueLabel(_IssueType type, AppLocalizations l10n) => switch (type) {
        _IssueType.translation => l10n.issueTranslation,
        _IssueType.image => l10n.issueImage,
        _IssueType.pronunciation => l10n.issuePronunciation,
        _IssueType.meaning => l10n.issueMeaning,
        _IssueType.other => l10n.issueOther,
      };

  String _subject(AppLocalizations l10n) =>
      l10n.feedbackSubject(widget.card.key, widget.deck.slug);

  String _body(AppLocalizations l10n) {
    final c = widget.card;
    return [
      l10n.feedbackBodyDeck(
        widget.deck.slug,
        '${widget.deck.version}',
        widget.deck.title(widget.l1),
      ),
      l10n.feedbackBodyCard(c.key),
      l10n.feedbackBodyLanguages(widget.l1, widget.l2),
      l10n.feedbackBodyShown(
        c.foreignLabel(widget.l2) ?? '—',
        c.foreignLabel(widget.l1) ?? '—',
      ),
      l10n.feedbackBodyStyle(widget.style),
      l10n.feedbackBodyIssue(_issueLabel(_issueType, l10n)),
      '',
      _comment.text.trim(),
    ].join('\n');
  }

  Future<void> _send() async {
    // Resolved before the first await: the sheet may be gone by the time the
    // mail client hands control back.
    final l10n = AppLocalizations.of(context);
    final subject = _subject(l10n);
    final body = _body(l10n);
    setState(() => _sending = true);
    final uri = Uri(
      scheme: 'mailto',
      path: kSupportEmail,
      // Uri.queryParameters encodes spaces as '+', which mail clients render
      // literally; encodeComponent keeps them as %20.
      query: {'subject': subject, 'body': body}
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
      ClipboardData(
        text: '${l10n.feedbackClipboardTo(kSupportEmail)}\n\n$subject\n\n$body',
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.feedbackNoMailApp(kSupportEmail)),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                Expanded(
                  child: Text(
                    l10n.reportIssue,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600),
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
                for (final type in _IssueType.values)
                  ChoiceChip(
                    label: Text(_issueLabel(type, l10n)),
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
                hintText: l10n.feedbackCommentHint,
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
                label: Text(l10n.feedbackSend),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
