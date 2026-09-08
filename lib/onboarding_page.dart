import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'home_shell.dart';

const String settingsBoxName = 'settings';
const String onboardingCompleteKey = 'onboardingComplete';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  void _getStarted(BuildContext context) {
    // Remembers that onboarding has been seen, so main.dart sends future
    // launches straight to HomeShell instead of showing this screen again.
    Hive.box(settingsBoxName).put(onboardingCompleteKey, true);
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Icon(Icons.favorite, size: 72, color: colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'Welcome to HealthWise',
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'A simple daily check-in to track how you feel, spot '
                'patterns over time, and learn what affects your energy.',
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              const _OnboardingStep(
                icon: Icons.edit_note,
                title: 'Check in daily',
                subtitle: 'Rate your Mood, Energy and Stress in seconds.',
              ),
              const SizedBox(height: 24),
              const _OnboardingStep(
                icon: Icons.show_chart,
                title: 'See your history',
                subtitle: 'Watch trends unfold on simple line charts.',
              ),
              const SizedBox(height: 24),
              const _OnboardingStep(
                icon: Icons.insights,
                title: 'Get insights',
                subtitle: 'Discover how Stress relates to your Energy.',
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _getStarted(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Get Started'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// One row of the feature list: a circular icon plus a title/subtitle pair.
// Pulled out into its own widget purely to avoid repeating the same Row
// layout three times above.
class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(icon, color: colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.titleMedium),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
