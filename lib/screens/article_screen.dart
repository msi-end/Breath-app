import 'package:flutter/material.dart';

import '../l10n/l_text.dart';
import '../l10n/strings.dart';
import '../models/article.dart';
import '../theme/app_colors.dart';

class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = context.isDark;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: Color.lerp(article.color, dark ? AppColors.night : AppColors.cream, dark ? 0.75 : 0.3),
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      article.color.withValues(alpha: dark ? 0.35 : 0.9),
                      dark ? AppColors.night : AppColors.cream,
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: (dark ? AppColors.nightCard : Colors.white).withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(article.icon, size: 48),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
            sliver: SliverList.list(
              children: [
                Text(context.l(article.title), style: theme.textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(
                  context.s.readMinutes(article.readMinutes),
                  style: theme.textTheme.labelLarge?.copyWith(color: context.softText),
                ),
                const SizedBox(height: 18),
                for (final section in article.sections) ...[
                  if (section.heading != null) ...[
                    const SizedBox(height: 10),
                    Text(context.l(section.heading!), style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                  ],
                  Text(context.l(section.body), style: theme.textTheme.bodyLarge),
                  if (section.bullets.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    for (final b in section.bullets)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Icon(
                                Icons.eco_rounded,
                                size: 16,
                                color: dark ? AppColors.mintDeep : AppColors.sageDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(context.l(b), style: theme.textTheme.bodyLarge)),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: dark ? AppColors.nightCard : AppColors.creamDeep,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(context.s.notMedicalAdvice, style: theme.textTheme.bodySmall),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
