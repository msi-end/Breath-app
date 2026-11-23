import 'package:flutter/material.dart';

import '../l10n/l_text.dart';
import '../models/music.dart';
import '../theme/app_colors.dart';

/// Music categories. Tracks reference these by `id` in catalog.json.
const List<MusicCategory> musicCategories = [
  MusicCategory(
    id: 'relaxation',
    name: LText('Relaxation', 'विश्राम'),
    description: LText('Soft, slow music to help you unwind.', 'आराम के लिए कोमल, धीमा संगीत।'),
    icon: Icons.spa_rounded,
    colors: [AppColors.mint, AppColors.sage],
  ),
  MusicCategory(
    id: 'meditation',
    name: LText('Meditation', 'ध्यान'),
    description: LText('Spacious tones for quiet sitting practice.', 'शांत बैठकर ध्यान के लिए विस्तृत स्वर।'),
    icon: Icons.self_improvement_rounded,
    colors: [AppColors.lavender, Color(0xFF8E86C2)],
  ),
  MusicCategory(
    id: 'guided',
    name: LText('Guided Meditation', 'निर्देशित ध्यान'),
    description: LText('Gentle spoken guidance with soft music.', 'कोमल संगीत के साथ बोलकर दिया गया मार्गदर्शन।'),
    icon: Icons.record_voice_over_rounded,
    colors: [AppColors.sky, Color(0xFF7AA6C9)],
  ),
  MusicCategory(
    id: 'piano',
    name: LText('Calm Piano', 'शांत पियानो'),
    description: LText('Quiet piano pieces for calm moments.', 'शांत पलों के लिए धीमे पियानो संगीत।'),
    icon: Icons.piano_rounded,
    colors: [AppColors.creamDeep, Color(0xFFC9B79A)],
  ),
  MusicCategory(
    id: 'instrumental',
    name: LText('Instrumental', 'वाद्य संगीत'),
    description: LText('Guitar, strings and gentle melodies.', 'गिटार, तार वाद्य और कोमल धुनें।'),
    icon: Icons.music_note_rounded,
    colors: [AppColors.sun, Color(0xFFD9B26A)],
  ),
  MusicCategory(
    id: 'flute',
    name: LText('Bansuri & Flute', 'बाँसुरी'),
    description: LText('Breathy flute melodies, including Indian bansuri.', 'भारतीय बाँसुरी सहित मधुर धुनें।'),
    icon: Icons.air_rounded,
    colors: [AppColors.mintDeep, Color(0xFF5E9C80)],
  ),
  MusicCategory(
    id: 'indian',
    name: LText('Indian Classical Calm', 'शांत भारतीय शास्त्रीय'),
    description: LText('Slow, meditative raag-inspired music.', 'धीमा, ध्यानमय राग-प्रेरित संगीत।'),
    icon: Icons.brightness_5_rounded,
    colors: [AppColors.blush, Color(0xFFD69A84)],
  ),
  MusicCategory(
    id: 'bowls',
    name: LText('Singing Bowls', 'सिंगिंग बाउल'),
    description: LText('Resonant bowls and bells for stillness.', 'स्थिरता के लिए गूँजते बाउल और घंटियाँ।'),
    icon: Icons.radio_button_checked_rounded,
    colors: [Color(0xFFE6D3B3), Color(0xFFB89B6E)],
  ),
  MusicCategory(
    id: 'stress',
    name: LText('Stress Relief', 'तनाव से राहत'),
    description: LText('Warm, steady music to soften a tense day.', 'तनाव भरे दिन को हल्का करने वाला संगीत।'),
    icon: Icons.favorite_rounded,
    colors: [AppColors.blush, AppColors.lavender],
  ),
  MusicCategory(
    id: 'focus',
    name: LText('Focus', 'एकाग्रता'),
    description: LText('Unobtrusive music for study and work.', 'पढ़ाई और काम के लिए सहज संगीत।'),
    icon: Icons.center_focus_strong_rounded,
    colors: [AppColors.sky, AppColors.mintDeep],
  ),
  MusicCategory(
    id: 'ambient',
    name: LText('Peaceful Ambient', 'शांत एम्बिएंट'),
    description: LText('Slow-moving soundscapes with soft synth pads.', 'धीरे बदलते, कोमल ध्वनि-परिदृश्य।'),
    icon: Icons.blur_on_rounded,
    colors: [Color(0xFF9CC7C9), Color(0xFF6E9AA8)],
  ),
  MusicCategory(
    id: 'yoga',
    name: LText('Yoga', 'योग'),
    description: LText('Flowing music for stretching and yoga practice.', 'स्ट्रेचिंग और योग के लिए प्रवाहमय संगीत।'),
    icon: Icons.accessibility_new_rounded,
    colors: [AppColors.sage, AppColors.forestSoft],
  ),
  MusicCategory(
    id: 'mindfulness',
    name: LText('Mindfulness', 'सजगता'),
    description: LText('Simple, gentle music to stay present.', 'वर्तमान में रहने के लिए सरल संगीत।'),
    icon: Icons.eco_rounded,
    colors: [AppColors.mint, AppColors.sky],
  ),
  MusicCategory(
    id: 'morning',
    name: LText('Gentle Morning', 'सौम्य सुबह'),
    description: LText('Light, hopeful music to start the day calmly.', 'दिन की शांत शुरुआत के लिए हल्का संगीत।'),
    icon: Icons.wb_twilight_rounded,
    colors: [AppColors.sun, AppColors.blush],
  ),
  MusicCategory(
    id: 'short',
    name: LText('Short Relaxation', 'छोटे विश्राम ट्रैक'),
    description: LText('Quick resets of five minutes or less.', 'पाँच मिनट या उससे कम के छोटे ट्रैक।'),
    icon: Icons.timer_rounded,
    colors: [AppColors.mintDeep, AppColors.sky],
  ),
];

MusicCategory? musicCategoryById(String id) {
  for (final c in musicCategories) {
    if (c.id == id) return c;
  }
  return null;
}
