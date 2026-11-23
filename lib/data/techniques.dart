import 'package:flutter/material.dart';

import '../l10n/l_text.dart';
import '../models/breath_pattern.dart';
import '../models/technique.dart';
import '../theme/app_colors.dart';

const _in = PhaseType.inhale;
const _holdIn = PhaseType.holdIn;
const _out = PhaseType.exhale;
const _holdOut = PhaseType.holdOut;

const _holdCaution = LText(
  'Holding is always optional. If a hold feels uncomfortable, turn on Gentle mode or simply keep breathing naturally.',
  'साँस रोकना हमेशा वैकल्पिक है। अगर रोकना असहज लगे, तो जेंटल मोड चालू करें या बस स्वाभाविक रूप से साँस लेते रहें।',
);

const List<Technique> allTechniques = [
  Technique(
    id: 'beginner',
    name: LText('Beginner Breathing', 'शुरुआती श्वास'),
    tagline: LText('A soft first step into mindful breathing', 'सजग श्वास की ओर पहला कोमल कदम'),
    description: LText(
      'A short, easy rhythm designed for anyone trying breathing exercises for the first time. You simply breathe in and out a little more slowly than usual, with no holds and no pressure.',
      'यह एक छोटी और आसान लय है, उन सभी के लिए जो पहली बार श्वास अभ्यास कर रहे हैं। आप बस सामान्य से थोड़ा धीरे साँस लेते और छोड़ते हैं — बिना रोके और बिना किसी दबाव के।',
    ),
    purpose: LText(
      'Helps you get comfortable with paying attention to your breath.',
      'अपनी साँस पर ध्यान देने की आदत को सहज बनाने में मदद करता है।',
    ),
    benefits: [
      LText('Easy to learn in under a minute', 'एक मिनट से भी कम में सीखना आसान'),
      LText('Builds a calm, steady rhythm', 'शांत और स्थिर लय बनाता है'),
      LText('A gentle way to pause during a busy day', 'व्यस्त दिन में ठहरने का कोमल तरीका'),
    ],
    steps: [
      LText(
        'Sit or lie down comfortably and relax your shoulders.',
        'आराम से बैठें या लेटें और कंधों को ढीला छोड़ दें।',
      ),
      LText('Breathe in gently through your nose for 3 seconds.', 'नाक से 3 सेकंड तक धीरे से साँस लें।'),
      LText('Breathe out softly for 3 seconds.', '3 सेकंड तक धीरे से साँस छोड़ें।'),
      LText('Keep the breath light and easy. Never force it.', 'साँस को हल्का और सहज रखें। कभी ज़ोर न लगाएँ।'),
    ],
    pattern: BreathPattern([BreathPhase(_in, 3), BreathPhase(_out, 3)]),
    recommendedMinutes: 2,
    icon: Icons.spa_outlined,
    color: AppColors.mintDeep,
    tags: {TechniqueTag.beginner, TechniqueTag.calm},
  ),
  Technique(
    id: 'box',
    name: LText('Box Breathing', 'बॉक्स श्वास'),
    tagline: LText('Four equal sides for a steady mind', 'स्थिर मन के लिए चार बराबर हिस्से'),
    description: LText(
      'Box breathing follows four equal steps: breathe in, pause, breathe out, pause. The simple, even structure gives your mind something steady to follow.',
      'बॉक्स श्वास चार बराबर चरणों में होती है: साँस लें, रुकें, साँस छोड़ें, रुकें। यह सरल और संतुलित ढाँचा मन को एक स्थिर सहारा देता है।',
    ),
    purpose: LText(
      'Useful for steadying yourself before a meeting, exam, or any moment that needs a clear head.',
      'मीटिंग, परीक्षा या किसी भी ऐसे पल से पहले, जहाँ साफ़ सोच चाहिए, खुद को स्थिर करने के लिए उपयोगी।',
    ),
    benefits: [
      LText('Encourages a calm, even rhythm', 'शांत और समान लय को बढ़ावा देता है'),
      LText('Helps you refocus your attention', 'ध्यान को फिर से केंद्रित करने में मदद करता है'),
      LText('Easy to remember and practice anywhere', 'याद रखना आसान, कहीं भी अभ्यास करें'),
    ],
    steps: [
      LText('Sit upright and relax your hands in your lap.', 'सीधे बैठें और हाथों को गोद में ढीला रखें।'),
      LText('Breathe in through your nose for 4 seconds.', 'नाक से 4 सेकंड तक साँस लें।'),
      LText('Gently pause for 4 seconds, only if comfortable.', 'सहज लगे तो ही 4 सेकंड के लिए हल्के से रुकें।'),
      LText('Breathe out slowly for 4 seconds.', '4 सेकंड तक धीरे-धीरे साँस छोड़ें।'),
      LText('Pause again for 4 seconds, then repeat.', 'फिर 4 सेकंड रुकें और दोहराएँ।'),
    ],
    pattern: BreathPattern([
      BreathPhase(_in, 4),
      BreathPhase(_holdIn, 4),
      BreathPhase(_out, 4),
      BreathPhase(_holdOut, 4),
    ]),
    recommendedMinutes: 4,
    icon: Icons.crop_square_rounded,
    color: AppColors.sky,
    tags: {TechniqueTag.focus, TechniqueTag.calm},
    caution: _holdCaution,
  ),
  Technique(
    id: '478',
    name: LText('4-7-8 Breathing', '4-7-8 श्वास'),
    tagline: LText('A long, soothing out-breath', 'लंबी, सुकून भरी साँस छोड़ना'),
    description: LText(
      'In 4-7-8 breathing you breathe in for 4 seconds, rest for 7, and breathe out slowly for 8. The long exhale is what makes this rhythm feel so relaxing.',
      '4-7-8 श्वास में आप 4 सेकंड साँस लेते हैं, 7 सेकंड रुकते हैं और 8 सेकंड धीरे-धीरे साँस छोड़ते हैं। लंबी साँस छोड़ना ही इस लय को इतना आरामदायक बनाता है।',
    ),
    purpose: LText(
      'A wind-down rhythm for moments when you want to relax and let go of tension.',
      'उन पलों के लिए, जब आप आराम करना और तनाव छोड़ना चाहते हैं।',
    ),
    benefits: [
      LText('Supports a feeling of relaxation', 'विश्राम की अनुभूति में सहायक'),
      LText('Slows down your breathing pace', 'साँस की गति को धीमा करता है'),
      LText('Gives racing thoughts a gentle anchor', 'भागते विचारों को एक कोमल सहारा देता है'),
    ],
    steps: [
      LText(
        'Rest the tip of your tongue behind your upper front teeth.',
        'जीभ की नोक को ऊपर के सामने वाले दाँतों के पीछे टिकाएँ।',
      ),
      LText('Breathe in quietly through your nose for 4 seconds.', 'नाक से 4 सेकंड तक शांति से साँस लें।'),
      LText('Rest for up to 7 seconds, only if comfortable.', 'सहज लगे तो 7 सेकंड तक रुकें।'),
      LText('Breathe out through your mouth for 8 seconds.', 'मुँह से 8 सेकंड तक साँस छोड़ें।'),
      LText('Beginners should start with just 3–4 rounds.', 'शुरुआत में केवल 3–4 चक्र ही करें।'),
    ],
    pattern: BreathPattern([BreathPhase(_in, 4), BreathPhase(_holdIn, 7), BreathPhase(_out, 8)]),
    recommendedMinutes: 2,
    icon: Icons.nightlight_outlined,
    color: AppColors.lavender,
    tags: {TechniqueTag.relax},
    caution: LText(
      'If you feel light-headed, stop and breathe normally. Holding is optional — Gentle mode removes it.',
      'अगर चक्कर जैसा लगे, तो रुकें और सामान्य रूप से साँस लें। रोकना वैकल्पिक है — जेंटल मोड इसे हटा देता है।',
    ),
  ),
  Technique(
    id: 'belly',
    name: LText('Deep Belly Breathing', 'गहरी पेट श्वास'),
    tagline: LText('Breathe low and slow into your belly', 'पेट तक धीमी और गहरी साँस'),
    description: LText(
      'Also called diaphragmatic breathing. Instead of breathing high in the chest, you let your belly rise as you breathe in and fall as you breathe out.',
      'इसे डायाफ्रामिक श्वास भी कहते हैं। छाती से ऊपर-ऊपर साँस लेने के बजाय, साँस लेते समय पेट को ऊपर उठने दें और छोड़ते समय नीचे आने दें।',
    ),
    purpose: LText(
      'A comforting way to unwind when you feel tense or stressed.',
      'जब आप तनाव या खिंचाव महसूस करें, तब आराम पाने का सुखद तरीका।',
    ),
    benefits: [
      LText('Encourages fuller, more relaxed breaths', 'पूरी और अधिक आरामदायक साँसों को बढ़ावा'),
      LText('Helps release tension in the shoulders', 'कंधों का तनाव कम करने में मदद'),
      LText('A great everyday stress-relief habit', 'रोज़ाना तनाव कम करने की बढ़िया आदत'),
    ],
    steps: [
      LText('Place one hand on your chest and one on your belly.', 'एक हाथ छाती पर और एक पेट पर रखें।'),
      LText(
        'Breathe in through your nose for 4 seconds, letting your belly rise.',
        'नाक से 4 सेकंड साँस लें और पेट को ऊपर उठने दें।',
      ),
      LText('Keep the hand on your chest fairly still.', 'छाती वाले हाथ को लगभग स्थिर रखें।'),
      LText(
        'Breathe out for 6 seconds and feel your belly soften.',
        '6 सेकंड तक साँस छोड़ें और पेट को ढीला होते महसूस करें।',
      ),
    ],
    pattern: BreathPattern([BreathPhase(_in, 4), BreathPhase(_out, 6)]),
    recommendedMinutes: 5,
    icon: Icons.self_improvement,
    color: AppColors.sage,
    tags: {TechniqueTag.relax, TechniqueTag.beginner},
  ),
  Technique(
    id: 'pursed',
    name: LText('Pursed-Lip Breathing', 'होंठ सिकोड़कर श्वास'),
    tagline: LText('Slow the out-breath through soft lips', 'कोमल होंठों से साँस को धीमे छोड़ें'),
    description: LText(
      'You breathe in through your nose and breathe out slowly through gently pursed lips, as if softly blowing on a candle flame without putting it out.',
      'नाक से साँस लें और हल्के सिकोड़े हुए होंठों से धीरे-धीरे छोड़ें — जैसे मोमबत्ती की लौ पर बिना बुझाए हल्के से फूँक रहे हों।',
    ),
    purpose: LText(
      'Helps you slow your breathing down when it feels quick or shallow during daily activities.',
      'रोज़मर्रा के कामों में जब साँस तेज़ या उथली लगे, तब उसे धीमा करने में मदद करता है।',
    ),
    benefits: [
      LText('Naturally lengthens each exhale', 'हर साँस छोड़ने को स्वाभाविक रूप से लंबा करता है'),
      LText('Easy to use while walking or resting', 'चलते या आराम करते समय करना आसान'),
      LText('Encourages a slower, controlled pace', 'धीमी और नियंत्रित गति को बढ़ावा'),
    ],
    steps: [
      LText('Relax your neck and shoulders.', 'गर्दन और कंधों को ढीला छोड़ें।'),
      LText('Breathe in through your nose for 2 seconds.', 'नाक से 2 सेकंड साँस लें।'),
      LText('Purse your lips as if about to whistle.', 'होंठों को ऐसे सिकोड़ें जैसे सीटी बजाने वाले हों।'),
      LText('Breathe out gently through your lips for 4 seconds.', 'होंठों से 4 सेकंड तक धीरे से साँस छोड़ें।'),
    ],
    pattern: BreathPattern([BreathPhase(_in, 2), BreathPhase(_out, 4)]),
    recommendedMinutes: 3,
    icon: Icons.air,
    color: AppColors.skyDeep,
    tags: {TechniqueTag.calm, TechniqueTag.beginner},
  ),
  Technique(
    id: 'equal',
    name: LText('Equal Breathing', 'समान श्वास'),
    tagline: LText('Matching in-breath and out-breath', 'साँस लेना और छोड़ना बराबर'),
    description: LText(
      'Known in yoga as Sama Vritti, equal breathing simply matches the length of every inhale and exhale, creating a balanced, even rhythm.',
      'योग में इसे समवृत्ति कहा जाता है। इसमें हर साँस लेने और छोड़ने की अवधि बराबर रखी जाती है, जिससे संतुलित लय बनती है।',
    ),
    purpose: LText(
      'A balancing practice to help you feel centred and even-tempered.',
      'संतुलित और केंद्रित महसूस करने में मदद करने वाला अभ्यास।',
    ),
    benefits: [
      LText('Creates a sense of balance', 'संतुलन की अनुभूति देता है'),
      LText('Helps cool down strong emotions', 'तीव्र भावनाओं को शांत करने में सहायक'),
      LText('Supports steady focus', 'स्थिर ध्यान में सहायक'),
    ],
    steps: [
      LText('Sit comfortably with a long, relaxed spine.', 'रीढ़ को सीधा और ढीला रखते हुए आराम से बैठें।'),
      LText('Breathe in through your nose for 4 seconds.', 'नाक से 4 सेकंड साँस लें।'),
      LText('Breathe out through your nose for 4 seconds.', 'नाक से 4 सेकंड साँस छोड़ें।'),
      LText('Keep the two halves smooth and equal.', 'दोनों हिस्सों को सहज और बराबर रखें।'),
    ],
    pattern: BreathPattern([BreathPhase(_in, 4), BreathPhase(_out, 4)]),
    recommendedMinutes: 3,
    icon: Icons.balance,
    color: AppColors.mint,
    tags: {TechniqueTag.balance, TechniqueTag.focus, TechniqueTag.beginner},
  ),
  Technique(
    id: 'slow',
    name: LText('Slow Breathing', 'धीमी श्वास'),
    tagline: LText('Gently slow your pace, breath by breath', 'हर साँस के साथ गति को धीमा करें'),
    description: LText(
      'Slow breathing invites you to take fewer, softer breaths each minute, with a slightly longer out-breath. It is gentle and suitable for almost everyone.',
      'धीमी श्वास में आप हर मिनट कम और कोमल साँसें लेते हैं, जिसमें साँस छोड़ना थोड़ा लंबा होता है। यह कोमल है और लगभग सभी के लिए उपयुक्त है।',
    ),
    purpose: LText(
      'For moments when you feel worked up and want to settle down.',
      'उन पलों के लिए जब आप बेचैन हों और शांत होना चाहें।',
    ),
    benefits: [
      LText('Encourages a calmer breathing pace', 'शांत श्वास गति को बढ़ावा'),
      LText('No breath-holding needed', 'साँस रोकने की ज़रूरत नहीं'),
      LText('Comforting during uneasy moments', 'बेचैनी के पलों में सुकून देता है'),
    ],
    steps: [
      LText('Let your body settle and soften your jaw.', 'शरीर को स्थिर होने दें और जबड़े को ढीला करें।'),
      LText('Breathe in gently for 5 seconds.', '5 सेकंड तक धीरे से साँस लें।'),
      LText('Breathe out slowly for 7 seconds.', '7 सेकंड तक धीरे-धीरे साँस छोड़ें।'),
      LText(
        'If it feels too long, shorten the counts — comfort comes first.',
        'अगर लंबा लगे तो गिनती कम करें — सहजता सबसे पहले।',
      ),
    ],
    pattern: BreathPattern([BreathPhase(_in, 5), BreathPhase(_out, 7)]),
    recommendedMinutes: 5,
    icon: Icons.water_drop_outlined,
    color: AppColors.sky,
    tags: {TechniqueTag.calm, TechniqueTag.relax},
  ),
  Technique(
    id: 'resonant',
    name: LText('Resonant Breathing', 'अनुनाद श्वास'),
    tagline: LText('About six smooth breaths a minute', 'लगभग छह सहज साँसें प्रति मिनट'),
    description: LText(
      'Also known as coherent breathing, resonant breathing settles into a smooth rhythm of about six breaths per minute — five seconds in, five seconds out.',
      'इसे कोहेरेंट श्वास भी कहते हैं। इसमें लगभग छह साँसें प्रति मिनट की सहज लय बनती है — पाँच सेकंड साँस लेना, पाँच सेकंड छोड़ना।',
    ),
    purpose: LText(
      'A flowing practice to help you feel balanced and at ease.',
      'संतुलित और सहज महसूस करने के लिए एक प्रवाहमय अभ्यास।',
    ),
    benefits: [
      LText('Smooth, wave-like rhythm', 'लहर जैसी सहज लय'),
      LText('Pleasant for longer sessions', 'लंबे सत्रों के लिए सुखद'),
      LText('Helps you feel steady and grounded', 'स्थिर और जमीन से जुड़ा महसूस कराता है'),
    ],
    steps: [
      LText('Sit or lie down and close your eyes if you like.', 'बैठें या लेटें, चाहें तो आँखें बंद कर लें।'),
      LText('Breathe in smoothly for 5 seconds.', '5 सेकंड तक सहजता से साँस लें।'),
      LText('Breathe out smoothly for 5 seconds.', '5 सेकंड तक सहजता से साँस छोड़ें।'),
      LText('Let one breath flow into the next, like a gentle wave.', 'एक साँस को दूसरी में लहर की तरह बहने दें।'),
    ],
    pattern: BreathPattern([BreathPhase(_in, 5), BreathPhase(_out, 5)]),
    recommendedMinutes: 5,
    icon: Icons.waves,
    color: AppColors.skyDeep,
    tags: {TechniqueTag.balance, TechniqueTag.calm},
  ),
  Technique(
    id: 'relax',
    name: LText('Gentle Relaxation Breathing', 'कोमल विश्राम श्वास'),
    tagline: LText('Let go a little more with every exhale', 'हर साँस छोड़ने के साथ थोड़ा और छोड़ दें'),
    description: LText(
      'A soft rhythm with a relaxed, longer out-breath. With each exhale, you let a part of your body — face, shoulders, hands — release a little more tension.',
      'आरामदायक और लंबी साँस छोड़ने वाली कोमल लय। हर साँस छोड़ने के साथ आप शरीर के किसी हिस्से — चेहरा, कंधे, हाथ — का थोड़ा और तनाव छोड़ते हैं।',
    ),
    purpose: LText(
      'Ideal after a long day or whenever you want to physically unwind.',
      'लंबे दिन के बाद या जब भी शरीर को आराम देना चाहें, तब आदर्श।',
    ),
    benefits: [
      LText('Combines breathing with body relaxation', 'श्वास को शारीरिक विश्राम के साथ जोड़ता है'),
      LText('Helps release everyday stress', 'रोज़मर्रा का तनाव छोड़ने में मदद'),
      LText('No holds, just easy breathing', 'कोई रोक नहीं, बस सहज श्वास'),
    ],
    steps: [
      LText('Get comfortable and let your eyes soften.', 'आराम से बैठें और आँखों को ढीला छोड़ें।'),
      LText('Breathe in for 4 seconds.', '4 सेकंड तक साँस लें।'),
      LText(
        'Breathe out for 7 seconds and relax one part of your body.',
        '7 सेकंड तक साँस छोड़ें और शरीर के एक हिस्से को ढीला करें।',
      ),
      LText('Move from your face, to shoulders, to arms and hands.', 'चेहरे से कंधों, फिर बाँहों और हाथों तक जाएँ।'),
    ],
    pattern: BreathPattern([BreathPhase(_in, 4), BreathPhase(_out, 7)]),
    recommendedMinutes: 4,
    icon: Icons.eco_outlined,
    color: AppColors.sage,
    tags: {TechniqueTag.relax, TechniqueTag.calm},
  ),
  Technique(
    id: 'focus',
    name: LText('Focus Breathing', 'एकाग्रता श्वास'),
    tagline: LText('A short reset for a clearer mind', 'साफ़ मन के लिए छोटा सा रीसेट'),
    description: LText(
      'A crisp, steady rhythm with a brief pause after each in-breath. It gives your attention a clear task so you can come back to your work refreshed.',
      'हर साँस लेने के बाद छोटे ठहराव वाली स्पष्ट और स्थिर लय। यह आपके ध्यान को एक साफ़ काम देती है ताकि आप ताज़गी से काम पर लौट सकें।',
    ),
    purpose: LText(
      'Great before studying, working, or any task that needs attention.',
      'पढ़ाई, काम या ध्यान माँगने वाले किसी भी काम से पहले बढ़िया।',
    ),
    benefits: [
      LText('Helps bring wandering attention back', 'भटकते ध्यान को वापस लाने में मदद'),
      LText('Short and easy to fit into a break', 'छोटा, किसी भी ब्रेक में आसानी से'),
      LText('Leaves you feeling refreshed', 'ताज़गी का एहसास देता है'),
    ],
    steps: [
      LText('Sit tall with both feet on the floor.', 'दोनों पैर ज़मीन पर रखकर सीधे बैठें।'),
      LText(
        'Breathe in for 4 seconds while noticing the air at your nose.',
        'नाक पर हवा को महसूस करते हुए 4 सेकंड साँस लें।',
      ),
      LText('Pause briefly for 2 seconds, only if comfortable.', 'सहज हो तो 2 सेकंड के लिए हल्का रुकें।'),
      LText(
        'Breathe out for 4 seconds and return your focus to the breath.',
        '4 सेकंड साँस छोड़ें और ध्यान वापस साँस पर लाएँ।',
      ),
    ],
    pattern: BreathPattern([BreathPhase(_in, 4), BreathPhase(_holdIn, 2), BreathPhase(_out, 4)]),
    recommendedMinutes: 3,
    icon: Icons.center_focus_strong_outlined,
    color: AppColors.sun,
    tags: {TechniqueTag.focus},
    caution: _holdCaution,
  ),
];

/// The gentle, hold-free rhythm used by Emergency Calm Mode.
const Technique calmModeTechnique = Technique(
  id: 'calm_mode',
  name: LText('Calm Mode', 'शांत मोड'),
  tagline: LText('Gentle breathing at your own pace', 'अपनी गति से कोमल श्वास'),
  description: LText('A simple in-and-out rhythm with no holds.', 'बिना रोक के सरल श्वास लय।'),
  purpose: LText('Quick relaxation.', 'त्वरित विश्राम।'),
  benefits: [],
  steps: [],
  pattern: BreathPattern([BreathPhase(_in, 4), BreathPhase(_out, 6)]),
  recommendedMinutes: 3,
  icon: Icons.favorite_border,
  color: AppColors.mintDeep,
  tags: {TechniqueTag.calm, TechniqueTag.relax},
);

Technique? techniqueById(String id) {
  if (id == calmModeTechnique.id) return calmModeTechnique;
  for (final t in allTechniques) {
    if (t.id == id) return t;
  }
  return null;
}
