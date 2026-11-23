import 'package:flutter/widgets.dart';

/// A piece of bilingual content (English / Hindi).
class LText {
  const LText(this.en, this.hi);

  final String en;
  final String hi;

  String get(String lang) => lang == 'hi' ? hi : en;
}

extension LTextContext on BuildContext {
  String get lang => Localizations.localeOf(this).languageCode;

  /// Resolve bilingual content for the current locale.
  String l(LText text) => text.get(lang);
}
