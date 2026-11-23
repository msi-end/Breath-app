import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/strings.dart';
import '../services/account_service.dart';
import '../theme/app_colors.dart';

/// User ID + PIN form with Login and Create Account.
class AccountForm extends StatefulWidget {
  const AccountForm({super.key, this.onSuccess});

  final VoidCallback? onSuccess;

  @override
  State<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  final _id = TextEditingController();
  final _pin = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _id.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool create}) async {
    final account = context.read<AccountService>();
    final s = context.s;
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    final result = create
        ? await account.createAccount(_id.text, _pin.text)
        : await account.signIn(_id.text, _pin.text);
    if (!mounted) return;
    if (result == AccountResult.ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(create ? s.accountCreated : s.signedIn)));
      widget.onSuccess?.call();
    } else {
      setState(() => _error = s.accountError(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final busy = context.watch<AccountService>().busy;
    final theme = Theme.of(context);
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _id,
            enabled: !busy,
            autofillHints: const [AutofillHints.username],
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
              LengthLimitingTextInputFormatter(20),
            ],
            decoration: InputDecoration(
              labelText: s.userId,
              helperText: s.userIdHelp,
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pin,
            enabled: !busy,
            obscureText: _obscure,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.password],
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
            onSubmitted: (_) => _submit(create: false),
            decoration: InputDecoration(
              labelText: s.pin,
              helperText: s.pinHelp,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: _obscure ? s.showPin : s.hidePin,
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 16),
          if (busy)
            const Center(
              child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()),
            )
          else ...[
            FilledButton(onPressed: () => _submit(create: false), child: Text(s.login)),
            const SizedBox(height: 10),
            OutlinedButton(onPressed: () => _submit(create: true), child: Text(s.createAccount)),
          ],
          const SizedBox(height: 10),
          Text(
            s.pinWarning,
            style: theme.textTheme.bodySmall?.copyWith(color: context.softText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
