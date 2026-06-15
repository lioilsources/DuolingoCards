import 'package:flutter/material.dart';

/// Displays the current credit balance and a button to open the credit shop.
class CreditBalanceHeader extends StatelessWidget {
  final int balance;
  final VoidCallback onBuyCredits;

  const CreditBalanceHeader({
    super.key,
    required this.balance,
    required this.onBuyCredits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.toll_rounded, size: 22),
          const SizedBox(width: 8),
          Text(
            '$balance kreditů',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const Spacer(),
          FilledButton.tonal(
            onPressed: onBuyCredits,
            child: const Text('+ Koupit'),
          ),
        ],
      ),
    );
  }
}
