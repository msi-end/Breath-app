import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../theme/app_colors.dart';
import 'account_form.dart';
import 'common.dart';

/// Friendly, optional invitation shown after ~10 days of use.
Future<void> showAccountInviteDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (c) {
      final s = c.s;
      final theme = Theme.of(c);
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: IconBadge(Icons.cloud_done_outlined, color: AppColors.mint, size: 64)),
              const SizedBox(height: 14),
              Text(s.inviteTitle, textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                s.inviteBody,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: c.softText),
              ),
              const SizedBox(height: 18),
              AccountForm(onSuccess: () => Navigator.of(c).pop()),
              const SizedBox(height: 4),
              TextButton(onPressed: () => Navigator.of(c).pop(), child: Text(s.maybeLater)),
            ],
          ),
        ),
      );
    },
  );
}
