import 'package:flutter/material.dart';

import '../data/techniques.dart';
import '../l10n/strings.dart';
import '../models/technique.dart';
import '../theme/app_colors.dart';
import '../widgets/banner_ad_slot.dart';
import '../widgets/common.dart';
import '../widgets/nature_background.dart';
import 'navigation.dart';

/// Two-column grid of technique tiles, shared by Techniques and Favorites.
class TechniqueGrid extends StatelessWidget {
  const TechniqueGrid({super.key, required this.techniques});

  final List<Technique> techniques;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisExtent: 200,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: techniques.length,
      itemBuilder: (context, i) {
        final t = techniques[i];
        return TechniqueTile(
          technique: t,
          onTap: () => openTechnique(context, t),
          onPlay: () => startSession(context, t),
        );
      },
    );
  }
}

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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          children: [
            Text(s.techniquesIntro, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.softText)),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  for (final tag in <TechniqueTag?>[null, ...TechniqueTag.values])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        showCheckmark: false,
                        label: Text(tag == null ? s.all : s.tagLabel(tag)),
                        selected: _filter == tag,
                        onSelected: (_) => setState(() => _filter = tag),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: TechniqueGrid(key: ValueKey(_filter), techniques: list),
            ),
            const BannerAdSlot(padding: EdgeInsets.only(top: 20)),
          ],
        ),
      ),
    );
  }
}
