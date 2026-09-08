import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'onboarding_page.dart' show settingsBoxName;

const String darkModeEnabledKey = 'darkModeEnabled';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box(settingsBoxName);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Settings'),
      ),
      // Same listen-to-Hive pattern as History/Insights: rebuilds this
      // switch immediately if the value ever changes from elsewhere.
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box box, _) {
          final darkModeEnabled =
              box.get(darkModeEnabledKey, defaultValue: false) as bool;

          return SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use a dark color scheme throughout the app'),
            value: darkModeEnabled,
            onChanged: (value) => box.put(darkModeEnabledKey, value),
          );
        },
      ),
    );
  }
}
