import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/strings.dart';
import '../services/account_service.dart';
import '../services/ads_service.dart';
import '../services/audio_download_service.dart';
import '../services/progress_store.dart';
import '../services/settings_controller.dart';
import '../services/usage_tracker.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/nature_background.dart';
import 'account_screen.dart';
import 'audio_library_screen.dart';
import 'info_screen.dart';

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
              ],
            ),
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
    if (alsoCloud) {
      await account.deleteCloudData();
    } else {
      await account.signOut();
    }
    await progress.clear();
    await audio.deleteAll();
    await usage.clear();
    await settings.reset();
    messenger.showSnackBar(SnackBar(content: Text(s.dataDeleted)));
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
