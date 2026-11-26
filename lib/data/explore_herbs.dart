import 'package:flutter/material.dart';

import '../l10n/l_text.dart';
import '../models/article.dart';
import '../theme/app_colors.dart';

const _h = ExploreCategory.herbs;
const _l = ExploreCategory.lifestyle;

/// The same safety note for every herb.
const _herbNote = ArticleSection(
  heading: Headings.goodToKnow,
  body: LText(
    'This is general, traditional information — not medical advice, and herbs are not a treatment for any condition. Use normal food amounts. If you are pregnant, breastfeeding, take medicines or have a health condition, talk to a doctor before using herbal supplements.',
    'यह सामान्य, पारंपरिक जानकारी है — चिकित्सीय सलाह नहीं, और जड़ी-बूटियाँ किसी बीमारी का इलाज नहीं हैं। भोजन जितनी सामान्य मात्रा ही लें। गर्भावस्था, स्तनपान, दवाइयों या किसी स्वास्थ्य समस्या की स्थिति में हर्बल सप्लीमेंट लेने से पहले डॉक्टर से सलाह लें।',
  ),
);

/// Herbs and spices from the Indian kitchen and beyond.
const List<Article> herbArticles = [
  Article(
    id: 'herb_haldi',
    category: _h,
    title: LText('Turmeric', 'हल्दी'),
    subtitle: LText('Haldi · Curcuma longa', 'हल्दी · हरिद्रा'),
    summary: LText('The golden spice of the Indian kitchen.', 'भारतीय रसोई का सुनहरा मसाला।'),
    readMinutes: 2,
    icon: Icons.local_florist_rounded,
    color: AppColors.sun,
    youtubeQuery: 'haldi doodh golden milk recipe',
    sections: [
      ArticleSection(
        body: LText(
          'Haldi gives curries their warm yellow colour and has been part of Indian cooking and home traditions for centuries.',
          'हल्दी सब्ज़ियों और दाल को गर्म पीला रंग देती है और सदियों से भारतीय खाने और घरेलू परंपराओं का हिस्सा है।',
        ),
      ),
      ArticleSection(
        heading: Headings.traditional,
        body: LText(
          'In Ayurveda, turmeric is valued as a warming spice and is a familiar part of daily cooking, festivals and home routines.',
          'आयुर्वेद में हल्दी को गर्म तासीर वाला मसाला माना जाता है, और यह रोज़ के खाने, त्योहारों और घरेलू दिनचर्या का जाना-पहचाना हिस्सा है।',
        ),
      ),
      ArticleSection(
        heading: Headings.ways,
        body: LText('Everyday ideas:', 'रोज़ के तरीके:'),
        bullets: [
          LText('Haldi doodh: warm milk with a pinch of turmeric and black pepper.', 'हल्दी दूध: गर्म दूध में चुटकी भर हल्दी और काली मिर्च।'),
          LText('A pinch in dal, sabzi or soup.', 'दाल, सब्ज़ी या सूप में एक चुटकी।'),
          LText('Fresh turmeric root in pickles.', 'अचार में ताज़ी कच्ची हल्दी।'),
        ],
      ),
      _herbNote,
    ],
  ),
  Article(
    id: 'herb_tulsi',
    category: _h,
    title: LText('Holy Basil', 'तुलसी'),
    subtitle: LText('Tulsi · Ocimum tenuiflorum', 'तुलसी'),
    summary: LText('A sacred plant often enjoyed as a soothing tea.', 'एक पवित्र पौधा, अक्सर सुकून देने वाली चाय के रूप में।'),
    readMinutes: 2,
    icon: Icons.eco_rounded,
    color: AppColors.mintDeep,
    youtubeQuery: 'tulsi tea recipe',
    sections: [
      ArticleSection(
        body: LText(
          'Tulsi grows in many Indian homes and holds a special place in daily rituals.',
          'तुलसी कई भारतीय घरों में उगती है और रोज़ की पूजा-परंपराओं में इसका विशेष स्थान है।',
        ),
      ),
      ArticleSection(
        heading: Headings.traditional,
        body: LText(
          'Ayurveda describes tulsi as a herb for overall balance, and its leaves are a classic part of home-made kadha in cooler months.',
          'आयुर्वेद में तुलसी को संपूर्ण संतुलन की जड़ी-बूटी बताया गया है, और ठंड के मौसम में घर के काढ़े में इसकी पत्तियाँ आम हैं।',
        ),
      ),
      ArticleSection(
        heading: Headings.ways,
        body: LText('Simple ideas:', 'आसान तरीके:'),
        bullets: [
          LText('Steep a few fresh leaves in hot water for a calming tea.', 'कुछ ताज़ी पत्तियाँ गर्म पानी में डालकर शांत चाय बनाएँ।'),
          LText('Add leaves to your regular chai.', 'अपनी रोज़ की चाय में पत्तियाँ डालें।'),
          LText('Grow a plant at home — caring for it is calming too.', 'घर में पौधा लगाएँ — उसकी देखभाल भी सुकून देती है।'),
        ],
      ),
      _herbNote,
    ],
  ),
  Article(
    id: 'herb_adrak',
    category: _h,
    title: LText('Ginger', 'अदरक'),
    subtitle: LText('Adrak · Zingiber officinale', 'अदरक · सोंठ'),
    summary: LText('A warming root found in chai, kadha and cooking.', 'चाय, काढ़े और खाने में इस्तेमाल होने वाली गर्म तासीर की जड़।'),
    readMinutes: 2,
    icon: Icons.spa_rounded,
    color: AppColors.creamDeep,
    youtubeQuery: 'adrak ginger tea recipe',
    sections: [
      ArticleSection(
        body: LText(
          'Fresh adrak and dried sonth are staples in Indian kitchens.',
          'ताज़ा अदरक और सूखी सोंठ भारतीय रसोई की ज़रूरी चीज़ें हैं।',
        ),
      ),
      ArticleSection(
        heading: Headings.traditional,
        body: LText(
          'Ginger is traditionally used as a warming spice and is a common part of home drinks on cold days.',
          'अदरक को पारंपरिक रूप से गर्म तासीर वाला मसाला माना जाता है और ठंडे दिनों के घरेलू पेयों का आम हिस्सा है।',
        ),
      ),
      ArticleSection(
        heading: Headings.ways,
        body: LText('Try:', 'आज़माएँ:'),
        bullets: [
          LText('Adrak chai.', 'अदरक वाली चाय।'),
          LText('Warm water with ginger slices, lemon and a little honey.', 'अदरक के टुकड़े, नींबू और थोड़े शहद के साथ गुनगुना पानी।'),
          LText('Grated ginger in dal, sabzi and soups.', 'दाल, सब्ज़ी और सूप में कसा हुआ अदरक।'),
        ],
      ),
      _herbNote,
    ],
  ),
  Article(
    id: 'herb_pudina',
    category: _h,
    title: LText('Mint', 'पुदीना'),
    subtitle: LText('Pudina · Mentha', 'पुदीना'),
    summary: LText('Fresh, cooling leaves for drinks and chutneys.', 'पेय और चटनी के लिए ताज़ी, ठंडी पत्तियाँ।'),
    readMinutes: 1,
    icon: Icons.grass_rounded,
    color: AppColors.mint,
    youtubeQuery: 'pudina chutney recipe',
    sections: [
      ArticleSection(
        body: LText(
          'Pudina’s fresh smell alone can feel refreshing. It is a summer favourite across India.',
          'पुदीने की ताज़ी खुशबू ही ताज़गी देती है। यह पूरे भारत में गर्मियों का पसंदीदा है।',
        ),
      ),
      ArticleSection(
        heading: Headings.ways,
        body: LText('Popular ways:', 'लोकप्रिय तरीके:'),
        bullets: [
          LText('Pudina chutney with meals.', 'भोजन के साथ पुदीने की चटनी।'),
          LText('Mint in chaas (buttermilk) or nimbu pani.', 'छाछ या नींबू पानी में पुदीना।'),
          LText('A few leaves in hot water as a light tea.', 'हल्की चाय के लिए गर्म पानी में कुछ पत्तियाँ।'),
        ],
      ),
      _herbNote,
    ],
  ),
  Article(
    id: 'herb_ashwagandha',
    category: _h,
    title: LText('Ashwagandha', 'अश्वगंधा'),
    subtitle: LText('Withania somnifera', 'अश्वगंधा'),
    summary: LText('A well-known Ayurvedic root, often taken with warm milk.', 'एक प्रसिद्ध आयुर्वेदिक जड़, अक्सर गर्म दूध के साथ।'),
    readMinutes: 2,
    icon: Icons.local_florist_outlined,
    color: AppColors.blush,
    sections: [
      ArticleSection(
        body: LText(
          'Ashwagandha is one of the most famous herbs in Ayurveda and is widely sold as a powder or supplement.',
          'अश्वगंधा आयुर्वेद की सबसे प्रसिद्ध जड़ी-बूटियों में से एक है और चूर्ण या सप्लीमेंट के रूप में खूब बिकती है।',
        ),
      ),
      ArticleSection(
        heading: Headings.traditional,
        body: LText(
          'Traditionally described as a rasayana (rejuvenating herb) and often taken at night with warm milk.',
          'पारंपरिक रूप से इसे रसायन (कायाकल्प करने वाली जड़ी-बूटी) माना जाता है और अक्सर रात को गर्म दूध के साथ लिया जाता है।',
        ),
      ),
      ArticleSection(
        heading: Headings.goodToKnow,
        body: LText(
          'Ashwagandha is a supplement, not a food spice — ask a doctor before starting it, especially if you are pregnant, have a thyroid or liver condition, or take any medicines. Stop if you notice side effects.',
          'अश्वगंधा एक सप्लीमेंट है, खाने का मसाला नहीं — इसे शुरू करने से पहले डॉक्टर से पूछें, खासकर गर्भावस्था, थायरॉइड या लिवर की समस्या, या कोई दवा लेने पर। कोई दुष्प्रभाव दिखे तो बंद कर दें।',
        ),
      ),
    ],
  ),
  Article(
    id: 'herb_brahmi',
    category: _h,
    title: LText('Brahmi', 'ब्राह्मी'),
    subtitle: LText('Bacopa monnieri', 'ब्राह्मी'),
    summary: LText('A small leafy herb long associated with the mind in Ayurveda.', 'आयुर्वेद में मन से जुड़ी एक छोटी पत्तेदार जड़ी-बूटी।'),
    readMinutes: 1,
    icon: Icons.psychology_rounded,
    color: AppColors.sage,
    sections: [
      ArticleSection(
        body: LText(
          'Brahmi grows in wet, marshy places and has a long history in traditional texts.',
          'ब्राह्मी नम, दलदली जगहों पर उगती है और पारंपरिक ग्रंथों में इसका लंबा इतिहास है।',
        ),
      ),
      ArticleSection(
        heading: Headings.traditional,
        body: LText(
          'Ayurveda has traditionally linked brahmi with memory and a calm mind. It is often found in herbal oils and supplements.',
          'आयुर्वेद में ब्राह्मी को पारंपरिक रूप से स्मृति और शांत मन से जोड़ा गया है। यह अक्सर हर्बल तेलों और सप्लीमेंट में मिलती है।',
        ),
      ),
      _herbNote,
    ],
  ),
  Article(
    id: 'herb_amla',
    category: _h,
    title: LText('Indian Gooseberry', 'आँवला'),
    subtitle: LText('Amla · Phyllanthus emblica', 'आँवला'),
    summary: LText('A sour green fruit enjoyed fresh, as murabba or pickle.', 'खट्टा हरा फल — ताज़ा, मुरब्बा या अचार के रूप में।'),
    readMinutes: 1,
    icon: Icons.circle_rounded,
    color: AppColors.mintDeep,
    youtubeQuery: 'amla murabba recipe',
    sections: [
      ArticleSection(
        body: LText(
          'Amla is a winter fruit and a key ingredient of the traditional preparation chyawanprash.',
          'आँवला सर्दियों का फल है और पारंपरिक च्यवनप्राश का मुख्य घटक है।',
        ),
      ),
      ArticleSection(
        heading: Headings.ways,
        body: LText('Ways to enjoy it:', 'इसके आनंद के तरीके:'),
        bullets: [
          LText('Fresh slices with a pinch of salt.', 'चुटकी भर नमक के साथ ताज़े टुकड़े।'),
          LText('Amla murabba or pickle.', 'आँवले का मुरब्बा या अचार।'),
          LText('Amla juice diluted with water.', 'पानी में मिलाकर आँवले का रस।'),
        ],
      ),
      _herbNote,
    ],
  ),
  Article(
    id: 'herb_elaichi',
    category: _h,
    title: LText('Cardamom', 'इलायची'),
    subtitle: LText('Elaichi · Elettaria cardamomum', 'इलायची'),
    summary: LText('The fragrant “queen of spices”.', 'सुगंधित “मसालों की रानी”।'),
    readMinutes: 1,
    icon: Icons.scatter_plot_rounded,
    color: AppColors.mint,
    sections: [
      ArticleSection(
        body: LText(
          'Green elaichi adds a sweet aroma to chai, kheer and many sweets.',
          'हरी इलायची चाय, खीर और कई मिठाइयों में मीठी खुशबू भरती है।',
        ),
      ),
      ArticleSection(
        heading: Headings.ways,
        body: LText('Everyday ideas:', 'रोज़ के तरीके:'),
        bullets: [
          LText('Crush a pod into your chai.', 'चाय में एक इलायची कूटकर डालें।'),
          LText('Chew a pod after meals as a natural mouth freshener.', 'भोजन के बाद प्राकृतिक माउथ फ्रेशनर के रूप में एक इलायची चबाएँ।'),
        ],
      ),
      _herbNote,
    ],
  ),
  Article(
    id: 'herb_saunf',
    category: _h,
    title: LText('Fennel Seeds', 'सौंफ'),
    subtitle: LText('Saunf · Foeniculum vulgare', 'सौंफ'),
    summary: LText('Sweet seeds traditionally enjoyed after meals.', 'मीठे बीज, पारंपरिक रूप से भोजन के बाद।'),
    readMinutes: 1,
    icon: Icons.grain_rounded,
    color: AppColors.sage,
    sections: [
      ArticleSection(
        body: LText(
          'A small bowl of saunf after a meal is a familiar sight in Indian homes and restaurants.',
          'भोजन के बाद सौंफ की कटोरी भारतीय घरों और रेस्तराँ में आम है।',
        ),
      ),
      ArticleSection(
        heading: Headings.ways,
        body: LText('Try:', 'आज़माएँ:'),
        bullets: [
          LText('Chew half a teaspoon after meals.', 'भोजन के बाद आधा चम्मच चबाएँ।'),
          LText('Saunf water: soak seeds overnight and sip in the morning.', 'सौंफ का पानी: रात भर भिगोकर सुबह पिएँ।'),
        ],
      ),
      _herbNote,
    ],
  ),
  Article(
    id: 'herb_chamomile',
    category: _h,
    title: LText('Chamomile', 'कैमोमाइल'),
    subtitle: LText('Babune ka phool', 'बबूने का फूल'),
    summary: LText('A gentle flower tea many enjoy in the evening.', 'फूलों की हल्की चाय जिसे बहुत लोग शाम को पीते हैं।'),
    readMinutes: 1,
    icon: Icons.filter_vintage_rounded,
    color: AppColors.sun,
    sections: [
      ArticleSection(
        body: LText(
          'Chamomile tea is caffeine-free and has a mild, honey-like flavour — a popular part of an evening wind-down.',
          'कैमोमाइल चाय कैफ़ीन-मुक्त होती है और इसका स्वाद हल्का, शहद जैसा होता है — शाम के आराम की लोकप्रिय आदत।',
        ),
      ),
      ArticleSection(
        heading: Headings.ways,
        body: LText('Make a cup:', 'एक कप बनाएँ:'),
        bullets: [
          LText('Steep 1 teaspoon of dried flowers (or a tea bag) for 5 minutes.', '1 चम्मच सूखे फूल (या टी बैग) 5 मिनट भिगोएँ।'),
          LText('Sip slowly, away from screens.', 'स्क्रीन से दूर, धीरे-धीरे पिएँ।'),
        ],
      ),
      _herbNote,
    ],
  ),
];

/// Better lifestyle habits.
const List<Article> lifestyleArticles = [
  Article(
    id: 'life_sunlight',
    category: _l,
    title: LText('Morning Sunlight', 'सुबह की धूप'),
    summary: LText('Step outside soon after waking for daylight and fresh air.', 'उठने के बाद जल्दी बाहर निकलें — धूप और ताज़ी हवा के लिए।'),
    readMinutes: 1,
    icon: Icons.wb_twilight_rounded,
    color: AppColors.sun,
    sections: [
      ArticleSection(
        body: LText(
          'Daylight in the morning helps set the body’s natural daily rhythm. Many people find it helps them feel awake.',
          'सुबह की रोशनी शरीर की प्राकृतिक दिनचर्या तय करने में मदद करती है। बहुत लोग इससे तरोताज़ा महसूस करते हैं।',
        ),
      ),
      ArticleSection(
        heading: Headings.tryThis,
        body: LText('Easy start:', 'आसान शुरुआत:'),
        bullets: [
          LText('Spend 10 minutes outside or by an open window.', '10 मिनट बाहर या खुली खिड़की के पास बिताएँ।'),
          LText('Combine it with a short walk or a few breaths.', 'इसे छोटी सैर या कुछ साँसों के साथ जोड़ें।'),
          LText('Never look directly at the sun.', 'सूरज की ओर सीधे कभी न देखें।'),
        ],
      ),
    ],
  ),
  Article(
    id: 'life_water',
    category: _l,
    title: LText('Drink Enough Water', 'पर्याप्त पानी पिएँ'),
    summary: LText('Simple ways to sip regularly through the day.', 'दिन भर नियमित पानी पीने के आसान तरीके।'),
    readMinutes: 1,
    icon: Icons.water_drop_rounded,
    color: AppColors.sky,
    sections: [
      ArticleSection(
        body: LText(
          'It’s easy to forget to drink when busy. Small habits make it automatic.',
          'व्यस्तता में पानी पीना भूल जाना आसान है। छोटी आदतें इसे अपने-आप करवा देती हैं।',
        ),
      ),
      ArticleSection(
        heading: Headings.tryThis,
        body: LText('Ideas:', 'सुझाव:'),
        bullets: [
          LText('Start the day with a glass of water.', 'दिन की शुरुआत एक गिलास पानी से करें।'),
          LText('Keep a bottle where you can see it.', 'बोतल ऐसी जगह रखें जहाँ दिखती रहे।'),
          LText('Drink a glass with each meal.', 'हर भोजन के साथ एक गिलास पिएँ।'),
        ],
      ),
    ],
  ),
  Article(
    id: 'life_sleep',
    category: _l,
    title: LText('A Calm Bedtime Routine', 'सोने की शांत दिनचर्या'),
    summary: LText('Habits that help the evening slow down.', 'शाम को धीमा करने वाली आदतें।'),
    readMinutes: 2,
    icon: Icons.bedtime_rounded,
    color: AppColors.lavender,
    sections: [
      ArticleSection(
        body: LText(
          'A regular wind-down tells your body that the day is ending.',
          'नियमित दिनचर्या शरीर को बताती है कि दिन खत्म हो रहा है।',
        ),
      ),
      ArticleSection(
        heading: Headings.tryThis,
        body: LText('Pick a few:', 'कुछ चुनें:'),
        bullets: [
          LText('Go to bed and wake up at similar times.', 'रोज़ लगभग एक ही समय पर सोएँ और उठें।'),
          LText('Dim the lights an hour before bed.', 'सोने से एक घंटा पहले रोशनी कम करें।'),
          LText('Avoid heavy meals and caffeine late in the day.', 'देर शाम भारी भोजन और कैफ़ीन से बचें।'),
          LText('Play soft music or try 4-7-8 breathing.', 'हल्का संगीत चलाएँ या 4-7-8 श्वास आज़माएँ।'),
        ],
      ),
      ArticleSection(
        heading: Headings.goodToKnow,
        body: LText(
          'If you often have trouble sleeping, it’s worth talking to a doctor.',
          'अगर अक्सर नींद में परेशानी होती है, तो डॉक्टर से बात करना अच्छा है।',
        ),
      ),
    ],
  ),
  Article(
    id: 'life_eating',
    category: _l,
    title: LText('Mindful Eating', 'सजग भोजन'),
    summary: LText('Slow down and actually taste your food.', 'धीमे खाएँ और भोजन का असली स्वाद लें।'),
    readMinutes: 1,
    icon: Icons.restaurant_rounded,
    color: AppColors.blush,
    sections: [
      ArticleSection(
        body: LText(
          'Eating with attention can make meals more enjoyable and satisfying.',
          'ध्यान से खाने से भोजन अधिक आनंददायक और संतोषजनक हो सकता है।',
        ),
      ),
      ArticleSection(
        heading: Headings.tryThis,
        body: LText('At your next meal:', 'अगले भोजन में:'),
        bullets: [
          LText('Take three slow breaths before you start.', 'शुरू करने से पहले तीन धीमी साँसें लें।'),
          LText('Put your spoon down between bites.', 'हर कौर के बीच चम्मच नीचे रखें।'),
          LText('Notice colours, smells and textures.', 'रंग, खुशबू और बनावट पर ध्यान दें।'),
          LText('Keep the phone away.', 'फ़ोन दूर रखें।'),
        ],
      ),
    ],
  ),
  Article(
    id: 'life_walk',
    category: _l,
    title: LText('A Walk After Meals', 'भोजन के बाद टहलना'),
    subtitle: LText('Shatapavali', 'शतपावली'),
    summary: LText('A short, easy stroll — an old habit worth keeping.', 'छोटी, आरामदायक सैर — एक पुरानी अच्छी आदत।'),
    readMinutes: 1,
    icon: Icons.directions_walk_rounded,
    color: AppColors.mintDeep,
    sections: [
      ArticleSection(
        body: LText(
          'Shatapavali — “a hundred steps” after a meal — is a traditional Indian habit. A relaxed 10-minute walk is plenty.',
          'शतपावली — भोजन के बाद “सौ कदम” — एक पारंपरिक भारतीय आदत है। आराम से 10 मिनट टहलना काफ़ी है।',
        ),
      ),
      ArticleSection(
        heading: Headings.tryThis,
        body: LText('Keep it gentle:', 'इसे हल्का रखें:'),
        bullets: [
          LText('Walk at an easy, chatting pace.', 'बातचीत करने लायक आरामदायक गति से चलें।'),
          LText('Try it after dinner with family.', 'रात के खाने के बाद परिवार के साथ आज़माएँ।'),
        ],
      ),
    ],
  ),
  Article(
    id: 'life_posture',
    category: _l,
    title: LText('Desk Breaks & Posture', 'डेस्क ब्रेक और मुद्रा'),
    summary: LText('Move a little every 30–60 minutes of sitting.', 'हर 30–60 मिनट बैठने के बाद थोड़ा हिलें-डुलें।'),
    readMinutes: 2,
    icon: Icons.chair_alt_rounded,
    color: AppColors.creamDeep,
    youtubeQuery: 'desk yoga stretches office',
    sections: [
      ArticleSection(
        body: LText(
          'Long hours at a desk can leave you stiff. Short breaks keep the body comfortable.',
          'डेस्क पर लंबे घंटे शरीर को अकड़ा सकते हैं। छोटे ब्रेक शरीर को आरामदायक रखते हैं।',
        ),
      ),
      ArticleSection(
        heading: Headings.tryThis,
        body: LText('A 2-minute break:', '2 मिनट का ब्रेक:'),
        bullets: [
          LText('Stand up and roll your shoulders back 5 times.', 'खड़े हों और कंधों को 5 बार पीछे घुमाएँ।'),
          LText('Gently turn your head left and right.', 'सिर को धीरे से बाएँ और दाएँ घुमाएँ।'),
          LText('Reach your arms overhead and take two deep breaths.', 'बाँहें ऊपर फैलाएँ और दो गहरी साँसें लें।'),
          LText('Keep your screen at eye level.', 'स्क्रीन को आँखों के स्तर पर रखें।'),
        ],
      ),
    ],
  ),
  Article(
    id: 'life_move',
    category: _l,
    title: LText('Move Every Day', 'रोज़ थोड़ा चलें-फिरें'),
    summary: LText('Find movement you enjoy — it all counts.', 'ऐसी गतिविधि चुनें जो आपको पसंद हो — सब गिना जाता है।'),
    readMinutes: 1,
    icon: Icons.directions_run_rounded,
    color: AppColors.sage,
    sections: [
      ArticleSection(
        body: LText(
          'Walking, dancing, yoga, gardening or playing with kids — regular movement is one of the simplest healthy habits.',
          'टहलना, नाचना, योग, बागवानी या बच्चों के साथ खेलना — नियमित गतिविधि सबसे आसान स्वस्थ आदतों में से एक है।',
        ),
      ),
      ArticleSection(
        heading: Headings.tryThis,
        body: LText('Start small:', 'छोटी शुरुआत करें:'),
        bullets: [
          LText('Take the stairs when you can.', 'जब हो सके सीढ़ियाँ लें।'),
          LText('Walk while on phone calls.', 'फ़ोन पर बात करते हुए टहलें।'),
          LText('Try 3 rounds of Sun Salutation in the morning.', 'सुबह सूर्य नमस्कार के 3 चक्र करें।'),
        ],
      ),
    ],
  ),
  Article(
    id: 'life_connect',
    category: _l,
    title: LText('Stay Connected', 'अपनों से जुड़े रहें'),
    summary: LText('Time with people you care about matters.', 'अपनों के साथ समय बिताना मायने रखता है।'),
    readMinutes: 1,
    icon: Icons.groups_rounded,
    color: AppColors.blush,
    sections: [
      ArticleSection(
        body: LText(
          'A call, a shared meal or a short walk with a friend can brighten the day for both of you.',
          'एक फ़ोन, साथ में भोजन या दोस्त के साथ छोटी सैर दोनों का दिन अच्छा बना सकती है।',
        ),
      ),
      ArticleSection(
        heading: Headings.tryThis,
        body: LText('This week:', 'इस हफ़्ते:'),
        bullets: [
          LText('Call someone you haven’t spoken to in a while.', 'किसी ऐसे व्यक्ति को फ़ोन करें जिनसे काफ़ी समय से बात नहीं हुई।'),
          LText('Share a meal without phones.', 'बिना फ़ोन के साथ में भोजन करें।'),
          LText('If you’re struggling, reach out to someone you trust or a professional.', 'अगर मुश्किल समय है, तो किसी भरोसेमंद व्यक्ति या विशेषज्ञ से बात करें।'),
        ],
      ),
    ],
  ),
];
