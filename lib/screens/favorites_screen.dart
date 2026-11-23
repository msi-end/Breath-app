import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/techniques.dart';
import '../l10n/strings.dart';
import '../services/progress_store.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/nature_background.dart';
import 'navigation.dart';
import 'techniques_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final store = context.watch<ProgressStore>();
    final list = allTechniques.where((t) => store.isFavorite(t.id)).toList();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.favorites)),
      body: NatureBackground(
        showHills: list.isEmpty,
        child: list.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const IconBadge(Icons.favorite_border_rounded, color: AppColors.blush, size: 80),
                      const SizedBox(height: 20),
                      Text(s.noFavoritesTitle, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text(
                        s.noFavoritesBody,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(color: context.softText),
                      ),
                      const SizedBox(height: 22),
                      FilledButton(onPressed: () => openTechniques(context), child: Text(s.exploreTechniques)),
                    ],
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                children: [TechniqueGrid(techniques: list)],
              ),
      ),
    );
  }
}
