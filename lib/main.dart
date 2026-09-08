import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'check_in_page.dart';
import 'history_page.dart';
import 'insights_page.dart';

// main() is async because Hive needs to do disk setup (initFlutter) and
// open the checkins box *before* the app starts, otherwise the Check-In
// screen would try to write to a box that isn't ready yet.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(checkInsBoxName);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthWise',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  static const _pages = [CheckInPage(), HistoryPage(), InsightsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps both pages alive in memory and just hides the
      // one not selected, instead of destroying/rebuilding it. That's what
      // stops slider values on Check-In from resetting when you tab away.
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.edit_note), label: 'Check-In'),
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'History'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Insights'),
        ],
      ),
    );
  }
}
