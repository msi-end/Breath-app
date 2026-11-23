import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/strings.dart';
import '../services/account_service.dart';
import '../services/ads_service.dart';
import '../services/usage_tracker.dart';
import '../widgets/account_invite_dialog.dart';
import 'home_screen.dart';
import 'learn_screen.dart';
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
            HomeScreen(onOpenProgress: () => _select(2)),
            const LearnScreen(),
            const ProgressScreen(),
            const SettingsScreen(),
          ].indexed)
            TickerMode(enabled: i == _index, child: page),
        ],
      ),
      bottomNavigationBar: NavigationBar(
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
    );
  }
}
