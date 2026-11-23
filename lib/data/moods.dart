import 'package:flutter/material.dart';

import '../l10n/l_text.dart';
import '../theme/app_colors.dart';

class MoodRecommendation {
  const MoodRecommendation(this.techniqueId, this.why);

  final String techniqueId;
  final LText why;
}

class Mood {
  const Mood({
    required this.id,
    required this.emoji,
    required this.label,
    required this.message,
    required this.color,
    required this.recommendations,
  });

  final String id;
  final String emoji;
  final LText label;
  final LText message;
  final Color color;
  final List<MoodRecommendation> recommendations;
}

/// Mood selections are only used to show suggestions on screen.
/// They are never stored, uploaded, or used for advertising.
const List<Mood> allMoods = [
  Mood(
    id: 'anxious',
    emoji: '😟',
    label: LText('Anxious', 'चिंतित'),
    message: LText(
      'It is okay to feel this way. Slow, steady breathing can help you feel a little more settled.',
      'ऐसा महसूस करना ठीक है। धीमी और स्थिर साँसें आपको थोड़ा अधिक सहज महसूस करा सकती हैं।',
    ),
    color: AppColors.lavender,
    recommendations: [
      MoodRecommendation(
        'slow',
        LText(
          'A gentle, slow rhythm with a longer out-breath and no holds — easy to follow when your mind feels busy.',
          'लंबी साँस छोड़ने वाली कोमल, धीमी लय, बिना रोक के — जब मन व्यस्त हो तब भी अपनाना आसान।',
        ),
      ),
      MoodRecommendation(
        'box',
        LText(
          'Four equal steps give your mind a simple pattern to hold on to. Use Gentle mode if pauses feel uncomfortable.',
          'चार बराबर चरण मन को पकड़ने के लिए एक सरल पैटर्न देते हैं। रुकना असहज लगे तो जेंटल मोड चुनें।',
        ),
      ),
    ],
  ),
  Mood(
    id: 'stressed',
    emoji: '😣',
    label: LText('Stressed', 'तनावग्रस्त'),
    message: LText(
      'Let’s take a few minutes just for you. Breathing deeply can help your body loosen up.',
      'चलिए कुछ मिनट सिर्फ़ अपने लिए निकालें। गहरी साँसें शरीर को ढीला करने में मदद कर सकती हैं।',
    ),
    color: AppColors.blush,
    recommendations: [
      MoodRecommendation(
        'belly',
        LText(
          'Breathing low into your belly encourages fuller, more relaxed breaths and helps release tight shoulders.',
          'पेट तक साँस लेने से पूरी और आरामदायक साँसें आती हैं और कंधों का खिंचाव कम होता है।',
        ),
      ),
      MoodRecommendation(
        'relax',
        LText(
          'Pairs a long out-breath with relaxing one part of your body at a time.',
          'लंबी साँस छोड़ने के साथ शरीर के एक-एक हिस्से को ढीला करना सिखाता है।',
        ),
      ),
    ],
  ),
  Mood(
    id: 'sad',
    emoji: '😔',
    label: LText('Sad', 'उदास'),
    message: LText(
      'Be kind to yourself today. A soft, flowing breath can offer a quiet moment of comfort.',
      'आज अपने प्रति दयालु रहें। कोमल, प्रवाहमय साँस सुकून का एक शांत पल दे सकती है।',
    ),
    color: AppColors.sky,
    recommendations: [
      MoodRecommendation(
        'resonant',
        LText(
          'A smooth, wave-like rhythm that many people find soothing and grounding.',
          'लहर जैसी सहज लय, जिसे बहुत से लोग सुकून देने वाला और स्थिर करने वाला पाते हैं।',
        ),
      ),
      MoodRecommendation(
        'belly',
        LText(
          'Placing a hand on your belly and breathing slowly can feel warm and reassuring.',
          'पेट पर हाथ रखकर धीरे साँस लेना गर्माहट और भरोसे का एहसास दे सकता है।',
        ),
      ),
    ],
  ),
  Mood(
    id: 'angry',
    emoji: '😠',
    label: LText('Angry', 'गुस्से में'),
    message: LText(
      'Strong feelings are natural. Slowing your breath can give you space before you respond.',
      'तीव्र भावनाएँ स्वाभाविक हैं। साँस धीमी करने से प्रतिक्रिया देने से पहले आपको थोड़ा समय मिलता है।',
    ),
    color: AppColors.blush,
    recommendations: [
      MoodRecommendation(
        'slow',
        LText(
          'Fewer, slower breaths help you pause and cool down before reacting.',
          'कम और धीमी साँसें प्रतिक्रिया से पहले ठहरने और शांत होने में मदद करती हैं।',
        ),
      ),
      MoodRecommendation(
        'equal',
        LText(
          'Matching your in- and out-breath creates a feeling of balance and control.',
          'साँस लेने और छोड़ने को बराबर रखने से संतुलन और नियंत्रण का एहसास होता है।',
        ),
      ),
    ],
  ),
  Mood(
    id: 'tired',
    emoji: '😴',
    label: LText('Tired', 'थका हुआ'),
    message: LText(
      'Low on energy? Keep it light. A few easy breaths can help you feel a bit more present.',
      'ऊर्जा कम है? हल्का रखें। कुछ आसान साँसें आपको थोड़ा अधिक सजग महसूस करा सकती हैं।',
    ),
    color: AppColors.sun,
    recommendations: [
      MoodRecommendation(
        'beginner',
        LText(
          'A gentle, short rhythm that asks very little of you — perfect when you are tired.',
          'एक कोमल और छोटी लय, जो आपसे बहुत कम माँगती है — थकान में बिलकुल सही।',
        ),
      ),
      MoodRecommendation(
        'equal',
        LText(
          'An even, steady rhythm that can leave you feeling a little more balanced.',
          'एक समान, स्थिर लय जो आपको थोड़ा अधिक संतुलित महसूस करा सकती है।',
        ),
      ),
    ],
  ),
  Mood(
    id: 'unfocused',
    emoji: '😵‍💫',
    label: LText('Unfocused', 'ध्यान भटका'),
    message: LText(
      'Let’s gather your attention gently. A clear rhythm gives your mind one simple thing to do.',
      'चलिए ध्यान को धीरे से समेटें। एक स्पष्ट लय मन को करने के लिए एक सरल काम देती है।',
    ),
    color: AppColors.mint,
    recommendations: [
      MoodRecommendation(
        'focus',
        LText(
          'A crisp rhythm designed as a short reset before studying or working.',
          'पढ़ाई या काम से पहले छोटे रीसेट के लिए बनी स्पष्ट लय।',
        ),
      ),
      MoodRecommendation(
        'equal',
        LText(
          'Counting equal breaths is a simple way to bring wandering attention back.',
          'बराबर साँसें गिनना भटकते ध्यान को वापस लाने का सरल तरीका है।',
        ),
      ),
    ],
  ),
  Mood(
    id: 'calm',
    emoji: '😌',
    label: LText('Calm', 'शांत'),
    message: LText(
      'Lovely! A short practice can help you enjoy and extend this peaceful feeling.',
      'बहुत बढ़िया! एक छोटा अभ्यास इस शांति को और गहरा कर सकता है।',
    ),
    color: AppColors.mintDeep,
    recommendations: [
      MoodRecommendation(
        'resonant',
        LText(
          'A flowing rhythm to stay in this calm, steady state a little longer.',
          'इस शांत, स्थिर अवस्था में थोड़ा और रहने के लिए प्रवाहमय लय।',
        ),
      ),
      MoodRecommendation(
        'equal',
        LText(
          'A balanced practice that fits nicely into a calm moment.',
          'शांत पल में सहजता से फ़िट होने वाला संतुलित अभ्यास।',
        ),
      ),
    ],
  ),
  Mood(
    id: 'happy',
    emoji: '😊',
    label: LText('Happy', 'खुश'),
    message: LText(
      'Wonderful! Take a mindful moment to notice and appreciate how you feel.',
      'शानदार! अपने इस एहसास को महसूस करने और सराहने के लिए एक सजग पल लें।',
    ),
    color: AppColors.sun,
    recommendations: [
      MoodRecommendation(
        'resonant',
        LText('Smooth breathing that lets you savour a good moment.', 'सहज श्वास जो अच्छे पल का आनंद लेने देती है।'),
      ),
      MoodRecommendation(
        'box',
        LText(
          'A steady, structured rhythm to build your daily breathing habit.',
          'रोज़ की श्वास आदत बनाने के लिए एक स्थिर, व्यवस्थित लय।',
        ),
      ),
    ],
  ),
];
