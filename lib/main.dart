import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'check_in_page.dart';
import 'home_shell.dart';
import 'onboarding_page.dart';
import 'settings_page.dart';

// main() is async because Hive needs to do disk setup (initFlutter) and
// open both boxes *before* the app starts, otherwise the first screen it
// shows could try to read/write a box that isn't ready yet.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(checkInsBoxName);
  await Hive.openBox(settingsBoxName);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box(settingsBoxName);

    // Listening here (the same "listen to a Hive box" pattern used by
    // History/Insights/Settings) means flipping the Dark Mode switch on
    // the Settings screen rebuilds the whole app immediately with the new
    // theme, instead of needing a restart to take effect.
    return ValueListenableBuilder(
      valueListenable: settingsBox.listenable(),
      builder: (context, Box box, _) {
        final onboardingComplete =
            box.get(onboardingCompleteKey, defaultValue: false) as bool;
        final darkModeEnabled =
            box.get(darkModeEnabledKey, defaultValue: false) as bool;

        return MaterialApp(
          title: 'HealthWise',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
          ),
          // themeMode picks a fixed light/dark rather than ThemeMode.system,
          // since the ask was an explicit in-app switch, not "follow the
          // phone's setting".
          themeMode: darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
          home: onboardingComplete ? const HomeShell() : const OnboardingPage(),
        );
      },
    );
  }
}
