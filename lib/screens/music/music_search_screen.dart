import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l_text.dart';
import '../../l10n/strings.dart';
import '../../models/music.dart';
import '../../services/music_library.dart';
import '../../theme/app_colors.dart';
import '../../widgets/music/music_widgets.dart';
import 'music_category_screen.dart' show SortButton;

/// Search by track, artist or category, with category filters and sorting.
class MusicSearchScreen extends StatefulWidget {
  const MusicSearchScreen({super.key, this.initialCategory});

  final String? initialCategory;

  @override
  State<MusicSearchScreen> createState() => _MusicSearchScreenState();
}

class _MusicSearchScreenState extends State<MusicSearchScreen> {
  final _controller = TextEditingController();
  late String? _category = widget.initialCategory;
  MusicSort _sort = MusicSort.featured;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final library = context.watch<MusicLibrary>();
    final results = library.search(_controller.text, categoryId: _category, sort: _sort, lang: context.lang);
    final categories = library.hasTracks ? library.activeCategories : <MusicCategory>[];

    return Scaffold(
      bottomNavigationBar: const SafeArea(child: MiniPlayer()),
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _controller,
            autofocus: widget.initialCategory == null,
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: s.searchMusic,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: s.clear,
                      onPressed: () => setState(_controller.clear),
                      icon: const Icon(Icons.close_rounded),
                    ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                for (final c in <MusicCategory?>[null, ...categories])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      showCheckmark: false,
                      avatar: c == null ? null : Icon(c.icon, size: 16),
                      label: Text(c == null ? s.all : c.name.get(context.lang)),
                      selected: _category == c?.id,
                      onSelected: (_) => setState(() => _category = c?.id),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  s.resultsCount(results.length),
                  style: theme.textTheme.labelLarge?.copyWith(color: context.softText),
                ),
              ),
              SortButton(value: _sort, onChanged: (v) => setState(() => _sort = v)),
            ],
          ),
          if (results.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 48, color: context.softText),
                  const SizedBox(height: 12),
                  Text(
                    library.hasTracks ? s.noResults : s.musicEmptyBody,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: context.softText),
                  ),
                ],
              ),
            )
          else
            for (final t in results) TrackTile(track: t, queue: results),
        ],
      ),
    );
  }
}
