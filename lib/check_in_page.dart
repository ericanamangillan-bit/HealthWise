import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String checkInsBoxName = 'checkins';

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  double _mood = 5;
  double _energy = 5;
  double _stress = 5;

  void _saveCheckIn() {
    // Hive stores plain Dart objects (here, a Map) as one record. .add()
    // appends it to the box with an auto-generated key, which is all we
    // need since History reads every record back and sorts by date itself.
    final entry = {
      'date': DateTime.now().toIso8601String(),
      'mood': _mood.round(),
      'energy': _energy.round(),
      'stress': _stress.round(),
    };
    Hive.box(checkInsBoxName).add(entry);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Check-in saved')));
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
        title: const Text('Daily Check-In'),
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
              label: 'Stress',
              value: _stress,
              onChanged: (v) => setState(() => _stress = v),
            ),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: _saveCheckIn, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
