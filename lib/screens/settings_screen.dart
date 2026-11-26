import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/strings.dart';
import '../services/account_service.dart';
import '../services/ads_service.dart';
import '../services/audio_download_service.dart';
import '../services/music_downloads.dart';
import '../services/music_player.dart';
import '../services/my_music_store.dart';
import '../services/progress_store.dart';
import '../services/reminder_service.dart';
import '../services/settings_controller.dart';
import '../services/usage_tracker.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/nature_background.dart';
import 'account_screen.dart';
import 'audio_library_screen.dart';
import 'info_screen.dart';
import 'music/music_nav.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final settings = context.watch<SettingsController>();
    final account = context.watch<AccountService>();
    final audio = context.watch<AudioDownloadService>();
    final theme = Theme.of(context);

    void push(Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

    return NatureBackground(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Text(s.tabSettings, style: theme.textTheme.headlineMedium),
            SectionHeader(s.preferences),
            _Group(
              children: [
                ListTile(
                  leading: const IconBadge(Icons.translate_rounded, color: AppColors.sky, size: 38),
                  title: Text(s.language),
                  subtitle: Text(settings.lang == 'hi' ? 'हिन्दी' : 'English'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _pickLanguage(context, settings),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const IconBadge(Icons.palette_outlined, color: AppColors.blush, size: 38),
                          const SizedBox(width: 16),
                          Text(s.theme, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ThemeMode>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(value: ThemeMode.light, label: Text(s.light)),
                            ButtonSegment(value: ThemeMode.dark, label: Text(s.dark)),
                            ButtonSegment(value: ThemeMode.system, label: Text(s.system)),
                          ],
                          selected: {settings.themeMode},
                          onSelectionChanged: (v) => settings.setThemeMode(v.first),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SectionHeader(s.audioSettings),
            _Group(
              children: [
                SwitchListTile(
                  secondary: const IconBadge(Icons.record_voice_over_outlined, color: AppColors.mintDeep, size: 38),
                  title: Text(s.voiceGuidance),
                  subtitle: Text(s.voiceGuidanceSub),
                  value: settings.voiceGuidance,
                  onChanged: settings.setVoiceGuidance,
                ),
                ListTile(
                  leading: const IconBadge(Icons.volume_up_outlined, color: AppColors.mintDeep, size: 38),
                  title: Text(s.voiceVolume),
                  subtitle: Slider(
                    value: settings.voiceVolume,
                    divisions: 10,
                    label: '${(settings.voiceVolume * 100).round()}%',
                    onChanged: settings.voiceGuidance ? settings.setVoiceVolume : null,
                  ),
                ),
                SwitchListTile(
                  secondary: const IconBadge(Icons.vibration_rounded, color: AppColors.lavender, size: 38),
                  title: Text(s.hapticCues),
                  subtitle: Text(s.hapticCuesSub),
                  value: settings.haptics,
                  onChanged: settings.setHaptics,
                ),
                SwitchListTile(
                  secondary: const IconBadge(Icons.air_rounded, color: AppColors.sky, size: 38),
                  title: Text(s.gentleModeDefault),
                  subtitle: Text(s.gentleModeSub),
                  value: settings.gentleModeDefault,
                  onChanged: settings.setGentleModeDefault,
                ),
                ListTile(
                  leading: const IconBadge(Icons.download_for_offline_outlined, color: AppColors.sun, size: 38),
                  title: Text(s.downloadedAudio),
                  subtitle: Text(s.downloadedCount(audio.downloadedIds.length, formatBytes(audio.totalBytes))),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => push(const AudioLibraryScreen()),
                ),
                SwitchListTile(
                  secondary: const IconBadge(Icons.offline_pin_outlined, color: AppColors.mint, size: 38),
                  title: Text(s.autoSaveMusic),
                  subtitle: Text(s.autoSaveMusicSub),
                  value: context.watch<MusicDownloads>().autoSave,
                  onChanged: context.read<MusicDownloads>().setAutoSave,
                ),
                ListTile(
                  leading: const IconBadge(Icons.library_music_outlined, color: AppColors.lavender, size: 38),
                  title: Text(s.downloadedMusic),
                  subtitle: Text(
                    s.downloadedCount(
                      context.watch<MusicDownloads>().downloadedIds.length,
                      formatBytes(context.watch<MusicDownloads>().totalBytes),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => openMyMusic(context, tab: 2),
                ),
              ],
            ),
            const _RemindersGroup(),
            SectionHeader(s.account),
            _Group(
              children: [
                ListTile(
                  leading: const IconBadge(Icons.account_circle_outlined, color: AppColors.mint, size: 38),
                  title: Text(account.signedIn ? s.signedInAs(account.userId ?? '') : s.accountAndBackup),
                  subtitle: Text(account.signedIn ? s.backupAvailable : s.accountOptional),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => push(const AccountScreen()),
                ),
              ],
            ),
            SectionHeader(s.aboutSection),
            _Group(
              children: [
                ListTile(
                  leading: const IconBadge(Icons.privacy_tip_outlined, color: AppColors.lavender, size: 38),
                  title: Text(s.privacyPolicy),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => push(const InfoScreen(kind: InfoKind.privacy)),
                ),
                ListTile(
                  leading: const IconBadge(Icons.description_outlined, color: AppColors.sky, size: 38),
                  title: Text(s.terms),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => push(const InfoScreen(kind: InfoKind.terms)),
                ),
                ListTile(
                  leading: const IconBadge(Icons.spa_outlined, color: AppColors.mintDeep, size: 38),
                  title: Text(s.aboutApp),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => push(const InfoScreen(kind: InfoKind.about)),
                ),
                if (AdsService.instance.privacyOptionsRequired)
                  ListTile(
                    leading: const IconBadge(Icons.ads_click_outlined, color: AppColors.sun, size: 38),
                    title: Text(s.adPrivacy),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => AdsService.instance.showPrivacyOptions(),
                  ),
              ],
            ),
            SectionHeader(s.yourData),
            _Group(
              children: [
                ListTile(
                  leading: const IconBadge(Icons.delete_forever_outlined, color: AppColors.blush, size: 38),
                  title: Text(s.deleteMyData, style: TextStyle(color: theme.colorScheme.error)),
                  subtitle: Text(s.deleteMyDataSub),
                  onTap: () => _confirmDeleteAll(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Text('BreatheCare · v1.0.0', style: theme.textTheme.labelSmall?.copyWith(color: context.softText)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickLanguage(BuildContext context, SettingsController settings) async {
    final s = context.s;
    final lang = await showModalBottomSheet<String>(
      context: context,
      builder: (c) => SafeArea(
        child: RadioGroup<String>(
          groupValue: settings.lang,
          onChanged: (v) => Navigator.pop(c, v),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(s.language, style: Theme.of(c).textTheme.titleLarge),
              ),
              const RadioListTile<String>(value: 'en', title: Text('English')),
              const RadioListTile<String>(value: 'hi', title: Text('हिन्दी (Hindi)')),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
    if (lang != null) await settings.setLang(lang);
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final s = context.s;
    final account = context.read<AccountService>();
    var alsoCloud = account.signedIn;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setLocal) => AlertDialog(
          icon: const Icon(Icons.delete_forever_outlined),
          title: Text(s.deleteMyDataTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.deleteMyDataBody),
              if (account.signedIn)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: alsoCloud,
                  onChanged: (v) => setLocal(() => alsoCloud = v ?? false),
                  title: Text(s.alsoDeleteCloud),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: Text(s.cancel)),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Theme.of(c).colorScheme.error),
              onPressed: () => Navigator.pop(c, true),
              child: Text(s.deleteEverything),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final progress = context.read<ProgressStore>();
    final audio = context.read<AudioDownloadService>();
    final settings = context.read<SettingsController>();
    final usage = context.read<UsageTracker>();
    final music = context.read<MusicPlayer>();
    final musicDownloads = context.read<MusicDownloads>();
    final myMusic = context.read<MyMusicStore>();
    final reminders = context.read<ReminderService?>();
    if (alsoCloud) {
      await account.deleteCloudData();
    } else {
      await account.signOut();
    }
    await progress.clear();
    await audio.deleteAll();
    await music.close();
    await musicDownloads.deleteAll();
    await myMusic.clear();
    await usage.clear();
    await reminders?.clear();
    await settings.reset();
    messenger.showSnackBar(SnackBar(content: Text(s.dataDeleted)));
  }
}

class _RemindersGroup extends StatelessWidget {
  const _RemindersGroup();

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final reminders = context.watch<ReminderService?>();
    if (reminders == null) return const SizedBox.shrink();
    final loc = MaterialLocalizations.of(context);

    Future<void> toggle(bool on, Future<bool> Function(bool) set) async {
      final messenger = ScaffoldMessenger.of(context);
      if (!reminders.available) {
        messenger.showSnackBar(SnackBar(content: Text(s.remindersUnavailable)));
        return;
      }
      final ok = await set(on);
      if (!ok) messenger.showSnackBar(SnackBar(content: Text(s.notificationsBlocked)));
    }

    Future<void> pick(TimeOfDay initial, Future<void> Function(TimeOfDay) set) async {
      final t = await showTimePicker(context: context, initialTime: initial);
      if (t != null) await set(t);
    }

    Widget row({
      required IconData icon,
      required Color color,
      required String title,
      required String sub,
      required bool on,
      required TimeOfDay time,
      required Future<bool> Function(bool) set,
      required Future<void> Function(TimeOfDay) setTime,
    }) {
      return Column(
        children: [
          SwitchListTile(
            secondary: IconBadge(icon, color: color, size: 38),
            title: Text(title),
            subtitle: Text(sub),
            value: on,
            onChanged: (v) => toggle(v, set),
          ),
          if (on)
            ListTile(
              contentPadding: const EdgeInsets.only(left: 70, right: 16),
              title: Text(s.reminderAt(loc.formatTimeOfDay(time))),
              trailing: const Icon(Icons.schedule_rounded),
              onTap: () => pick(time, setTime),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(s.reminders),
        _Group(
          children: [
            row(
              icon: Icons.wb_sunny_outlined,
              color: AppColors.sun,
              title: s.morningReminder,
              sub: s.morningReminderSub,
              on: reminders.morning,
              time: reminders.morningTime,
              set: reminders.setMorning,
              setTime: reminders.setMorningTime,
            ),
            row(
              icon: Icons.bedtime_outlined,
              color: AppColors.lavender,
              title: s.eveningReminder,
              sub: s.eveningReminderSub,
              on: reminders.evening,
              time: reminders.eveningTime,
              set: reminders.setEvening,
              setTime: reminders.setEveningTime,
            ),
          ],
        ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(children: children),
    );
  }
}

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
