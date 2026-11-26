import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/strings.dart';
import '../services/account_service.dart';
import '../services/ads_service.dart';
import '../services/usage_tracker.dart';
import '../theme/app_colors.dart';
import '../widgets/account_invite_dialog.dart';
import '../widgets/music/music_widgets.dart';
import '../data/explore.dart';
import '../data/music_categories.dart';
import '../data/techniques.dart';
import '../models/article.dart';
import '../services/reminder_service.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'music/music_nav.dart';
import 'navigation.dart';
import 'music/music_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  static const _home = 0, _listen = 1, _explore = 2, _progress = 3;

  int _index = _home;
  final _exploreCategory = ValueNotifier<ExploreCategory?>(null);
  ReminderService? _reminders;

  @override
  void initState() {
    super.initState();
    final reminders = context.read<ReminderService?>();
    _reminders = reminders;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (reminders != null) {
        reminders.onOpen = _openFromReminder;
        final launch = reminders.takeLaunchPayload();
        if (launch != null) {
          _openFromReminder(launch);
          return; // Don't stack prompts on top of where the reminder led.
        }
      }
      await AdsService.instance.initialize();
      if (!mounted) return;
      final invited = await _maybeInviteToAccount();
      if (!invited && mounted) await _maybeOfferReminder();
    });
  }

  @override
  void dispose() {
    if (_reminders?.onOpen == _openFromReminder) _reminders?.onOpen = null;
    _exploreCategory.dispose();
    super.dispose();
  }

  Future<bool> _maybeInviteToAccount() async {
    final usage = context.read<UsageTracker>();
    final account = context.read<AccountService>();
    if (!account.available || !usage.shouldInviteToAccount(signedIn: account.signedIn)) return false;
    // Never interrupt an exercise: only show while the shell is the top route.
    if (ModalRoute.of(context)?.isCurrent != true) return false;
    await usage.markInvited();
    if (!mounted) return false;
    await showAccountInviteDialog(context);
    return true;
  }

  /// Offers the morning reminder once, when the user comes back on a second day.
  Future<void> _maybeOfferReminder() async {
    final reminders = _reminders;
    final usage = context.read<UsageTracker>();
    if (reminders == null || !reminders.shouldAsk(activeDays: usage.activeDayCount)) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;
    await reminders.markAsked();
    if (!mounted) return;
    final s = context.s;
    final time = MaterialLocalizations.of(context).formatTimeOfDay(reminders.morningTime);
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        icon: const Icon(Icons.notifications_active_outlined),
        title: Text(s.reminderInviteTitle),
        content: Text(s.reminderInviteBody(time)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(s.notNow)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(s.turnOn)),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    final ok = await reminders.setMorning(true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? s.reminderOn : s.notificationsBlocked)));
  }

  /// Takes the user where a tapped reminder points.
  void _openFromReminder(String payload) {
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
    final parts = payload.split(':');
    final kind = parts.first;
    final arg = parts.length > 1 ? parts[1] : null;
    switch (kind) {
      case 'breathe':
        _select(_home);
        final t = (arg == null ? null : techniqueById(arg)) ?? todaysTechnique();
        openTechnique(context, t);
      case 'explore':
        _select(_explore);
        _exploreCategory.value = arg == null ? null : exploreCategoryByName(arg);
      case 'music':
        _select(_listen);
        final cat = arg == null ? null : musicCategoryById(arg);
        if (cat != null) openMusicCategory(context, cat);
      case 'challenge':
        _select(_home);
        openChallenges(context);
      default:
        _select(_home);
    }
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
            HomeScreen(onOpenProgress: () => _select(_progress)),
            const MusicScreen(),
            ExploreScreen(selection: _exploreCategory),
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
                        icon: const Icon(Icons.headphones_outlined),
                        selectedIcon: const Icon(Icons.headphones_rounded),
                        label: s.musicTab,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.explore_outlined),
                        selectedIcon: const Icon(Icons.explore_rounded),
                        label: s.tabExplore,
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
