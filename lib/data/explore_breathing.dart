import 'package:flutter/material.dart';

import '../l10n/l_text.dart';
import '../models/article.dart';
import '../theme/app_colors.dart';

const _p = ExploreCategory.pranayama;
const _c = ExploreCategory.calm;

const _comfort = ArticleSection(
  heading: Headings.gently,
  body: LText(
    'Breathe softly and never strain. If you feel dizzy or uncomfortable, stop and return to normal breathing.',
    'कोमलता से साँस लें और कभी ज़ोर न लगाएँ। चक्कर या असहजता लगे तो रुकें और सामान्य साँस पर लौट आएँ।',
  ),
);

/// Pranayama and quick breathing tricks.
const List<Article> breathingArticles = [
  Article(
    id: 'pr_nadishodhana',
    category: _p,
    title: LText('Alternate Nostril Breathing', 'अनुलोम-विलोम'),
    subtitle: LText('Nadi Shodhana', 'नाड़ी शोधन'),
    summary: LText('Breathe through one nostril at a time for a balanced feel.', 'एक-एक नथुने से साँस लेकर संतुलन का अनुभव।'),
    readMinutes: 3,
    icon: Icons.swap_horiz_rounded,
    color: AppColors.sky,
    youtubeQuery: 'Nadi Shodhana anulom vilom pranayama steps',
    sections: [
      ArticleSection(
        body: LText(
          'One of the best-known pranayamas. It is calm and slow, done without any breath holding here.',
          'सबसे प्रसिद्ध प्राणायामों में से एक। यह शांत और धीमा है, और यहाँ बिना साँस रोके किया जाता है।',
        ),
      ),
      ArticleSection(
        heading: Headings.how,
        body: LText('Sit comfortably and use your right hand:', 'आराम से बैठें और दाएँ हाथ का उपयोग करें:'),
        bullets: [
          LText('Close the right nostril with your thumb; breathe in through the left.', 'अँगूठे से दायाँ नथुना बंद करें; बाएँ से साँस लें।'),
          LText('Close the left with your ring finger; breathe out through the right.', 'अनामिका से बायाँ बंद करें; दाएँ से साँस छोड़ें।'),
          LText('Breathe in through the right, then switch and breathe out through the left.', 'दाएँ से साँस लें, फिर बदलकर बाएँ से छोड़ें।'),
          LText('That is one round. Try 5–10 slow rounds.', 'यह एक चक्र है। 5–10 धीमे चक्र करें।'),
        ],
      ),
      ArticleSection(
        heading: Headings.why,
        body: LText('People often say it feels:', 'लोग अक्सर बताते हैं कि यह:'),
        bullets: [
          LText('Balancing and settling', 'संतुलित और स्थिर करने वाला लगता है'),
          LText('A good way to begin meditation', 'ध्यान शुरू करने का अच्छा तरीका है'),
        ],
      ),
      _comfort,
    ],
  ),
  Article(
    id: 'pr_bhramari',
    category: _p,
    title: LText('Humming Bee Breath', 'भ्रामरी प्राणायाम'),
    subtitle: LText('Bhramari', 'भ्रामरी'),
    summary: LText('A soft hum on the out-breath — simple and soothing.', 'साँस छोड़ते समय हल्की गुनगुनाहट — सरल और सुकून भरी।'),
    readMinutes: 2,
    icon: Icons.graphic_eq_rounded,
    color: AppColors.sun,
    youtubeQuery: 'Bhramari pranayama humming bee breath',
    sections: [
      ArticleSection(
        body: LText(
          'Bhramari is named after the humming bee. The gentle vibration of the hum is what many people love about it.',
          'भ्रामरी का नाम भौंरे की गुनगुनाहट से आया है। हल्का कंपन ही इसे बहुत लोगों का पसंदीदा बनाता है।',
        ),
      ),
      ArticleSection(
        heading: Headings.how,
        body: LText('Sit tall with eyes closed:', 'आँखें बंद करके सीधे बैठें:'),
        bullets: [
          LText('Optionally, place your index fingers gently on the ear flaps.', 'चाहें तो तर्जनी उँगलियों को कानों के बाहरी हिस्से पर हल्के से रखें।'),
          LText('Breathe in slowly through your nose.', 'नाक से धीरे साँस लें।'),
          LText('Breathe out while making a soft “mmm” hum.', 'हल्की “म्म्म” गुनगुनाहट के साथ साँस छोड़ें।'),
          LText('Repeat 5–7 times, then sit quietly.', '5–7 बार दोहराएँ, फिर शांत बैठें।'),
        ],
      ),
      ArticleSection(
        heading: Headings.why,
        body: LText('Enjoyed because:', 'पसंद किया जाता है क्योंकि:'),
        bullets: [
          LText('The hum naturally lengthens the exhale', 'गुनगुनाहट से साँस छोड़ना अपने-आप लंबा होता है'),
          LText('It feels calming and inward', 'यह शांत और अंतर्मुखी अनुभव देता है'),
        ],
      ),
      _comfort,
    ],
  ),
  Article(
    id: 'pr_ujjayi',
    category: _p,
    title: LText('Ocean Breath', 'उज्जायी प्राणायाम'),
    subtitle: LText('Ujjayi', 'उज्जायी'),
    summary: LText('A quiet, wave-like sound in the throat as you breathe.', 'साँस के साथ गले में लहर जैसी हल्की आवाज़।'),
    readMinutes: 2,
    icon: Icons.water_rounded,
    color: AppColors.skyDeep,
    youtubeQuery: 'Ujjayi breath how to do',
    sections: [
      ArticleSection(
        body: LText(
          'Ujjayi is often used during yoga. A slight narrowing at the back of the throat makes a soft ocean-like sound.',
          'उज्जायी अक्सर योग के दौरान की जाती है। गले के पिछले हिस्से को हल्का संकरा करने से समुद्र जैसी कोमल आवाज़ आती है।',
        ),
      ),
      ArticleSection(
        heading: Headings.how,
        body: LText('Try it like this:', 'ऐसे आज़माएँ:'),
        bullets: [
          LText('Breathe out through the mouth as if fogging a mirror — “haaa”.', 'मुँह से ऐसे साँस छोड़ें जैसे शीशे पर भाप बना रहे हों — “हाआ”।'),
          LText('Now close your mouth and keep that soft sound, breathing through the nose.', 'अब मुँह बंद करें और नाक से साँस लेते हुए वही हल्की आवाज़ रखें।'),
          LText('Keep the breath slow, smooth and quiet.', 'साँस धीमी, सहज और शांत रखें।'),
          LText('Continue for 1–3 minutes.', '1–3 मिनट तक करें।'),
        ],
      ),
      ArticleSection(
        heading: Headings.why,
        body: LText('People like it because:', 'लोग इसे पसंद करते हैं क्योंकि:'),
        bullets: [
          LText('The sound gives the mind something to follow', 'आवाज़ मन को एक सहारा देती है'),
          LText('It helps keep a steady rhythm in yoga', 'योग में स्थिर लय बनाए रखने में मदद करती है'),
        ],
      ),
      _comfort,
    ],
  ),
  Article(
    id: 'pr_sheetali',
    category: _p,
    title: LText('Cooling Breath', 'शीतली प्राणायाम'),
    subtitle: LText('Sheetali / Sheetkari', 'शीतली / शीतकारी'),
    summary: LText('Breathe in over the tongue for a fresh, cool feeling.', 'जीभ के ऊपर से साँस लेकर ठंडक का एहसास।'),
    readMinutes: 2,
    icon: Icons.ac_unit_rounded,
    color: AppColors.mint,
    youtubeQuery: 'Sheetali pranayama cooling breath',
    sections: [
      ArticleSection(
        body: LText(
          'Traditionally enjoyed on hot days. If you can’t roll your tongue, Sheetkari (breathing in through closed teeth) works too.',
          'पारंपरिक रूप से गर्म दिनों में किया जाता है। अगर जीभ मोड़ नहीं पाते, तो शीतकारी (बंद दाँतों से साँस लेना) भी उतना ही अच्छा है।',
        ),
      ),
      ArticleSection(
        heading: Headings.how,
        body: LText('Sitting comfortably:', 'आराम से बैठकर:'),
        bullets: [
          LText('Roll your tongue into a tube (or rest teeth lightly together).', 'जीभ को नली जैसा मोड़ें (या दाँतों को हल्का मिलाएँ)।'),
          LText('Breathe in slowly through the tongue or teeth.', 'जीभ या दाँतों से धीरे साँस लें।'),
          LText('Close your mouth and breathe out through the nose.', 'मुँह बंद करें और नाक से साँस छोड़ें।'),
          LText('Repeat 5–8 times.', '5–8 बार दोहराएँ।'),
        ],
      ),
      ArticleSection(
        heading: Headings.why,
        body: LText('Popular for:', 'लोकप्रिय है:'),
        bullets: [
          LText('A refreshing pause in summer', 'गर्मियों में ताज़गी भरे ठहराव के लिए'),
          LText('Feeling cool and calm', 'ठंडक और शांति के एहसास के लिए'),
        ],
      ),
      _comfort,
    ],
  ),
  Article(
    id: 'pr_dirgha',
    category: _p,
    title: LText('Three-Part Breath', 'त्रिभागीय श्वास'),
    subtitle: LText('Dirgha Pranayama', 'दीर्घ प्राणायाम'),
    summary: LText('Fill the belly, ribs and chest in one smooth wave.', 'पेट, पसलियों और छाती को एक सहज लहर में भरें।'),
    readMinutes: 2,
    icon: Icons.stacked_line_chart_rounded,
    color: AppColors.sage,
    youtubeQuery: 'Dirgha pranayama three part breath',
    sections: [
      ArticleSection(
        body: LText(
          'A full, slow breath that teaches you to use your whole torso.',
          'एक पूरी, धीमी साँस जो पूरे धड़ का उपयोग करना सिखाती है।',
        ),
      ),
      ArticleSection(
        heading: Headings.how,
        body: LText('Lying down or sitting:', 'लेटकर या बैठकर:'),
        bullets: [
          LText('Breathe in and let the belly rise.', 'साँस लें और पेट को ऊपर उठने दें।'),
          LText('Continue the breath into the ribs, then the upper chest.', 'साँस को पसलियों तक, फिर ऊपरी छाती तक ले जाएँ।'),
          LText('Breathe out slowly: chest, ribs, then belly.', 'धीरे साँस छोड़ें: छाती, पसलियाँ, फिर पेट।'),
          LText('Repeat for 1–3 minutes.', '1–3 मिनट दोहराएँ।'),
        ],
      ),
      ArticleSection(
        heading: Headings.why,
        body: LText('Liked because:', 'पसंद किया जाता है क्योंकि:'),
        bullets: [
          LText('It’s an easy way to slow down', 'धीमे होने का आसान तरीका है'),
          LText('It builds body awareness', 'शरीर के प्रति जागरूकता बढ़ाता है'),
        ],
      ),
      _comfort,
    ],
  ),
  Article(
    id: 'pr_sigh',
    category: _p,
    title: LText('The Calming Sigh', 'सुकून भरी आह'),
    subtitle: LText('Double inhale, long exhale', 'दो बार साँस लें, लंबा छोड़ें'),
    summary: LText('A quick reset you can do anywhere in under a minute.', 'एक मिनट से कम में कहीं भी किया जा सकने वाला रीसेट।'),
    readMinutes: 1,
    icon: Icons.air_rounded,
    color: AppColors.mintDeep,
    sections: [
      ArticleSection(
        body: LText(
          'We naturally sigh when we let go of tension. Doing it on purpose is a simple breathing trick.',
          'तनाव छोड़ते समय हम अपने-आप आह भरते हैं। इसे जानबूझकर करना एक आसान श्वास तरकीब है।',
        ),
      ),
      ArticleSection(
        heading: Headings.tryThis,
        body: LText('2–3 times:', '2–3 बार:'),
        bullets: [
          LText('Breathe in through the nose.', 'नाक से साँस लें।'),
          LText('Take a second, smaller sip of air on top.', 'ऊपर से एक और छोटी साँस भरें।'),
          LText('Breathe out slowly and fully through the mouth.', 'मुँह से धीरे और पूरी साँस छोड़ें।'),
        ],
      ),
      _comfort,
    ],
  ),
  Article(
    id: 'pr_nose',
    category: _p,
    title: LText('Nose Breathing Habit', 'नाक से साँस की आदत'),
    summary: LText('Small reminders to breathe through your nose during the day.', 'दिन भर नाक से साँस लेने के छोटे संकेत।'),
    readMinutes: 2,
    icon: Icons.face_rounded,
    color: AppColors.lavender,
    sections: [
      ArticleSection(
        body: LText(
          'Many breathing practices use the nose. Noticing how you breathe during the day is a gentle first step.',
          'कई श्वास अभ्यास नाक से होते हैं। दिन में अपनी साँस पर ध्यान देना एक आसान पहला कदम है।',
        ),
      ),
      ArticleSection(
        heading: Headings.tryThis,
        body: LText('Easy reminders:', 'आसान संकेत:'),
        bullets: [
          LText('Check in at every meal: lips closed, breathe through the nose.', 'हर भोजन पर ध्यान दें: होंठ बंद, नाक से साँस।'),
          LText('On walks, breathe in and out through the nose at an easy pace.', 'टहलते समय आराम की गति से नाक से साँस लें और छोड़ें।'),
          LText('Keep your shoulders and jaw relaxed.', 'कंधे और जबड़ा ढीला रखें।'),
        ],
      ),
      ArticleSection(
        heading: Headings.goodToKnow,
        body: LText(
          'If your nose is often blocked, or breathing feels difficult, please talk to a doctor.',
          'अगर नाक अक्सर बंद रहती है या साँस लेने में कठिनाई होती है, तो कृपया डॉक्टर से बात करें।',
        ),
      ),
    ],
  ),
  Article(
    id: 'pr_counting',
    category: _p,
    title: LText('Breath Counting', 'साँसों की गिनती'),
    summary: LText('Count breaths from 1 to 10 to steady a busy mind.', 'व्यस्त मन को स्थिर करने के लिए 1 से 10 तक साँसें गिनें।'),
    readMinutes: 1,
    icon: Icons.format_list_numbered_rounded,
    color: AppColors.creamDeep,
    sections: [
      ArticleSection(
        body: LText(
          'A classic attention practice. Losing count is normal — just start again at one.',
          'ध्यान का एक पुराना अभ्यास। गिनती भूल जाना सामान्य है — बस फिर से एक से शुरू करें।',
        ),
      ),
      ArticleSection(
        heading: Headings.tryThis,
        body: LText('For 2–5 minutes:', '2–5 मिनट के लिए:'),
        bullets: [
          LText('Breathe naturally.', 'स्वाभाविक साँस लें।'),
          LText('Count “one” on the out-breath, “two” on the next, up to ten.', 'साँस छोड़ते समय “एक”, अगली पर “दो”, दस तक गिनें।'),
          LText('Then begin again at one.', 'फिर एक से दोबारा शुरू करें।'),
        ],
      ),
    ],
  ),
];

/// Calm and stress-relief practices.
const List<Article> calmArticles = [
  Article(
    id: 'calm_54321',
    category: _c,
    title: LText('5-4-3-2-1 Grounding', '5-4-3-2-1 ग्राउंडिंग'),
    summary: LText('Use your senses to come back to the present moment.', 'अपनी इंद्रियों से वर्तमान पल में लौटें।'),
    readMinutes: 2,
    icon: Icons.back_hand_rounded,
    color: AppColors.mint,
    sections: [
      ArticleSection(
        body: LText(
          'A simple way to shift attention away from racing thoughts by noticing what is around you.',
          'आस-पास की चीज़ों पर ध्यान देकर दौड़ते विचारों से ध्यान हटाने का आसान तरीका।',
        ),
      ),
      ArticleSection(
        heading: Headings.tryThis,
        body: LText('Slowly name:', 'धीरे-धीरे पहचानें:'),
        bullets: [
          LText('5 things you can see', '5 चीज़ें जो आप देख सकते हैं'),
          LText('4 things you can feel', '4 चीज़ें जो आप महसूस कर सकते हैं'),
          LText('3 things you can hear', '3 चीज़ें जो आप सुन सकते हैं'),
          LText('2 things you can smell', '2 चीज़ें जिनकी गंध आप ले सकते हैं'),
          LText('1 thing you can taste', '1 चीज़ जिसका स्वाद आप ले सकते हैं'),
        ],
      ),
    ],
  ),
  Article(
    id: 'calm_pmr',
    category: _c,
    title: LText('Progressive Muscle Relaxation', 'क्रमिक मांसपेशी विश्राम'),
    summary: LText('Tense and release each muscle group, head to toe.', 'सिर से पैर तक हर मांसपेशी को कसें और ढीला छोड़ें।'),
    readMinutes: 3,
    icon: Icons.accessibility_new_rounded,
    color: AppColors.lavender,
    youtubeQuery: 'progressive muscle relaxation guided',
    sections: [
      ArticleSection(
        body: LText(
          'By gently tensing and then relaxing your muscles, you learn what “letting go” feels like.',
          'मांसपेशियों को हल्का कसकर फिर ढीला छोड़ने से आप समझते हैं कि “छोड़ देना” कैसा लगता है।',
        ),
      ),
      ArticleSection(
        heading: Headings.how,
        body: LText('Lying or sitting comfortably:', 'आराम से लेटकर या बैठकर:'),
        bullets: [
          LText('Start with your feet: tense gently for 5 seconds.', 'पैरों से शुरू करें: 5 सेकंड हल्का कसें।'),
          LText('Release and notice the difference for 10 seconds.', 'छोड़ें और 10 सेकंड अंतर महसूस करें।'),
          LText('Move up: legs, belly, hands, arms, shoulders, face.', 'ऊपर बढ़ें: पैर, पेट, हाथ, बाँहें, कंधे, चेहरा।'),
          LText('Finish with a few slow breaths.', 'कुछ धीमी साँसों के साथ समाप्त करें।'),
        ],
      ),
      ArticleSection(
        heading: Headings.gently,
        body: LText(
          'Tense lightly — never to the point of pain or cramp. Skip any area that is injured.',
          'हल्का ही कसें — दर्द या ऐंठन तक नहीं। किसी चोटिल हिस्से को छोड़ दें।',
        ),
      ),
    ],
  ),
  Article(
    id: 'calm_bodyscan',
    category: _c,
    title: LText('Body Scan', 'बॉडी स्कैन'),
    subtitle: LText('A Yoga Nidra–style rest', 'योग निद्रा जैसा विश्राम'),
    summary: LText('Move your attention slowly through the body.', 'ध्यान को धीरे-धीरे पूरे शरीर में घुमाएँ।'),
    readMinutes: 2,
    icon: Icons.person_search_rounded,
    color: AppColors.sky,
    youtubeQuery: 'yoga nidra body scan guided',
    sections: [
      ArticleSection(
        body: LText(
          'There’s nothing to change — you simply notice each part of the body with kindness.',
          'कुछ बदलना नहीं है — बस शरीर के हर हिस्से को स्नेह से महसूस करें।',
        ),
      ),
      ArticleSection(
        heading: Headings.how,
        body: LText('For 5–10 minutes:', '5–10 मिनट के लिए:'),
        bullets: [
          LText('Lie down and close your eyes.', 'लेट जाएँ और आँखें बंद करें।'),
          LText('Bring attention to your toes, then feet, ankles and legs.', 'ध्यान पंजों पर लाएँ, फिर पैर, टखने और टाँगें।'),
          LText('Continue slowly up to the top of your head.', 'धीरे-धीरे सिर के ऊपर तक जाएँ।'),
          LText('If your mind wanders, gently come back.', 'मन भटके तो धीरे से वापस आएँ।'),
        ],
      ),
    ],
  ),
  Article(
    id: 'calm_journal',
    category: _c,
    title: LText('Worry Journal', 'चिंता डायरी'),
    summary: LText('Write thoughts down so you don’t have to carry them.', 'विचार लिख दें ताकि उन्हें साथ न ढोना पड़े।'),
    readMinutes: 2,
    icon: Icons.edit_note_rounded,
    color: AppColors.creamDeep,
    sections: [
      ArticleSection(
        body: LText(
          'Putting worries on paper can make them feel smaller and easier to sort.',
          'चिंताओं को कागज़ पर उतारने से वे छोटी और सुलझाने में आसान लग सकती हैं।',
        ),
      ),
      ArticleSection(
        heading: Headings.tryThis,
        body: LText('Once a day, for 10 minutes:', 'दिन में एक बार, 10 मिनट:'),
        bullets: [
          LText('Write down whatever is on your mind.', 'जो भी मन में है लिख दें।'),
          LText('Mark what you can act on and what you can’t control.', 'जिस पर काम कर सकते हैं और जो नियंत्रण से बाहर है, उसे अलग करें।'),
          LText('Pick one small next step.', 'एक छोटा अगला कदम चुनें।'),
          LText('Close the notebook and take three slow breaths.', 'डायरी बंद करें और तीन धीमी साँसें लें।'),
        ],
      ),
    ],
  ),
  Article(
    id: 'calm_gratitude',
    category: _c,
    title: LText('Three Good Things', 'तीन अच्छी बातें'),
    summary: LText('End the day by noticing what went well.', 'दिन के अंत में देखें कि क्या अच्छा हुआ।'),
    readMinutes: 1,
    icon: Icons.favorite_rounded,
    color: AppColors.blush,
    sections: [
      ArticleSection(
        body: LText(
          'A small gratitude habit that many people find uplifting.',
          'कृतज्ञता की एक छोटी आदत जो बहुत लोगों को अच्छी लगती है।',
        ),
      ),
      ArticleSection(
        heading: Headings.tryThis,
        body: LText('Each evening, write:', 'हर शाम लिखें:'),
        bullets: [
          LText('Three things that went well today — big or small.', 'आज की तीन अच्छी बातें — बड़ी या छोटी।'),
          LText('Why each one happened.', 'हर एक क्यों हुई।'),
        ],
      ),
    ],
  ),
  Article(
    id: 'calm_digital',
    category: _c,
    title: LText('Mini Digital Detox', 'छोटा डिजिटल ब्रेक'),
    summary: LText('Short screen-free breaks to rest your eyes and mind.', 'आँखों और मन को आराम देने के लिए छोटे स्क्रीन-मुक्त ब्रेक।'),
    readMinutes: 2,
    icon: Icons.phonelink_erase_rounded,
    color: AppColors.sage,
    sections: [
      ArticleSection(
        body: LText(
          'Constant notifications keep the mind busy. Small breaks can feel surprisingly refreshing.',
          'लगातार नोटिफ़िकेशन मन को व्यस्त रखते हैं। छोटे ब्रेक आश्चर्यजनक रूप से ताज़गी दे सकते हैं।',
        ),
      ),
      ArticleSection(
        heading: Headings.tryThis,
        body: LText('Pick one:', 'कोई एक चुनें:'),
        bullets: [
          LText('No phone for the first 20 minutes after waking.', 'उठने के बाद पहले 20 मिनट फ़ोन नहीं।'),
          LText('Every 20 minutes of screen time, look 20 feet away for 20 seconds.', 'हर 20 मिनट स्क्रीन के बाद 20 सेकंड 20 फ़ीट दूर देखें।'),
          LText('Phone-free meals.', 'फ़ोन-मुक्त भोजन।'),
          LText('Screens off 30–60 minutes before bed.', 'सोने से 30–60 मिनट पहले स्क्रीन बंद।'),
        ],
      ),
    ],
  ),
  Article(
    id: 'calm_nature',
    category: _c,
    title: LText('Time in Nature', 'प्रकृति के साथ समय'),
    summary: LText('A slow walk outdoors, paying attention to what’s around you.', 'बाहर धीमी सैर, आस-पास पर ध्यान देते हुए।'),
    readMinutes: 2,
    icon: Icons.forest_rounded,
    color: AppColors.mintDeep,
    sections: [
      ArticleSection(
        body: LText(
          'Many people feel calmer after time among trees, plants or open sky — even a small park counts.',
          'बहुत लोग पेड़-पौधों या खुले आसमान के बीच समय बिताकर शांत महसूस करते हैं — एक छोटा पार्क भी काफ़ी है।',
        ),
      ),
      ArticleSection(
        heading: Headings.tryThis,
        body: LText('On your next walk:', 'अपनी अगली सैर पर:'),
        bullets: [
          LText('Leave headphones off for the first few minutes.', 'पहले कुछ मिनट हेडफ़ोन न लगाएँ।'),
          LText('Notice colours, sounds and the air on your skin.', 'रंगों, आवाज़ों और त्वचा पर हवा को महसूस करें।'),
          LText('Match a few steps to slow breaths.', 'कुछ कदमों को धीमी साँसों से मिलाएँ।'),
        ],
      ),
    ],
  ),
];
