import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/strings.dart';
import '../services/account_service.dart';
import '../services/ads_service.dart';
import '../services/usage_tracker.dart';
import '../theme/app_colors.dart';
import '../widgets/account_invite_dialog.dart';
import '../widgets/music/music_widgets.dart';
import 'home_screen.dart';
import 'learn_screen.dart';
import 'music/music_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AdsService.instance.initialize();
      if (mounted) _maybeInviteToAccount();
    });
  }

  Future<void> _maybeInviteToAccount() async {
    final usage = context.read<UsageTracker>();
    final account = context.read<AccountService>();
    if (!account.available || !usage.shouldInviteToAccount(signedIn: account.signedIn)) return;
    // Never interrupt an exercise: only show while the shell is the top route.
    if (ModalRoute.of(context)?.isCurrent != true) return;
    await usage.markInvited();
    if (!mounted) return;
    await showAccountInviteDialog(context);
  }

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          // Hidden tabs are ticker-disabled, which also keeps their banner ads
          // unloaded: an ad is only requested when it can actually be seen.
          for (final (i, page) in [
            HomeScreen(onOpenProgress: () => _select(3)),
            const LearnScreen(),
            const MusicScreen(),
            const ProgressScreen(),
            const SettingsScreen(),
          ].indexed)
            TickerMode(enabled: i == _index, child: page),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Persistent mini player — music keeps playing across tabs.
          const MiniPlayer(),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: context.isDark ? Border.all(color: AppColors.nightLine) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: context.isDark ? 0.35 : 0.07),
                    blurRadius: 24,
                    spreadRadius: -6,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: MediaQuery.removePadding(
                  context: context,
                  removeBottom: true,
                  child: NavigationBar(
                    height: 66,
                    selectedIndex: _index,
                    onDestinationSelected: _select,
                    destinations: [
                      NavigationDestination(
                        icon: const Icon(Icons.home_outlined),
                        selectedIcon: const Icon(Icons.home_rounded),
                        label: s.tabHome,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.menu_book_outlined),
                        selectedIcon: const Icon(Icons.menu_book_rounded),
                        label: s.tabLearn,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.music_note_outlined),
                        selectedIcon: const Icon(Icons.music_note_rounded),
                        label: s.musicTab,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.insights_outlined),
                        selectedIcon: const Icon(Icons.insights_rounded),
                        label: s.tabProgress,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.settings_outlined),
                        selectedIcon: const Icon(Icons.settings_rounded),
                        label: s.tabSettings,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
