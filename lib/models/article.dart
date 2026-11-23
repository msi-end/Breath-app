import 'package:flutter/material.dart';

import '../l10n/l_text.dart';

class ArticleSection {
  const ArticleSection({this.heading, required this.body, this.bullets = const []});

  final LText? heading;
  final LText body;
  final List<LText> bullets;
}

class Article {
  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.readMinutes,
    required this.icon,
    required this.color,
    required this.sections,
  });

  final String id;
  final LText title;
  final LText summary;
  final int readMinutes;
  final IconData icon;
  final Color color;
  final List<ArticleSection> sections;
}
