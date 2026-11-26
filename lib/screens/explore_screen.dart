import 'package:flutter/material.dart';

import '../data/explore.dart';
import '../l10n/l_text.dart';
import '../l10n/strings.dart';
import '../models/article.dart';
import '../services/date_utils.dart';
import '../theme/app_colors.dart';
import '../widgets/banner_ad_slot.dart';
import '../widgets/common.dart';
import '../widgets/nature_background.dart';
import '../widgets/youtube.dart';
import 'navigation.dart';

/// The Explore tab: yoga, pranayama, calm practices, herbs, lifestyle tips
/// and breathing guides — all offline, in English and Hindi.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, this.selection});

  /// Lets other parts of the app (e.g. a tapped reminder) open a category.
  final ValueNotifier<ExploreCategory?>? selection;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  ExploreCategory? _category;

  @override
  void initState() {
    super.initState();
    _category = widget.selection?.value;
    widget.selection?.addListener(_onExternalSelection);
  }

  @override
  void dispose() {
    widget.selection?.removeListener(_onExternalSelection);
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onExternalSelection() => _select(widget.selection?.value);

  void _select(ExploreCategory? c) {
    setState(() => _category = c);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final query = _search.text;
    final browsing = _category == null && query.trim().isEmpty;
    final results = browsing ? const <Article>[] : searchExplore(query, category: _category);

    return NatureBackground(
      child: SafeArea(
        bottom: false,
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 28),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.tabExplore, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 2),
                  Text(s.exploreSubtitle, style: theme.textTheme.bodyMedium?.copyWith(color: context.softText)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: s.searchExplore,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: s.clear,
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => setState(_search.clear),
                            ),
                      filled: true,
                      fillColor: context.cardColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _CategoryChips(selected: _category, onSelected: _select),
            if (browsing) ..._browse(context) else ..._list(context, results),
          ],
        ),
      ),
    );
  }

  List<Widget> _browse(BuildContext context) {
    final s = context.s;
    final pick = explorePickOfTheDay(today());
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: _PickOfTheDay(article: pick),
      ),
      for (final (i, info) in exploreCategories.indexed) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader(context.l(info.name), action: s.seeAll, onAction: () => _select(info.category)),
        ),
        SizedBox(
          height: 218,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: exploreItemsIn(info.category).length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, j) => ExploreCard(article: exploreItemsIn(info.category)[j]),
          ),
        ),
        if (i == 1) const BannerAdSlot(padding: EdgeInsets.fromLTRB(20, 20, 20, 0)),
      ],
    ];
  }

  List<Widget> _list(BuildContext context, List<Article> results) {
    final s = context.s;
    final info = _category == null ? null : exploreCategoryInfo(_category!);
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (info != null && _search.text.trim().isEmpty) ...[
              Text(context.l(info.description), style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 14),
            ],
            if (_category == ExploreCategory.pranayama) ...[
              SoftCard(
                color: pastelOf(context, AppColors.sky),
                onTap: () => openTechniques(context),
                child: Row(
                  children: [
                    const IconBadge(Icons.timer_outlined, color: AppColors.skyDeep, size: 44),
                    const SizedBox(width: 14),
                    Expanded(child: Text(s.practiceWithTimer, style: Theme.of(context).textTheme.titleSmall)),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (results.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text(s.noExploreResults, textAlign: TextAlign.center)),
              ),
            for (final (i, a) in results.indexed) ...[
              ExploreListTile(article: a),
              const SizedBox(height: 12),
              if (i == 3) const BannerAdSlot(padding: EdgeInsets.only(bottom: 12)),
            ],
          ],
        ),
      ),
    ];
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelected});

  final ExploreCategory? selected;
  final ValueChanged<ExploreCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          ChoiceChip(
            showCheckmark: false,
            label: Text(s.all),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          for (final info in exploreCategories) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              showCheckmark: false,
              avatar: Icon(info.icon, size: 18),
              label: Text(context.l(info.name)),
              selected: selected == info.category,
              onSelected: (_) => onSelected(info.category),
            ),
          ],
        ],
      ),
    );
  }
}

class _PickOfTheDay extends StatelessWidget {
  const _PickOfTheDay({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = exploreCategoryInfo(article.category);
    final dark = context.isDark;
    return SoftCard(
      padding: EdgeInsets.zero,
      onTap: () => openArticle(context, article),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? [AppColors.forestSoft, AppColors.nightCard]
                : [AppColors.forest, AppColors.forestSoft],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.s.pickOfTheDay.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2, color: AppColors.mintDeep),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l(article.title),
                    style: theme.textTheme.titleLarge?.copyWith(color: AppColors.cream),
                  ),
                  if (article.subtitle != null)
                    Text(
                      context.l(article.subtitle!),
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.cream.withValues(alpha: 0.75)),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    context.l(article.summary),
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.cream.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Pill(text: context.l(info.name), icon: info.icon),
                      if (article.youtubeQuery != null) ...[
                        const SizedBox(width: 8),
                        YoutubeChip(article: article, compact: true),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: info.color.withValues(alpha: 0.35),
              ),
              child: Icon(article.icon, size: 36, color: AppColors.cream),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.cream),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.cream),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card used in the horizontal Explore rows.
class ExploreCard extends StatelessWidget {
  const ExploreCard({super.key, required this.article, this.width = 172});

  final Article article;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = context.isDark;
    return SizedBox(
      width: width,
      child: SoftCard(
        padding: EdgeInsets.zero,
        onTap: () => openArticle(context, article),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 104,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    article.color.withValues(alpha: dark ? 0.4 : 0.95),
                    article.color.withValues(alpha: dark ? 0.12 : 0.45),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Center(child: Icon(article.icon, size: 44, color: dark ? AppColors.cream : AppColors.forest)),
                  if (article.youtubeQuery != null)
                    Positioned(right: 8, top: 8, child: YoutubeChip(article: article, compact: true)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l(article.title),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    article.subtitle != null ? context.l(article.subtitle!) : context.s.readMinutes(article.readMinutes),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: context.softText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Row used in category lists and search results.
class ExploreListTile extends StatelessWidget {
  const ExploreListTile({super.key, required this.article});

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
                if (article.subtitle != null)
                  Text(
                    context.l(article.subtitle!),
                    style: theme.textTheme.labelMedium?.copyWith(color: context.softText),
                  ),
                const SizedBox(height: 2),
                Text(
                  context.l(article.summary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: context.softText),
                ),
              ],
            ),
          ),
          if (article.youtubeQuery != null)
            IconButton(
              tooltip: context.s.watchOnYoutube,
              onPressed: () => openYoutube(context, article),
              icon: const Icon(Icons.smart_display_rounded, color: youtubeRed),
            )
          else
            const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
