import 'package:flutter/material.dart';

import '../data/legal.dart';
import '../l10n/l_text.dart';
import '../l10n/strings.dart';
import '../theme/app_colors.dart';
import '../widgets/logo.dart';
import '../widgets/common.dart';
import '../widgets/nature_background.dart';

enum InfoKind { privacy, terms, about }

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key, required this.kind});

  final InfoKind kind;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final (title, sections) = switch (kind) {
      InfoKind.privacy => (s.privacyPolicy, privacySections),
      InfoKind.terms => (s.terms, termsSections),
      InfoKind.about => (s.aboutApp, aboutSections),
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: NatureBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
          children: [
            if (kind == InfoKind.about) ...[
              const Center(child: BreatheCareLogo(size: 120, tile: true)),
              const SizedBox(height: 12),
              Text('BreatheCare', textAlign: TextAlign.center, style: theme.textTheme.headlineMedium),
              Text(
                s.versionLabel('1.0.0'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: context.softText),
              ),
              const SizedBox(height: 16),
            ] else ...[
              Text(s.lastUpdated, style: theme.textTheme.labelMedium?.copyWith(color: context.softText)),
              const SizedBox(height: 12),
            ],
            for (final sec in sections) ...[
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l(sec.heading), style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(context.l(sec.body), style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
