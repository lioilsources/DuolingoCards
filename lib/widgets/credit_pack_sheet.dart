import 'package:flutter/material.dart';

import '../models/store_catalog.dart';
import '../services/entitlement_service.dart';

/// Bottom sheet listing all credit packs available for purchase.
void showCreditPackSheet(
  BuildContext context,
  EntitlementService entitlements,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _CreditPackSheet(entitlements: entitlements),
  );
}

class _CreditPackSheet extends StatelessWidget {
  final EntitlementService entitlements;

  const _CreditPackSheet({required this.entitlements});

  @override
  Widget build(BuildContext context) {
    final packs = entitlements.catalog?.creditPacks ?? const [];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Koupit kredity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Kredity slouží k odemykání decků ve všech jazycích.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (packs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text('Obchod není dostupný.'),
              )
            else
              ...packs.map((pack) => _PackTile(
                    pack: pack,
                    price: entitlements.priceForCreditPack(pack.code),
                    onBuy: () {
                      Navigator.of(context).pop();
                      entitlements.purchaseCreditPack(pack.code);
                    },
                  )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _PackTile extends StatelessWidget {
  final CreditPack pack;
  final String? price;
  final VoidCallback onBuy;

  const _PackTile({
    required this.pack,
    required this.price,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              pack.highlighted ? Colors.amber.shade100 : Colors.grey.shade100,
          child: Text(
            '${pack.credits}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: pack.highlighted ? Colors.amber.shade800 : Colors.black87,
            ),
          ),
        ),
        title: Text('${pack.credits} kreditů'),
        subtitle: pack.bonus != null ? Text(pack.bonus!) : null,
        trailing: FilledButton(
          onPressed: price != null ? onBuy : null,
          child: Text(price ?? '...'),
        ),
      ),
    );
  }
}
