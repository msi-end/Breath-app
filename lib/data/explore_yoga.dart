import 'package:flutter/material.dart';

import '../l10n/l_text.dart';
import '../models/article.dart';
import '../theme/app_colors.dart';

const _cat = ExploreCategory.yoga;

const _listen = ArticleSection(
  heading: Headings.gently,
  body: LText(
    'Move slowly and only as far as feels comfortable — never into pain. Skip any pose that doesn’t suit your body, and check with a doctor first if you are pregnant, injured or have a health condition.',
    'धीरे चलें और उतना ही करें जितना आरामदायक लगे — दर्द तक कभी नहीं। जो आसन आपके शरीर के अनुकूल न हो उसे छोड़ दें, और गर्भावस्था, चोट या किसी स्वास्थ्य समस्या में पहले डॉक्टर से सलाह लें।',
  ),
);

const List<Article> yogaArticles = [
  Article(
    id: 'yoga_tadasana',
    category: _cat,
    title: LText('Mountain Pose', 'पर्वत आसन'),
    subtitle: LText('Tadasana', 'ताड़ासन'),
    summary: LText('Stand tall, steady and grounded — the base of many poses.', 'सीधे, स्थिर और ज़मीन से जुड़े खड़े हों — कई आसनों का आधार।'),
    readMinutes: 2,
    icon: Icons.landscape_rounded,
    color: AppColors.sage,
    youtubeQuery: 'Tadasana mountain pose yoga for beginners',
    sections: [
      ArticleSection(
        body: LText(
          'Tadasana looks simple, but it teaches you to stand with balance and ease. Many people use it to begin or end a practice.',
          'ताड़ासन सरल दिखता है, पर यह संतुलन और सहजता से खड़े होना सिखाता है। बहुत से लोग अभ्यास की शुरुआत या अंत इससे करते हैं।',
        ),
      ),
      ArticleSection(
        heading: Headings.how,
        body: LText('Take about a minute:', 'लगभग एक मिनट लें:'),
        bullets: [
          LText('Stand with feet together or hip-width apart.', 'पैरों को साथ या कूल्हों जितनी दूरी पर रखकर खड़े हों।'),
          LText('Spread your weight evenly through both feet.', 'वज़न दोनों पैरों पर बराबर बाँटें।'),
          LText('Lengthen your spine and relax your shoulders down.', 'रीढ़ लंबी करें और कंधों को ढीला छोड़ें।'),
          LText('Arms rest by your sides, or raise them overhead.', 'बाँहें बगल में रखें, या ऊपर उठाएँ।'),
          LText('Breathe slowly for 5–8 breaths.', '5–8 धीमी साँसें लें।'),
        ],
      ),
      ArticleSection(
        heading: Headings.why,
        body: LText('People often say it helps them:', 'लोग अक्सर कहते हैं कि इससे उन्हें:'),
        bullets: [
          LText('Notice and improve their posture', 'अपनी मुद्रा पर ध्यान देने में मदद मिलती है'),
          LText('Feel steady and present', 'स्थिर और वर्तमान में महसूस होता है'),
        ],
      ),
      _listen,
    ],
  ),
  Article(
    id: 'yoga_vrikshasana',
    category: _cat,
    title: LText('Tree Pose', 'वृक्ष आसन'),
    subtitle: LText('Vrikshasana', 'वृक्षासन'),
    summary: LText('A calm balancing pose that invites focus.', 'एक शांत संतुलन आसन जो एकाग्रता बढ़ाता है।'),
    readMinutes: 2,
    icon: Icons.park_rounded,
    color: AppColors.mintDeep,
    youtubeQuery: 'Vrikshasana tree pose yoga steps',
    sections: [
      ArticleSection(
        body: LText(
          'Balancing on one leg asks for quiet attention. A wobble is normal — it’s part of the practice.',
          'एक पैर पर संतुलन के लिए शांत ध्यान चाहिए। डगमगाना सामान्य है — यह अभ्यास का हिस्सा है।',
        ),
      ),
      ArticleSection(
        heading: Headings.how,
        body: LText('Stand near a wall if you like:', 'चाहें तो दीवार के पास खड़े हों:'),
        bullets: [
          LText('Shift your weight onto your left foot.', 'वज़न बाएँ पैर पर ले जाएँ।'),
          LText('Place your right sole on your ankle, calf or inner thigh — never on the knee.', 'दाएँ तलवे को टखने, पिंडली या जाँघ के अंदर रखें — घुटने पर कभी नहीं।'),
          LText('Bring palms together at your chest.', 'हथेलियों को छाती के सामने जोड़ें।'),
          LText('Rest your gaze on one still point.', 'नज़र किसी एक स्थिर बिंदु पर टिकाएँ।'),
          LText('Hold for 5 breaths, then switch sides.', '5 साँसों तक रुकें, फिर पैर बदलें।'),
        ],
      ),
      ArticleSection(
        heading: Headings.why,
        body: LText('Many people enjoy it for:', 'बहुत से लोग इसे पसंद करते हैं क्योंकि:'),
        bullets: [
          LText('Practicing balance and focus', 'संतुलन और एकाग्रता का अभ्यास होता है'),
          LText('A feeling of standing strong and calm', 'मज़बूत और शांत खड़े होने का एहसास होता है'),
        ],
      ),
      _listen,
    ],
  ),
  Article(
    id: 'yoga_balasana',
    category: _cat,
    title: LText('Child’s Pose', 'बालासन'),
    subtitle: LText('Balasana', 'बालासन'),
    summary: LText('A restful pose to pause and breathe into your back.', 'रुककर पीठ में साँस भरने का एक आरामदायक आसन।'),
    readMinutes: 2,
    icon: Icons.child_care_rounded,
    color: AppColors.blush,
    youtubeQuery: 'Balasana child pose yoga how to',
    sections: [
      ArticleSection(
        body: LText(
          'Child’s Pose is a resting shape you can return to any time during practice.',
          'बालासन एक विश्राम मुद्रा है जिसमें अभ्यास के दौरान कभी भी लौट सकते हैं।',
        ),
      ),
      ArticleSection(
        heading: Headings.how,
        body: LText('On a mat or soft surface:', 'मैट या नरम सतह पर:'),
        bullets: [
          LText('Kneel and sit back towards your heels.', 'घुटनों के बल बैठें और एड़ियों की ओर पीछे बैठें।'),
          LText('Fold forward and rest your forehead down (use a cushion if needed).', 'आगे झुकें और माथा नीचे टिकाएँ (ज़रूरत हो तो तकिया रखें)।'),
          LText('Stretch arms forward or rest them by your sides.', 'बाँहें आगे फैलाएँ या बगल में रखें।'),
          LText('Breathe slowly into your back for 1–2 minutes.', '1–2 मिनट पीठ में धीमी साँस भरें।'),
        ],
      ),
      ArticleSection(
        heading: Headings.why,
        body: LText('People often describe it as:', 'लोग अक्सर इसे ऐसा बताते हैं:'),
        bullets: [
          LText('A gentle stretch for the back and hips', 'पीठ और कूल्हों के लिए हल्का खिंचाव'),
          LText('A cosy, calming pause', 'एक सुकून भरा, शांत ठहराव'),
        ],
      ),
      _listen,
    ],
  ),
  Article(
    id: 'yoga_catcow',
    category: _cat,
    title: LText('Cat–Cow Stretch', 'मार्जरी–बिटिला आसन'),
    subtitle: LText('Marjaryasana–Bitilasana', 'मार्जरी आसन'),
    summary: LText('Flowing spine movement linked with your breath.', 'साँस के साथ जुड़ी रीढ़ की लयबद्ध गति।'),
    readMinutes: 2,
    icon: Icons.pets_rounded,
    color: AppColors.sun,
    youtubeQuery: 'cat cow stretch marjaryasana bitilasana',
    sections: [
      ArticleSection(
        body: LText(
          'A simple flow that moves the spine gently, with each movement matched to a breath.',
          'एक सरल प्रवाह जो रीढ़ को कोमलता से चलाता है, हर गति एक साँस से जुड़ी।',
        ),
      ),
      ArticleSection(
        heading: Headings.how,
        body: LText('On hands and knees:', 'हाथों और घुटनों के बल:'),
        bullets: [
          LText('Hands under shoulders, knees under hips.', 'हाथ कंधों के नीचे, घुटने कूल्हों के नीचे।'),
          LText('Breathe in: let the belly lower and look slightly up (Cow).', 'साँस लें: पेट नीचे जाने दें और थोड़ा ऊपर देखें (गाय)।'),
          LText('Breathe out: round your back and tuck your chin (Cat).', 'साँस छोड़ें: पीठ गोल करें और ठुड्डी अंदर लें (बिल्ली)।'),
          LText('Repeat slowly 6–10 times.', 'धीरे-धीरे 6–10 बार दोहराएँ।'),
        ],
      ),
      ArticleSection(
        heading: Headings.why,
        body: LText('A favourite for:', 'इसे पसंद किया जाता है:'),
        bullets: [
          LText('Loosening up after sitting for long', 'लंबे समय बैठने के बाद शरीर खोलने के लिए'),
          LText('Practicing breath and movement together', 'साँस और गति को साथ जोड़ने के लिए'),
        ],
      ),
      _listen,
    ],
  ),
  Article(
    id: 'yoga_bhujangasana',
    category: _cat,
    title: LText('Cobra Pose', 'भुजंग आसन'),
    subtitle: LText('Bhujangasana', 'भुजंगासन'),
    summary: LText('A gentle backbend that opens the chest.', 'छाती खोलने वाला हल्का पीछे का झुकाव।'),
    readMinutes: 2,
    icon: Icons.waves_rounded,
    color: AppColors.sky,
    youtubeQuery: 'Bhujangasana cobra pose for beginners',
    sections: [
      ArticleSection(
        body: LText(
          'Keep it low and easy — a small, comfortable lift is plenty.',
          'इसे नीचे और आसान रखें — छोटा, आरामदायक उठाव ही काफ़ी है।',
        ),
      ),
      ArticleSection(
        heading: Headings.how,
        body: LText('Lying on your front:', 'पेट के बल लेटकर:'),
        bullets: [
          LText('Place hands under your shoulders, elbows close to the body.', 'हाथ कंधों के नीचे रखें, कोहनियाँ शरीर के पास।'),
          LText('Press the tops of your feet down.', 'पैरों के ऊपरी हिस्से को ज़मीन पर दबाएँ।'),
          LText('Breathe in and gently lift your chest a little.', 'साँस लेते हुए छाती को थोड़ा ऊपर उठाएँ।'),
          LText('Keep shoulders relaxed; hold 3–5 breaths, then lower.', 'कंधे ढीले रखें; 3–5 साँसें रुकें, फिर नीचे आएँ।'),
        ],
      ),
      ArticleSection(
        heading: Headings.why,
        body: LText('People enjoy it as:', 'लोग इसे पसंद करते हैं:'),
        bullets: [
          LText('A counter-stretch to slouching', 'झुककर बैठने के उलट खिंचाव के रूप में'),
          LText('A way to feel more open in the chest', 'छाती में खुलापन महसूस करने के लिए'),
        ],
      ),
      _listen,
    ],
  ),
  Article(
    id: 'yoga_downdog',
    category: _cat,
    title: LText('Downward-Facing Dog', 'अधोमुख श्वान आसन'),
    subtitle: LText('Adho Mukha Svanasana', 'अधोमुख श्वानासन'),
    summary: LText('A full-body stretch for arms, back and legs.', 'बाँहों, पीठ और पैरों का पूरा खिंचाव।'),
    readMinutes: 2,
    icon: Icons.change_history_rounded,
    color: AppColors.lavender,
    youtubeQuery: 'Adho Mukha Svanasana downward dog beginners',
    sections: [
      ArticleSection(
        body: LText(
          'Your body makes an upside-down “V”. Bent knees are perfectly fine.',
          'शरीर उल्टे “V” का आकार बनाता है। घुटने मुड़े रहें तो भी बिल्कुल ठीक है।',
        ),
      ),
      ArticleSection(
        heading: Headings.how,
        body: LText('From hands and knees:', 'हाथों और घुटनों के बल से:'),
        bullets: [
          LText('Tuck your toes and lift your hips up and back.', 'पंजे मोड़ें और कूल्हों को ऊपर-पीछे उठाएँ।'),
          LText('Spread your fingers and press through your palms.', 'उँगलियाँ फैलाएँ और हथेलियों से दबाएँ।'),
          LText('Let your head hang loosely between your arms.', 'सिर को बाँहों के बीच ढीला छोड़ दें।'),
          LText('Bend your knees as much as you need; hold 5 breaths.', 'जितनी ज़रूरत हो घुटने मोड़ें; 5 साँसें रुकें।'),
        ],
      ),
      ArticleSection(
        heading: Headings.why,
        body: LText('A popular pose for:', 'यह लोकप्रिय है:'),
        bullets: [
          LText('Stretching the back of the legs', 'पैरों के पिछले हिस्से के खिंचाव के लिए'),
          LText('Feeling energised and awake', 'ऊर्जावान और तरोताज़ा महसूस करने के लिए'),
        ],
      ),
      _listen,
    ],
  ),
  Article(
    id: 'yoga_setubandha',
    category: _cat,
    title: LText('Bridge Pose', 'सेतु बंध आसन'),
    subtitle: LText('Setu Bandhasana', 'सेतुबंधासन'),
    summary: LText('Lift your hips gently to open the front of the body.', 'शरीर के अगले हिस्से को खोलने के लिए कूल्हे धीरे से उठाएँ।'),
    readMinutes: 2,
    icon: Icons.architecture_rounded,
    color: AppColors.mint,
    youtubeQuery: 'Setu Bandhasana bridge pose yoga steps',
    sections: [
      ArticleSection(
        body: LText(
          'A friendly backbend done lying down, easy to adjust to your comfort.',
          'लेटकर किया जाने वाला सरल आसन, जिसे अपनी सहजता के अनुसार बदला जा सकता है।',
        ),
      ),
      ArticleSection(
        heading: Headings.how,
        body: LText('Lying on your back:', 'पीठ के बल लेटकर:'),
        bullets: [
          LText('Bend your knees, feet flat and hip-width apart.', 'घुटने मोड़ें, पैर ज़मीन पर कूल्हों जितनी दूरी पर।'),
          LText('Breathe in and slowly lift your hips.', 'साँस लेते हुए धीरे से कूल्हे उठाएँ।'),
          LText('Keep your neck relaxed and still.', 'गर्दन को ढीला और स्थिर रखें।'),
          LText('Hold 3–5 breaths, then roll down slowly.', '3–5 साँसें रुकें, फिर धीरे-धीरे नीचे आएँ।'),
        ],
      ),
      ArticleSection(
        heading: Headings.why,
        body: LText('People like it for:', 'लोग इसे पसंद करते हैं:'),
        bullets: [
          LText('Waking up the legs and hips', 'पैरों और कूल्हों को सक्रिय करने के लिए'),
          LText('A gentle opening for the chest', 'छाती के हल्के खुलाव के लिए'),
        ],
      ),
      _listen,
    ],
  ),
  Article(
    id: 'yoga_paschimottanasana',
    category: _cat,
    title: LText('Seated Forward Bend', 'बैठकर आगे झुकना'),
    subtitle: LText('Paschimottanasana', 'पश्चिमोत्तानासन'),
    summary: LText('A quiet, inward stretch for the back body.', 'शरीर के पिछले हिस्से के लिए शांत खिंचाव।'),
    readMinutes: 2,
    icon: Icons.airline_seat_legroom_extra_rounded,
    color: AppColors.creamDeep,
    youtubeQuery: 'Paschimottanasana seated forward bend beginners',
    sections: [
      ArticleSection(
        body: LText(
          'Reaching your toes is not the goal. A long spine and easy breath matter more.',
          'पंजों को छूना लक्ष्य नहीं है। लंबी रीढ़ और सहज साँस ज़्यादा ज़रूरी हैं।',
        ),
      ),
      ArticleSection(
        heading: Headings.how,
        body: LText('Sitting on the floor:', 'ज़मीन पर बैठकर:'),
        bullets: [
          LText('Stretch your legs forward; bend the knees if needed.', 'पैर आगे फैलाएँ; ज़रूरत हो तो घुटने मोड़ें।'),
          LText('Breathe in and sit tall.', 'साँस लें और सीधे बैठें।'),
          LText('Breathe out and fold forward from the hips.', 'साँस छोड़ते हुए कूल्हों से आगे झुकें।'),
          LText('Rest your hands wherever they reach; stay for 5–8 breaths.', 'हाथ जहाँ तक पहुँचें वहीं रखें; 5–8 साँसें रुकें।'),
        ],
      ),
      ArticleSection(
        heading: Headings.why,
        body: LText('Often enjoyed:', 'अक्सर पसंद किया जाता है:'),
        bullets: [
          LText('In the evening, to wind down', 'शाम को आराम के लिए'),
          LText('As a stretch for the back and hamstrings', 'पीठ और जाँघों के पिछले हिस्से के खिंचाव के लिए'),
        ],
      ),
      _listen,
    ],
  ),
  Article(
    id: 'yoga_viparitakarani',
    category: _cat,
    title: LText('Legs Up the Wall', 'दीवार पर पैर'),
    subtitle: LText('Viparita Karani', 'विपरीत करणी'),
    summary: LText('A deeply restful pose for tired legs.', 'थके पैरों के लिए बहुत आरामदायक आसन।'),
    readMinutes: 2,
    icon: Icons.vertical_align_top_rounded,
    color: AppColors.skyDeep,
    youtubeQuery: 'Viparita Karani legs up the wall pose',
    sections: [
      ArticleSection(
        body: LText(
          'A restorative pose — you simply rest with your legs supported by a wall.',
          'एक विश्राम आसन — बस दीवार के सहारे पैर टिकाकर आराम करें।',
        ),
      ),
      ArticleSection(
        heading: Headings.how,
        body: LText('Near a wall:', 'दीवार के पास:'),
        bullets: [
          LText('Sit sideways next to the wall.', 'दीवार के बगल में तिरछे बैठें।'),
          LText('Lie back and swing your legs up the wall.', 'पीछे लेटें और पैरों को दीवार पर ऊपर ले जाएँ।'),
          LText('Rest your arms by your sides, palms up.', 'बाँहें बगल में रखें, हथेलियाँ ऊपर।'),
          LText('Breathe slowly for 3–5 minutes.', '3–5 मिनट धीमी साँस लें।'),
        ],
      ),
      ArticleSection(
        heading: Headings.why,
        body: LText('People reach for it:', 'लोग इसे करते हैं:'),
        bullets: [
          LText('After a long day on their feet', 'दिन भर खड़े रहने के बाद'),
          LText('Before bed, as a calm pause', 'सोने से पहले शांत ठहराव के लिए'),
        ],
      ),
      _listen,
    ],
  ),
  Article(
    id: 'yoga_vajrasana',
    category: _cat,
    title: LText('Thunderbolt Pose', 'वज्र आसन'),
    subtitle: LText('Vajrasana', 'वज्रासन'),
    summary: LText('A kneeling seat traditionally practiced after meals.', 'घुटनों के बल बैठने का आसन, पारंपरिक रूप से भोजन के बाद।'),
    readMinutes: 2,
    icon: Icons.bolt_rounded,
    color: AppColors.sun,
    youtubeQuery: 'Vajrasana how to sit correctly',
    sections: [
      ArticleSection(
        body: LText(
          'Vajrasana is one of the few poses traditionally done right after eating, for a few calm minutes.',
          'वज्रासन उन कुछ आसनों में से है जो पारंपरिक रूप से भोजन के ठीक बाद कुछ शांत मिनटों के लिए किए जाते हैं।',
        ),
      ),
      ArticleSection(
        heading: Headings.how,
        body: LText('On a soft mat:', 'नरम मैट पर:'),
        bullets: [
          LText('Kneel with knees together.', 'घुटनों को साथ रखकर बैठें।'),
          LText('Sit back on your heels; a cushion between heels and hips helps.', 'एड़ियों पर बैठें; एड़ियों और कूल्हों के बीच तकिया मदद करता है।'),
          LText('Rest hands on your thighs and sit tall.', 'हाथ जाँघों पर रखें और सीधे बैठें।'),
          LText('Breathe slowly for 2–5 minutes.', '2–5 मिनट धीमी साँस लें।'),
        ],
      ),
      ArticleSection(
        heading: Headings.why,
        body: LText('Liked for:', 'इसे पसंद किया जाता है:'),
        bullets: [
          LText('A steady seat for breathing practice', 'श्वास अभ्यास के लिए स्थिर आसन के रूप में'),
          LText('A calm pause after meals', 'भोजन के बाद शांत ठहराव के लिए'),
        ],
      ),
      ArticleSection(
        heading: Headings.gently,
        body: LText(
          'Skip this pose if your knees or ankles hurt. Use plenty of padding and come out slowly.',
          'घुटनों या टखनों में दर्द हो तो यह आसन न करें। पर्याप्त गद्दी रखें और धीरे से बाहर आएँ।',
        ),
      ),
    ],
  ),
  Article(
    id: 'yoga_shavasana',
    category: _cat,
    title: LText('Relaxation Pose', 'शव आसन'),
    subtitle: LText('Shavasana', 'शवासन'),
    summary: LText('Lie still and let your whole body rest.', 'स्थिर लेटें और पूरे शरीर को आराम दें।'),
    readMinutes: 2,
    icon: Icons.airline_seat_flat_rounded,
    color: AppColors.lavender,
    youtubeQuery: 'Shavasana guided relaxation',
    sections: [
      ArticleSection(
        body: LText(
          'Usually practiced at the end of a session, Shavasana is simply resting with awareness.',
          'आम तौर पर अभ्यास के अंत में किया जाने वाला शवासन, जागरूकता के साथ आराम करना है।',
        ),
      ),
      ArticleSection(
        heading: Headings.how,
        body: LText('Lying on your back:', 'पीठ के बल लेटकर:'),
        bullets: [
          LText('Let your legs and arms fall open comfortably.', 'पैरों और बाँहों को आराम से फैलने दें।'),
          LText('Close your eyes and soften your face.', 'आँखें बंद करें और चेहरे को ढीला छोड़ें।'),
          LText('Let your breath be natural.', 'साँस को स्वाभाविक चलने दें।'),
          LText('Rest for 3–10 minutes, then roll to one side to get up.', '3–10 मिनट आराम करें, फिर करवट लेकर उठें।'),
        ],
      ),
      ArticleSection(
        heading: Headings.why,
        body: LText('People say it helps them:', 'लोग कहते हैं कि इससे:'),
        bullets: [
          LText('Feel rested after movement', 'हलचल के बाद आराम महसूस होता है'),
          LText('Practice letting go', 'छोड़ देने का अभ्यास होता है'),
        ],
      ),
      _listen,
    ],
  ),
  Article(
    id: 'yoga_suryanamaskar',
    category: _cat,
    title: LText('Sun Salutation', 'सूर्य नमस्कार'),
    subtitle: LText('Surya Namaskar', 'सूर्य नमस्कार'),
    summary: LText('A flowing sequence of 12 steps, often done in the morning.', '12 चरणों का प्रवाह, अक्सर सुबह किया जाता है।'),
    readMinutes: 3,
    icon: Icons.wb_sunny_rounded,
    color: AppColors.sun,
    youtubeQuery: 'Surya Namaskar step by step for beginners',
    sections: [
      ArticleSection(
        body: LText(
          'Surya Namaskar links several poses into one smooth flow, each step matched with a breath. Watching a video first makes the sequence easy to follow.',
          'सूर्य नमस्कार कई आसनों को एक सहज प्रवाह में जोड़ता है, हर चरण एक साँस के साथ। पहले वीडियो देख लेने से क्रम समझना आसान हो जाता है।',
        ),
      ),
      ArticleSection(
        heading: Headings.how,
        body: LText('The basic flow:', 'मूल क्रम:'),
        bullets: [
          LText('Prayer pose → arms up → forward fold.', 'प्रणाम आसन → हाथ ऊपर → आगे झुकना।'),
          LText('Step back into a lunge → plank → knees-chest-chin (or knees down).', 'पीछे कदम लेकर अश्व संचालन → प्लैंक → घुटने-छाती-ठुड्डी (या घुटने नीचे)।'),
          LText('Cobra → downward dog.', 'भुजंगासन → अधोमुख श्वानासन।'),
          LText('Lunge → forward fold → arms up → prayer pose.', 'अश्व संचालन → आगे झुकना → हाथ ऊपर → प्रणाम आसन।'),
          LText('Start with 2–3 slow rounds.', '2–3 धीमे चक्रों से शुरू करें।'),
        ],
      ),
      ArticleSection(
        heading: Headings.why,
        body: LText('A morning favourite because it:', 'यह सुबह इसलिए पसंद किया जाता है क्योंकि:'),
        bullets: [
          LText('Moves the whole body in a few minutes', 'कुछ ही मिनटों में पूरे शरीर को चलाता है'),
          LText('Builds a steady rhythm of breath and movement', 'साँस और गति की स्थिर लय बनाता है'),
        ],
      ),
      _listen,
    ],
  ),
];
