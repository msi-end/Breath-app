import 'package:flutter/material.dart';

import '../l10n/l_text.dart';
import '../models/article.dart';
import '../theme/app_colors.dart';

const List<Article> allArticles = [
  Article(
    id: 'understanding',
    title: LText('Understanding Breathing Exercises', 'श्वास अभ्यास को समझना'),
    summary: LText(
      'What breathing exercises are and why so many people enjoy them.',
      'श्वास अभ्यास क्या हैं और लोग इन्हें क्यों पसंद करते हैं।',
    ),
    readMinutes: 3,
    icon: Icons.menu_book_outlined,
    color: AppColors.mint,
    sections: [
      ArticleSection(
        body: LText(
          'Most of the time we breathe without thinking about it. Breathing exercises simply invite you to pay attention to your breath and shape it gently — making it slower, deeper, or more even for a few minutes.',
          'ज़्यादातर समय हम बिना सोचे साँस लेते हैं। श्वास अभ्यास आपको अपनी साँस पर ध्यान देने और उसे कोमलता से ढालने का निमंत्रण देते हैं — कुछ मिनटों के लिए उसे धीमा, गहरा या अधिक संतुलित बनाना।',
        ),
      ),
      ArticleSection(
        heading: LText('Why people practice', 'लोग अभ्यास क्यों करते हैं'),
        body: LText(
          'Many people find that a few minutes of intentional breathing helps them feel more relaxed and present. It needs no equipment and can be done almost anywhere.',
          'बहुत से लोग पाते हैं कि कुछ मिनट की सजग श्वास उन्हें अधिक आरामदायक और वर्तमान में महसूस कराती है। इसके लिए किसी उपकरण की ज़रूरत नहीं और इसे लगभग कहीं भी किया जा सकता है।',
        ),
        bullets: [
          LText('Taking a calm pause in a busy day', 'व्यस्त दिन में एक शांत ठहराव'),
          LText('Settling down before an important task', 'किसी ज़रूरी काम से पहले स्थिर होना'),
          LText('Winding down in the evening', 'शाम को आराम की ओर बढ़ना'),
        ],
      ),
      ArticleSection(
        heading: LText('A wellness habit, not a treatment', 'एक वेलनेस आदत, इलाज नहीं'),
        body: LText(
          'Breathing exercises are a relaxation and wellness practice. They are not a medical treatment and do not replace advice from a qualified health professional.',
          'श्वास अभ्यास विश्राम और वेलनेस का अभ्यास है। यह कोई चिकित्सीय उपचार नहीं है और योग्य स्वास्थ्य विशेषज्ञ की सलाह का विकल्प नहीं है।',
        ),
      ),
    ],
  ),
  Article(
    id: 'relaxation',
    title: LText('Breathing and Relaxation', 'श्वास और विश्राम'),
    summary: LText(
      'How slowing your breath can help you feel more at ease.',
      'साँस धीमी करना आपको अधिक सहज कैसे महसूस करा सकता है।',
    ),
    readMinutes: 3,
    icon: Icons.spa_outlined,
    color: AppColors.sky,
    sections: [
      ArticleSection(
        body: LText(
          'When we feel tense, our breathing often becomes quick and shallow. When we are relaxed, it tends to be slower and softer. Gently slowing your breath is one way to invite a more relaxed state.',
          'जब हम तनाव में होते हैं, तो साँस अक्सर तेज़ और उथली हो जाती है। आराम की स्थिति में यह धीमी और कोमल होती है। साँस को धीरे से धीमा करना अधिक आरामदायक अवस्था को आमंत्रित करने का एक तरीका है।',
        ),
      ),
      ArticleSection(
        heading: LText('The power of a longer exhale', 'लंबी साँस छोड़ने की शक्ति'),
        body: LText(
          'Many relaxing techniques make the out-breath a little longer than the in-breath. People often describe this as a feeling of letting go.',
          'कई आरामदायक तकनीकों में साँस छोड़ना साँस लेने से थोड़ा लंबा होता है। लोग अक्सर इसे "छोड़ देने" जैसा एहसास बताते हैं।',
        ),
        bullets: [
          LText('Try Deep Belly Breathing: in 4, out 6', 'गहरी पेट श्वास आज़माएँ: 4 में लें, 6 में छोड़ें'),
          LText('Try Gentle Relaxation: in 4, out 7', 'कोमल विश्राम आज़माएँ: 4 में लें, 7 में छोड़ें'),
        ],
      ),
      ArticleSection(
        heading: LText('Make it comfortable', 'इसे आरामदायक बनाएँ'),
        body: LText(
          'Relaxation comes from ease, not effort. If a count feels too long, shorten it. There is no perfect way — only what feels comfortable for you.',
          'विश्राम सहजता से आता है, ज़ोर लगाने से नहीं। अगर गिनती लंबी लगे, तो उसे छोटा करें। कोई "सही" तरीका नहीं — बस वही जो आपके लिए आरामदायक हो।',
        ),
      ),
    ],
  ),
  Article(
    id: 'stress',
    title: LText('Everyday Stress Management', 'रोज़मर्रा का तनाव प्रबंधन'),
    summary: LText(
      'Small, simple ways to add calm moments to your day.',
      'अपने दिन में शांत पल जोड़ने के छोटे और सरल तरीके।',
    ),
    readMinutes: 4,
    icon: Icons.wb_sunny_outlined,
    color: AppColors.sun,
    sections: [
      ArticleSection(
        body: LText(
          'Stress is a normal part of life. Deadlines, traffic and busy schedules affect all of us. Short breathing breaks are an easy way to give yourself a moment of calm.',
          'तनाव जीवन का सामान्य हिस्सा है। समय-सीमा, ट्रैफ़िक और व्यस्त दिनचर्या हम सभी को प्रभावित करते हैं। छोटे श्वास ब्रेक खुद को शांति का पल देने का आसान तरीका हैं।',
        ),
      ),
      ArticleSection(
        heading: LText('Micro-moments of calm', 'शांति के छोटे पल'),
        body: LText(
          'You do not need a long session. Try one or two minutes at natural pauses in your day:',
          'लंबे सत्र की ज़रूरत नहीं। दिन के स्वाभाविक ठहरावों में एक-दो मिनट आज़माएँ:',
        ),
        bullets: [
          LText('After waking up, before checking your phone', 'जागने के बाद, फ़ोन देखने से पहले'),
          LText('Before a meeting or class', 'मीटिंग या क्लास से पहले'),
          LText('During a work break', 'काम के ब्रेक के दौरान'),
          LText('Before going to bed', 'सोने से पहले'),
        ],
      ),
      ArticleSection(
        heading: LText('Beyond breathing', 'श्वास से आगे'),
        body: LText(
          'Breathing works best alongside other healthy habits: regular movement, good rest, time outdoors, and talking with people you trust. If stress feels overwhelming or lasts a long time, please reach out to a qualified professional.',
          'श्वास अभ्यास अन्य स्वस्थ आदतों के साथ सबसे अच्छा काम करता है: नियमित व्यायाम, अच्छा आराम, बाहर समय बिताना और भरोसेमंद लोगों से बात करना। अगर तनाव बहुत ज़्यादा लगे या लंबे समय तक रहे, तो कृपया किसी योग्य विशेषज्ञ से संपर्क करें।',
        ),
      ),
    ],
  ),
  Article(
    id: 'beginners',
    title: LText('Beginner’s Guide to Breathing', 'श्वास अभ्यास: शुरुआती गाइड'),
    summary: LText('Everything you need for your very first session.', 'आपके पहले सत्र के लिए ज़रूरी सब कुछ।'),
    readMinutes: 3,
    icon: Icons.emoji_nature_outlined,
    color: AppColors.mintDeep,
    sections: [
      ArticleSection(
        heading: LText('Find a comfortable position', 'आरामदायक स्थिति चुनें'),
        body: LText(
          'Sit in a chair with your feet on the floor, sit cross-legged, or lie on your back. Let your shoulders drop and your hands rest.',
          'कुर्सी पर पैर ज़मीन पर रखकर बैठें, पालथी मारकर बैठें, या पीठ के बल लेटें। कंधों को ढीला और हाथों को आराम से रखें।',
        ),
      ),
      ArticleSection(
        heading: LText('Start small', 'छोटी शुरुआत करें'),
        body: LText(
          'Begin with just 1–2 minutes of Beginner Breathing. As it becomes familiar, try longer sessions or new techniques.',
          'सिर्फ़ 1–2 मिनट की शुरुआती श्वास से शुरू करें। जब यह परिचित लगे, तो लंबे सत्र या नई तकनीकें आज़माएँ।',
        ),
      ),
      ArticleSection(
        heading: LText('Follow the circle', 'घेरे का अनुसरण करें'),
        body: LText(
          'In BreatheCare, the circle grows as you breathe in and shrinks as you breathe out. Follow it at a pace that feels natural.',
          'BreatheCare में, साँस लेते समय घेरा बड़ा होता है और छोड़ते समय छोटा। इसे ऐसी गति से अपनाएँ जो स्वाभाविक लगे।',
        ),
        bullets: [
          LText('Breathe through your nose when you can', 'जब संभव हो, नाक से साँस लें'),
          LText('Keep your breath soft and quiet', 'साँस को कोमल और शांत रखें'),
          LText('It is fine if your mind wanders — just come back', 'मन भटके तो कोई बात नहीं — बस वापस आ जाएँ'),
        ],
      ),
    ],
  ),
  Article(
    id: 'safety',
    title: LText('Safe Breathing Practices', 'सुरक्षित श्वास अभ्यास'),
    summary: LText(
      'Simple guidelines to keep your practice comfortable and safe.',
      'अभ्यास को आरामदायक और सुरक्षित रखने के सरल दिशानिर्देश।',
    ),
    readMinutes: 3,
    icon: Icons.health_and_safety_outlined,
    color: AppColors.blush,
    sections: [
      ArticleSection(
        heading: LText('Listen to your body', 'अपने शरीर की सुनें'),
        body: LText(
          'Breathing exercises should feel comfortable. You can stop at any time. If you feel dizzy, light-headed, or uncomfortable, stop and return to normal breathing.',
          'श्वास अभ्यास आरामदायक लगना चाहिए। आप कभी भी रुक सकते हैं। अगर चक्कर, हल्कापन या असहजता महसूस हो, तो रुकें और सामान्य रूप से साँस लें।',
        ),
      ),
      ArticleSection(
        heading: LText('Holds are always optional', 'साँस रोकना हमेशा वैकल्पिक है'),
        body: LText(
          'Some techniques include short pauses. Never force a hold. Turn on Gentle mode in BreatheCare to remove all holds.',
          'कुछ तकनीकों में छोटे ठहराव होते हैं। कभी ज़बरदस्ती साँस न रोकें। सभी ठहराव हटाने के लिए BreatheCare में जेंटल मोड चालू करें।',
        ),
      ),
      ArticleSection(
        heading: LText('When to seek help', 'कब मदद लें'),
        body: LText(
          'BreatheCare is a relaxation app, not a medical device. Seek urgent medical help for severe breathing difficulty, chest pain, fainting, or other serious symptoms. If you have a heart or lung condition, are pregnant, or have other health concerns, talk to your doctor before starting breathing exercises.',
          'BreatheCare एक विश्राम ऐप है, कोई चिकित्सा उपकरण नहीं। साँस लेने में गंभीर कठिनाई, सीने में दर्द, बेहोशी या अन्य गंभीर लक्षणों के लिए तुरंत चिकित्सा सहायता लें। अगर आपको हृदय या फेफड़ों की कोई समस्या है, आप गर्भवती हैं, या स्वास्थ्य से जुड़ी अन्य चिंताएँ हैं, तो श्वास अभ्यास शुरू करने से पहले डॉक्टर से बात करें।',
        ),
      ),
    ],
  ),
  Article(
    id: 'mistakes',
    title: LText('Common Breathing Mistakes', 'श्वास अभ्यास की आम गलतियाँ'),
    summary: LText(
      'Small adjustments that make your practice more enjoyable.',
      'छोटे बदलाव जो आपके अभ्यास को और सुखद बनाते हैं।',
    ),
    readMinutes: 3,
    icon: Icons.tips_and_updates_outlined,
    color: AppColors.lavender,
    sections: [
      ArticleSection(
        body: LText(
          'Everyone makes these at the start. Noticing them is already progress!',
          'शुरुआत में सभी ये गलतियाँ करते हैं। इन्हें पहचान लेना ही प्रगति है!',
        ),
      ),
      ArticleSection(
        heading: LText('Trying too hard', 'बहुत ज़्यादा ज़ोर लगाना'),
        body: LText(
          'Forcing very big breaths can feel uncomfortable. Aim for soft, gentle breaths instead.',
          'बहुत बड़ी साँसें ज़बरदस्ती लेना असहज लग सकता है। इसके बजाय कोमल साँसों का लक्ष्य रखें।',
        ),
      ),
      ArticleSection(
        heading: LText('Raising the shoulders', 'कंधे ऊपर उठाना'),
        body: LText(
          'Let your belly and ribs expand rather than lifting your shoulders toward your ears.',
          'कंधों को कानों की ओर उठाने के बजाय पेट और पसलियों को फैलने दें।',
        ),
      ),
      ArticleSection(
        heading: LText('Holding when uncomfortable', 'असहज होने पर भी साँस रोकना'),
        body: LText(
          'Holds should never strain. Shorten or skip them any time.',
          'साँस रोकने में कभी खिंचाव नहीं होना चाहिए। इन्हें कभी भी छोटा करें या छोड़ दें।',
        ),
      ),
      ArticleSection(
        heading: LText('Practicing only when stressed', 'केवल तनाव में अभ्यास करना'),
        body: LText(
          'Practicing on calm days too makes the technique feel familiar when you need it most.',
          'शांत दिनों में भी अभ्यास करने से ज़रूरत के समय तकनीक परिचित लगती है।',
        ),
      ),
    ],
  ),
  Article(
    id: 'focus',
    title: LText('Breathing and Focus', 'श्वास और एकाग्रता'),
    summary: LText(
      'Use your breath as a gentle anchor for your attention.',
      'साँस को ध्यान के लिए एक कोमल सहारा बनाएँ।',
    ),
    readMinutes: 3,
    icon: Icons.center_focus_strong_outlined,
    color: AppColors.skyDeep,
    sections: [
      ArticleSection(
        body: LText(
          'Our attention naturally wanders. Counting breaths gives the mind a simple, steady task, which many people find helpful before work or study.',
          'हमारा ध्यान स्वाभाविक रूप से भटकता है। साँसें गिनना मन को एक सरल, स्थिर काम देता है, जो बहुत से लोगों को काम या पढ़ाई से पहले मददगार लगता है।',
        ),
      ),
      ArticleSection(
        heading: LText('A focus routine', 'एकाग्रता की दिनचर्या'),
        body: LText('Try this before a task that needs attention:', 'ध्यान माँगने वाले किसी काम से पहले यह आज़माएँ:'),
        bullets: [
          LText('Put your phone on silent', 'फ़ोन को साइलेंट पर रखें'),
          LText('Do 2–3 minutes of Focus or Box Breathing', '2–3 मिनट एकाग्रता या बॉक्स श्वास करें'),
          LText('Decide the one thing you will do next', 'तय करें कि आगे कौन-सा एक काम करेंगे'),
        ],
      ),
      ArticleSection(
        heading: LText('When your mind wanders', 'जब मन भटके'),
        body: LText(
          'That is completely normal. Each time you notice and return to the breath, you are practicing focus.',
          'यह बिलकुल सामान्य है। हर बार जब आप ध्यान भटकने को पहचानकर साँस पर लौटते हैं, आप एकाग्रता का अभ्यास कर रहे होते हैं।',
        ),
      ),
    ],
  ),
  Article(
    id: 'habits',
    title: LText('Developing Healthy Breathing Habits', 'स्वस्थ श्वास आदतें बनाना'),
    summary: LText(
      'Turn a few calm minutes into a lasting daily routine.',
      'कुछ शांत मिनटों को एक स्थायी दिनचर्या में बदलें।',
    ),
    readMinutes: 4,
    icon: Icons.local_florist_outlined,
    color: AppColors.sage,
    sections: [
      ArticleSection(
        heading: LText('Link it to something you already do', 'इसे किसी मौजूदा आदत से जोड़ें'),
        body: LText(
          'Habits stick when they are attached to existing routines — after brushing your teeth, with your morning tea, or before opening your laptop.',
          'आदतें तब टिकती हैं जब वे मौजूदा दिनचर्या से जुड़ी हों — दाँत ब्रश करने के बाद, सुबह की चाय के साथ, या लैपटॉप खोलने से पहले।',
        ),
      ),
      ArticleSection(
        heading: LText('Small and steady wins', 'छोटा और नियमित ही जीतता है'),
        body: LText(
          'Two minutes every day is more valuable than one long session a month. Daily Challenges and streaks in BreatheCare can help keep you motivated.',
          'हर दिन दो मिनट, महीने में एक लंबे सत्र से ज़्यादा मूल्यवान है। BreatheCare के दैनिक चैलेंज और स्ट्रीक आपको प्रेरित रखने में मदद कर सकते हैं।',
        ),
      ),
      ArticleSection(
        heading: LText('Be kind to yourself', 'अपने प्रति दयालु रहें'),
        body: LText(
          'Missed a day? That is okay. Simply start again tomorrow. Progress is about returning, not about being perfect.',
          'कोई दिन छूट गया? कोई बात नहीं। बस कल फिर से शुरू करें। प्रगति लौटने में है, परफ़ेक्ट होने में नहीं।',
        ),
        bullets: [
          LText('Pick a regular time', 'एक नियमित समय चुनें'),
          LText('Save favorites for quick access', 'जल्दी पहुँच के लिए पसंदीदा सेव करें'),
          LText('Celebrate small milestones', 'छोटी उपलब्धियों का जश्न मनाएँ'),
        ],
      ),
    ],
  ),
];
