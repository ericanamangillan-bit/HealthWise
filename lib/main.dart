import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'check_in_page.dart';
import 'home_shell.dart';
import 'onboarding_page.dart';

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
    // Hive reads are synchronous once a box is open (no "await" needed), so
    // this can happen right here in build() rather than in an async method.
    // defaultValue: false means a first-ever launch (no key saved yet) is
    // treated as "onboarding not seen".
    final onboardingComplete = Hive.box(
      settingsBoxName,
    ).get(onboardingCompleteKey, defaultValue: false) as bool;

    return MaterialApp(
      title: 'HealthWise',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: onboardingComplete ? const HomeShell() : const OnboardingPage(),
    );
  }
}
