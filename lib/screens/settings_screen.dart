import 'package:flutter/material.dart';
import 'package:ol1n_telemetry/ol1n_telemetry.dart';

import '../l10n/app_localizations.dart';
import '../telemetry/telemetry_setup.dart';

/// Settings. Today it holds one thing: the anonymous statistics switch, shown
/// only where measuring can run ([telemetryToggleVisible]).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (telemetryToggleVisible())
            SwitchListTile(
              key: const ValueKey('telemetry-switch'),
              title: Text(l10n.statsToggle),
              subtitle: Text(l10n.statsToggleSubtitle),
              value: Telemetry.isEnabled,
              onChanged: (on) async {
                await Telemetry.setEnabled(on);
                if (mounted) setState(() {});
              },
            ),
        ],
      ),
    );
  }
}
