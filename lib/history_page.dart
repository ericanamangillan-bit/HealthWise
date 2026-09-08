import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'check_in_page.dart' show checkInsBoxName;

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box(checkInsBoxName);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('History'),
      ),
      // box.listenable() lets this widget "subscribe" to the Hive box: every
      // time a check-in is added elsewhere (the Check-In screen), Hive
      // notifies this builder and it rebuilds with the new data — no manual
      // refresh button needed.
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box box, _) {
          // Hive doesn't guarantee insertion order matches save order once
          // entries could be edited/deleted, so we sort by the stored date
          // string explicitly rather than relying on box.values' order.
          final entries = box.values.toList()
            ..sort(
              (a, b) => (a['date'] as String).compareTo(b['date'] as String),
            );

          if (entries.isEmpty) {
            return const Center(child: Text('No check-ins yet'));
          }

          final moodSpots = <FlSpot>[];
          final energySpots = <FlSpot>[];
          final stressSpots = <FlSpot>[];

          // x is just "1st valid check-in, 2nd, ..." rather than a real
          // date, which keeps the chart simple. A follow-up could map x to
          // the actual date for proper date labels on the axis.
          //
          // `as num?` (not `as num`) is deliberate: a check-in saved before
          // the Stress field existed (it used to be called Tiredness) has
          // no 'stress' key, so entry['stress'] is null. Casting null
          // straight to num throws; casting to num? just gives null, which
          // we then skip below instead of crashing the whole screen.
          var x = 0.0;
          for (final entry in entries) {
            final mood = entry['mood'] as num?;
            final energy = entry['energy'] as num?;
            final stress = entry['stress'] as num?;
            if (mood == null || energy == null || stress == null) {
              continue;
            }
            moodSpots.add(FlSpot(x, mood.toDouble()));
            energySpots.add(FlSpot(x, energy.toDouble()));
            stressSpots.add(FlSpot(x, stress.toDouble()));
            x += 1;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ChartCard(
                title: 'Mood',
                color: Colors.deepPurple,
                spots: moodSpots,
              ),
              const SizedBox(height: 24),
              _ChartCard(
                title: 'Energy',
                color: Colors.orange,
                spots: energySpots,
              ),
              const SizedBox(height: 24),
              _ChartCard(
                title: 'Stress',
                color: Colors.teal,
                spots: stressSpots,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.color,
    required this.spots,
  });

  final String title;
  final Color color;
  final List<FlSpot> spots;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: LineChart(
            LineChartData(
              minY: 1,
              maxY: 10,
              titlesData: const FlTitlesData(
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: 3),
                ),
              ),
              gridData: const FlGridData(show: true, horizontalInterval: 3),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: color,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
