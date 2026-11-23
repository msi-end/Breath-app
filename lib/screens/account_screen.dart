import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/strings.dart';
import '../services/account_service.dart';
import '../services/progress_store.dart';
import '../theme/app_colors.dart';
import '../widgets/account_form.dart';
import '../widgets/common.dart';
import '../widgets/nature_background.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final account = context.watch<AccountService>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.accountAndBackup)),
      body: NatureBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            SoftCard(
              child: Row(
                children: [
                  const IconBadge(Icons.cloud_sync_outlined, color: AppColors.sky),
                  const SizedBox(width: 14),
                  Expanded(child: Text(s.accountIntro, style: theme.textTheme.bodyMedium)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (!account.available)
              SoftCard(
                color: context.isDark ? const Color(0xFF26323A) : const Color(0xFFE8F3FA),
                child: Text(s.cloudNotConfigured, style: theme.textTheme.bodyMedium),
              )
            else if (!account.signedIn)
              const SoftCard(child: AccountForm())
            else
              _SignedInPanel(account: account),
          ],
        ),
      ),
    );
  }
}

class _SignedInPanel extends StatelessWidget {
  const _SignedInPanel({required this.account});

  final AccountService account;

  Future<void> _run(BuildContext context, Future<AccountResult> Function() action, String okMsg) async {
    final s = context.s;
    final messenger = ScaffoldMessenger.of(context);
    final r = await action();
    messenger.showSnackBar(SnackBar(content: Text(r == AccountResult.ok ? okMsg : s.accountError(r))));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final store = context.read<ProgressStore>();
    final last = account.lastBackup;
    final loc = MaterialLocalizations.of(context);
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.mint,
                child: Text(
                  (account.userId ?? '?').substring(0, 1).toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(color: AppColors.forest),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.userId ?? '', style: theme.textTheme.titleLarge),
                    Text(
                      last == null
                          ? s.neverBackedUp
                          : s.lastBackup(
                              '${loc.formatMediumDate(last)} ${loc.formatTimeOfDay(TimeOfDay.fromDateTime(last))}',
                            ),
                      style: theme.textTheme.bodySmall?.copyWith(color: context.softText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (account.busy)
            const Center(
              child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()),
            )
          else ...[
            FilledButton.icon(
              onPressed: () => _run(context, () => account.backup(store), s.backupDone),
              icon: const Icon(Icons.cloud_upload_outlined),
              label: Text(s.backupNow),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: Text(s.restoreTitle),
                    content: Text(s.restoreBody),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(c, false), child: Text(s.cancel)),
                      FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(s.restore)),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  await _run(context, () => account.restore(store), s.restoreDone);
                }
              },
              icon: const Icon(Icons.cloud_download_outlined),
              label: Text(s.restore),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => account.signOut(),
              icon: const Icon(Icons.logout_rounded),
              label: Text(s.logout),
            ),
          ],
        ],
      ),
    );
  }
}
