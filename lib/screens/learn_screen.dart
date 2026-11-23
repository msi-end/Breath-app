import 'package:flutter/material.dart';

import '../data/articles.dart';
import '../l10n/l_text.dart';
import '../l10n/strings.dart';
import '../models/article.dart';
import '../theme/app_colors.dart';
import '../widgets/banner_ad_slot.dart';
import '../widgets/common.dart';
import '../widgets/nature_background.dart';
import 'navigation.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final featured = allArticles.first;
    final rest = allArticles.skip(1).toList();
    return NatureBackground(
      showHills: false,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(s.tabLearn, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(s.learnSubtitle, style: theme.textTheme.bodyMedium?.copyWith(color: context.softText)),
            const SizedBox(height: 20),
            _FeaturedArticle(article: featured),
            SectionHeader(s.allArticles),
            for (var i = 0; i < rest.length; i++) ...[
              _ArticleTile(article: rest[i]),
              const SizedBox(height: 12),
              if (i == 3) const BannerAdSlot(padding: EdgeInsets.only(bottom: 12)),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeaturedArticle extends StatelessWidget {
  const _FeaturedArticle({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = context.isDark;
    return SoftCard(
      padding: EdgeInsets.zero,
      onTap: () => openArticle(context, article),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 130,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              gradient: LinearGradient(
                colors: [
                  article.color.withValues(alpha: dark ? 0.35 : 0.9),
                  article.color.withValues(alpha: dark ? 0.15 : 0.4),
                ],
              ),
            ),
            child: Center(child: Icon(article.icon, size: 56)),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.s.featured.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2, color: context.softText),
                ),
                const SizedBox(height: 6),
                Text(context.l(article.title), style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(context.l(article.summary), style: theme.textTheme.bodyMedium?.copyWith(color: context.softText)),
                const SizedBox(height: 8),
                Text(context.s.readMinutes(article.readMinutes), style: theme.textTheme.labelMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  const _ArticleTile({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      onTap: () => openArticle(context, article),
      child: Row(
        children: [
          IconBadge(article.icon, color: article.color, size: 54),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l(article.title), style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  context.l(article.summary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: context.softText),
                ),
                const SizedBox(height: 6),
                Text(context.s.readMinutes(article.readMinutes), style: theme.textTheme.labelSmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
