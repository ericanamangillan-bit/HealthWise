import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'check_in_page.dart' show checkInsBoxName;

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box(checkInsBoxName);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Insights'),
      ),
      // Same pattern as History: listen directly to the Hive box so this
      // screen updates itself the moment a new check-in is saved.
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box box, _) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                _buildInsightText(box.values.toList()),
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }

  // Splits check-ins into two groups by Stress (>7 vs <=7), averages
  // Energy within each group, and turns the comparison into one sentence.
  // Stress and Energy are independent sliders (unlike Tiredness, which is
  // basically the inverse of Energy), so this comparison can actually
  // surface something the raw numbers don't already say outright.
  // Returns a friendly placeholder instead of comparing when either group
  // is empty, since averaging zero days isn't a meaningful comparison.
  String _buildInsightText(List<dynamic> entries) {
    if (entries.isEmpty) {
      return 'No check-ins yet — save a few days to see insights here.';
    }

    final stressedEnergies = <num>[];
    final calmEnergies = <num>[];

    // `as num?` (not `as num`): a check-in saved before the Stress field
    // existed (it used to be called Tiredness) has no 'stress' key, so
    // entry['stress'] is null. Casting straight to num throws on that; we
    // cast to num? instead and just skip entries missing either value.
    for (final entry in entries) {
      final stress = entry['stress'] as num?;
      final energy = entry['energy'] as num?;
      if (stress == null || energy == null) {
        continue;
      }
      if (stress > 7) {
        stressedEnergies.add(energy);
      } else {
        calmEnergies.add(energy);
      }
    }

    if (stressedEnergies.isEmpty || calmEnergies.isEmpty) {
      return "Not enough data yet — once you've logged check-ins on both "
          'high-stress (Stress > 7) and lower-stress (Stress ≤ 7) '
          "days, we'll compare your energy across them.";
    }

    final stressedAvg =
        stressedEnergies.reduce((a, b) => a + b) / stressedEnergies.length;
    final calmAvg =
        calmEnergies.reduce((a, b) => a + b) / calmEnergies.length;

    final comparison = stressedAvg > calmAvg
        ? 'higher'
        : stressedAvg < calmAvg
        ? 'lower'
        : 'about the same';

    return 'On days Stress was above 7, average Energy was '
        '${stressedAvg.toStringAsFixed(1)}. On days Stress was 7 or below, '
        'average Energy was ${calmAvg.toStringAsFixed(1)} — energy '
        'tends to be $comparison on your most stressful days.';
  }
}
