import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/techniques.dart';
import '../l10n/l_text.dart';
import '../l10n/strings.dart';
import '../services/audio_download_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/nature_background.dart';
import 'navigation.dart';
import 'settings_screen.dart' show formatBytes;

/// Manage downloaded guidance audio (download, retry, delete).
class AudioLibraryScreen extends StatelessWidget {
  const AudioLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final audio = context.watch<AudioDownloadService>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.downloadedAudio)),
      body: NatureBackground(
        showHills: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            SoftCard(
              child: Row(
                children: [
                  const IconBadge(Icons.sd_storage_outlined, color: AppColors.sky),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.storageUsed(formatBytes(audio.totalBytes)), style: theme.textTheme.titleMedium),
                        Text(s.audioOfflineNote, style: theme.textTheme.bodySmall?.copyWith(color: context.softText)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!audio.cloudAvailable) ...[
              const SizedBox(height: 12),
              SoftCard(
                color: context.isDark ? const Color(0xFF26323A) : const Color(0xFFE8F3FA),
                child: Text(s.cloudNotConfigured, style: theme.textTheme.bodyMedium),
              ),
            ],
            const SizedBox(height: 16),
            for (final t in allTechniques) ...[
              Builder(
                builder: (context) {
                  final st = audio.stateOf(t.id);
                  Widget trailing;
                  String subtitle;
                  switch (st.status) {
                    case AudioStatus.downloaded:
                      subtitle = '${s.downloaded} · ${formatBytes(st.bytes)}';
                      trailing = IconButton(
                        tooltip: s.deleteDownload,
                        onPressed: () => audio.delete(t.id),
                        icon: const Icon(Icons.delete_outline_rounded),
                      );
                    case AudioStatus.downloading:
                      subtitle = s.downloadingPercent((st.progress * 100).round());
                      trailing = IconButton(
                        tooltip: s.cancel,
                        onPressed: () => audio.cancel(t.id),
                        icon: const Icon(Icons.close_rounded),
                      );
                    case AudioStatus.failed:
                      subtitle = s.audioError(st.error);
                      trailing = IconButton(
                        tooltip: s.retry,
                        onPressed: () => audio.download(t),
                        icon: const Icon(Icons.refresh_rounded),
                      );
                    case AudioStatus.notDownloaded:
                      subtitle = s.notDownloaded;
                      trailing = IconButton(
                        tooltip: s.downloadAudio,
                        onPressed: () => audio.download(t),
                        icon: const Icon(Icons.download_rounded),
                      );
                  }
                  return SoftCard(
                    padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
                    onTap: () => openTechnique(context, t),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconBadge(t.icon, color: t.color, size: 42),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(context.l(t.name), style: theme.textTheme.titleSmall),
                                  Text(
                                    subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: st.status == AudioStatus.failed
                                          ? theme.colorScheme.error
                                          : context.softText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing,
                          ],
                        ),
                        if (st.status == AudioStatus.downloading)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 8, 2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: st.progress == 0 ? null : st.progress,
                                minHeight: 6,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
            if (audio.downloadedIds.isNotEmpty) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: Text(s.deleteAllDownloads),
                      content: Text(s.deleteAllDownloadsBody),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(s.cancel)),
                        FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(s.delete)),
                      ],
                    ),
                  );
                  if (ok == true) await audio.deleteAll();
                },
                icon: const Icon(Icons.delete_sweep_outlined),
                label: Text(s.deleteAllDownloads),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
