import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String checkInsBoxName = 'checkins';

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
      home: const CheckInPage(title: 'Daily Check-In'),
    );
  }
}

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key, required this.title});

  final String title;

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  double _mood = 5;
  double _energy = 5;
  double _tiredness = 5;

  void _saveCheckIn() {
    final entry = {
      'date': DateTime.now().toIso8601String(),
      'mood': _mood.round(),
      'energy': _energy.round(),
      'tiredness': _tiredness.round(),
    };
    Hive.box(checkInsBoxName).add(entry);
    debugPrint(
      'Mood: ${entry['mood']}, Energy: ${entry['energy']}, Tiredness: ${entry['tiredness']}',
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.round()}', style: const TextStyle(fontSize: 18)),
        Slider(
          value: value,
          min: 1,
          max: 10,
          divisions: 9,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSlider(
              label: 'Mood',
              value: _mood,
              onChanged: (v) => setState(() => _mood = v),
            ),
            const SizedBox(height: 16),
            _buildSlider(
              label: 'Energy',
              value: _energy,
              onChanged: (v) => setState(() => _energy = v),
            ),
            const SizedBox(height: 16),
            _buildSlider(
              label: 'Tiredness',
              value: _tiredness,
              onChanged: (v) => setState(() => _tiredness = v),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveCheckIn,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
