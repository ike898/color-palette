import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String headline;
  final String subtext;
  final String ctaLabel;
  final VoidCallback onCtaTap;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.headline,
    required this.subtext,
    required this.ctaLabel,
    required this.onCtaTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 24),
            Text(headline,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtext,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCtaTap,
              icon: const Icon(Icons.camera_alt),
              label: Text(ctaLabel),
            ),
          ],
        ),
      ),
    );
  }
}
