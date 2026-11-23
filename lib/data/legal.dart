import '../l10n/l_text.dart';

class InfoSection {
  const InfoSection(this.heading, this.body);

  final LText heading;
  final LText body;
}

const privacySections = [
  InfoSection(
    LText('Summary', 'सारांश'),
    LText(
      'BreatheCare is designed to work without an account. Your practice history, favorites and settings are stored only on your device unless you choose to create an account and back them up.',
      'BreatheCare बिना अकाउंट के काम करने के लिए बनाया गया है। आपका अभ्यास इतिहास, पसंदीदा और सेटिंग्स केवल आपके डिवाइस पर रहते हैं, जब तक आप खुद अकाउंट बनाकर उनका बैकअप नहीं लेते।',
    ),
  ),
  InfoSection(
    LText('Information stored on your device', 'आपके डिवाइस पर संग्रहीत जानकारी'),
    LText(
      'Breathing sessions (technique, date, duration), favorites, app settings, the number of days you have used the app, and any guidance audio you download.',
      'श्वास सत्र (तकनीक, तारीख, अवधि), पसंदीदा, ऐप सेटिंग्स, ऐप उपयोग के दिनों की संख्या, और आपके द्वारा डाउनलोड किया गया गाइडेंस ऑडियो।',
    ),
  ),
  InfoSection(
    LText('Mood selections', 'मूड चयन'),
    LText(
      'When you use Mood-Based Breathing, your selected mood is used only to show suggestions on screen. It is never saved, uploaded, or shared, and it is never used for advertising.',
      'मूड-आधारित श्वास में आपका चुना गया मूड केवल स्क्रीन पर सुझाव दिखाने के लिए उपयोग होता है। इसे कभी सेव, अपलोड या साझा नहीं किया जाता, और विज्ञापन के लिए कभी उपयोग नहीं होता।',
    ),
  ),
  InfoSection(
    LText('Optional account and backup', 'वैकल्पिक अकाउंट और बैकअप'),
    LText(
      'If you create an account, your User ID and a protected form of your PIN are handled by Google Firebase Authentication. When you tap Back up, your session history and favorites are stored in Google Cloud Firestore so you can restore them on another device. You can delete this data at any time with Delete My Data.',
      'अगर आप अकाउंट बनाते हैं, तो आपकी यूज़र आईडी और पिन का सुरक्षित रूप Google Firebase Authentication द्वारा संभाला जाता है। बैकअप दबाने पर आपका सत्र इतिहास और पसंदीदा Google Cloud Firestore में सहेजे जाते हैं ताकि आप उन्हें दूसरे डिवाइस पर वापस पा सकें। आप "मेरा डेटा हटाएँ" से इसे कभी भी हटा सकते हैं।',
    ),
  ),
  InfoSection(
    LText('Advertising', 'विज्ञापन'),
    LText(
      'BreatheCare is free and shows a small number of banner ads through Google AdMob. We request non-personalized ads only and never share your mood, wellness or practice information for ad targeting. Ads are never shown during breathing exercises or Emergency Calm Mode. Google may collect device identifiers and approximate location to deliver and measure ads, as described in Google’s privacy policy. Where required by law, you will be asked for consent and can change it in Settings.',
      'BreatheCare मुफ़्त है और Google AdMob के माध्यम से कुछ छोटे बैनर विज्ञापन दिखाता है। हम केवल गैर-व्यक्तिगत विज्ञापनों का अनुरोध करते हैं और आपका मूड, वेलनेस या अभ्यास जानकारी विज्ञापन लक्ष्यीकरण के लिए कभी साझा नहीं करते। श्वास अभ्यास या आपातकालीन शांत मोड के दौरान कभी विज्ञापन नहीं दिखाए जाते। विज्ञापन दिखाने और मापने के लिए Google डिवाइस पहचानकर्ता और अनुमानित स्थान एकत्र कर सकता है, जैसा कि Google की गोपनीयता नीति में बताया गया है। जहाँ कानूनन आवश्यक हो, आपसे सहमति माँगी जाएगी और आप इसे सेटिंग्स में बदल सकते हैं।',
    ),
  ),
  InfoSection(
    LText('Your choices', 'आपके विकल्प'),
    LText(
      'You can use every feature without an account, delete downloaded audio at any time, and remove all of your data from this device (and your cloud backup, if any) using Settings › Delete My Data.',
      'आप बिना अकाउंट के हर सुविधा का उपयोग कर सकते हैं, डाउनलोड किया ऑडियो कभी भी हटा सकते हैं, और सेटिंग्स › मेरा डेटा हटाएँ से इस डिवाइस का (और यदि हो तो क्लाउड बैकअप का) सारा डेटा हटा सकते हैं।',
    ),
  ),
  InfoSection(
    LText('Children', 'बच्चे'),
    LText(
      'BreatheCare is intended for a general audience and is not directed at children under 13.',
      'BreatheCare सामान्य उपयोगकर्ताओं के लिए है और 13 वर्ष से कम उम्र के बच्चों के लिए निर्देशित नहीं है।',
    ),
  ),
];

const termsSections = [
  InfoSection(
    LText('Wellness, not medical care', 'वेलनेस, चिकित्सा देखभाल नहीं'),
    LText(
      'BreatheCare provides general relaxation and breathing exercises for everyday wellbeing. It is not a medical device and does not diagnose, treat, cure or prevent any disease or condition. It is not a substitute for professional medical advice.',
      'BreatheCare रोज़मर्रा की भलाई के लिए सामान्य विश्राम और श्वास अभ्यास प्रदान करता है। यह कोई चिकित्सा उपकरण नहीं है और किसी रोग या स्थिति का निदान, उपचार, इलाज या रोकथाम नहीं करता। यह पेशेवर चिकित्सा सलाह का विकल्प नहीं है।',
    ),
  ),
  InfoSection(
    LText('Emergencies', 'आपात स्थिति'),
    LText(
      'Emergency Calm Mode is a relaxation feature only. If you experience severe breathing difficulty, chest pain, fainting or any other serious symptom, contact your local emergency number or seek urgent medical help immediately.',
      'आपातकालीन शांत मोड केवल एक विश्राम सुविधा है। अगर आपको साँस लेने में गंभीर कठिनाई, सीने में दर्द, बेहोशी या कोई अन्य गंभीर लक्षण हो, तो तुरंत अपने स्थानीय आपातकालीन नंबर पर संपर्क करें या चिकित्सा सहायता लें।',
    ),
  ),
  InfoSection(
    LText('Practice safely', 'सुरक्षित अभ्यास करें'),
    LText(
      'Breathe at a comfortable pace and stop whenever you wish. Breath holds are always optional. Consult a doctor before starting if you have a heart or lung condition, are pregnant, or have other health concerns. Do not practice while driving or operating machinery.',
      'आरामदायक गति से साँस लें और जब चाहें रुक जाएँ। साँस रोकना हमेशा वैकल्पिक है। अगर आपको हृदय या फेफड़ों की समस्या है, आप गर्भवती हैं, या स्वास्थ्य संबंधी अन्य चिंताएँ हैं, तो शुरू करने से पहले डॉक्टर से सलाह लें। गाड़ी चलाते या मशीन चलाते समय अभ्यास न करें।',
    ),
  ),
  InfoSection(
    LText('Your account', 'आपका अकाउंट'),
    LText(
      'Accounts are optional. Keep your User ID and PIN private. Because no e-mail address is collected, a forgotten PIN cannot be recovered.',
      'अकाउंट वैकल्पिक है। अपनी यूज़र आईडी और पिन गोपनीय रखें। चूँकि कोई ईमेल पता नहीं लिया जाता, भूला हुआ पिन वापस नहीं पाया जा सकता।',
    ),
  ),
  InfoSection(
    LText('The service', 'सेवा'),
    LText(
      'BreatheCare is provided free of charge, supported by advertising, on an “as is” basis. Features may change over time. By using the app you agree to these terms.',
      'BreatheCare विज्ञापनों द्वारा समर्थित, निःशुल्क और "जैसा है" के आधार पर प्रदान किया जाता है। सुविधाएँ समय के साथ बदल सकती हैं। ऐप का उपयोग करके आप इन शर्तों से सहमत होते हैं।',
    ),
  ),
];

const aboutSections = [
  InfoSection(
    LText('Your peaceful breathing companion', 'आपका शांत श्वास साथी'),
    LText(
      'BreatheCare helps you take calm, mindful pauses through simple guided breathing. Choose how you feel, pick a technique, follow the gentle animation, complete daily challenges and watch your healthy habit grow.',
      'BreatheCare सरल निर्देशित श्वास के ज़रिए शांत और सजग ठहराव लेने में आपकी मदद करता है। चुनें कि आप कैसा महसूस कर रहे हैं, एक तकनीक चुनें, कोमल एनिमेशन का अनुसरण करें, दैनिक चैलेंज पूरे करें और अपनी स्वस्थ आदत को बढ़ते देखें।',
    ),
  ),
  InfoSection(
    LText('Made for everyone', 'सभी के लिए'),
    LText(
      'Free to use, beginner-friendly, available in English and Hindi, and fully usable offline. No account required.',
      'उपयोग में मुफ़्त, शुरुआती लोगों के अनुकूल, अंग्रेज़ी और हिन्दी में उपलब्ध, और पूरी तरह ऑफ़लाइन उपयोग योग्य। किसी अकाउंट की ज़रूरत नहीं।',
    ),
  ),
  InfoSection(
    LText('A gentle reminder', 'एक कोमल याद'),
    LText(
      'BreatheCare supports relaxation and everyday wellbeing. It does not replace medical care. Always listen to your body.',
      'BreatheCare विश्राम और रोज़मर्रा की भलाई में सहायक है। यह चिकित्सा देखभाल का विकल्प नहीं है। हमेशा अपने शरीर की सुनें।',
    ),
  ),
];
