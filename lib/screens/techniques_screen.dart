import 'package:flutter/material.dart';

import '../data/techniques.dart';
import '../l10n/strings.dart';
import '../models/technique.dart';
import '../widgets/banner_ad_slot.dart';
import '../widgets/common.dart';
import '../widgets/nature_background.dart';
import 'navigation.dart';

class TechniquesScreen extends StatefulWidget {
  const TechniquesScreen({super.key});

  @override
  State<TechniquesScreen> createState() => _TechniquesScreenState();
}

class _TechniquesScreenState extends State<TechniquesScreen> {
  TechniqueTag? _filter;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final list = _filter == null ? allTechniques : allTechniques.where((t) => t.tags.contains(_filter)).toList();
    return Scaffold(
      appBar: AppBar(title: Text(s.breathingTechniques)),
      body: NatureBackground(
        showHills: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            Text(s.techniquesIntro, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  for (final tag in <TechniqueTag?>[null, ...TechniqueTag.values])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(tag == null ? s.all : s.tagLabel(tag)),
                        selected: _filter == tag,
                        onSelected: (_) => setState(() => _filter = tag),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (final t in list) ...[
              TechniqueCard(technique: t, onTap: () => openTechnique(context, t)),
              const SizedBox(height: 12),
            ],
            const BannerAdSlot(),
          ],
        ),
      ),
    );
  }
}
