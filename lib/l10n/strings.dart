import 'package:flutter/widgets.dart';

import '../data/challenges.dart';
import '../models/breath_pattern.dart';
import '../models/technique.dart';
import '../services/account_service.dart';
import '../services/audio_download_service.dart';
import '../services/challenge_service.dart';

/// All UI strings in English and Hindi. Each entry carries both languages,
/// so a translation can never be missing.
class AppStrings {
  const AppStrings(this.lang);

  final String lang;

  bool get _hi => lang == 'hi';
  String _t(String en, String hi) => _hi ? hi : en;

  // Navigation
  String get tabHome => _t('Home', 'होम');
  String get tabLearn => _t('Learn', 'सीखें');
  String get tabProgress => _t('Progress', 'प्रगति');
  String get tabSettings => _t('Settings', 'सेटिंग्स');

  // Home
  String get goodMorning => _t('Good morning', 'सुप्रभात');
  String get goodAfternoon => _t('Good afternoon', 'नमस्कार');
  String get goodEvening => _t('Good evening', 'शुभ संध्या');
  String get welcomeTitle => _t('Welcome back', 'फिर से स्वागत है');
  String get welcomeSubtitle =>
      _t('Take a slow breath. This moment is just for you.', 'एक धीमी साँस लें। यह पल सिर्फ़ आपके लिए है।');
  String get todaysBreathing => _t('Today’s breathing', 'आज की श्वास');
  String get noPracticeToday => _t(
    'No practice yet today — a few calm minutes is all it takes.',
    'आज अभी अभ्यास नहीं हुआ — बस कुछ शांत मिनट काफ़ी हैं।',
  );
  String practicedToday(String d) => _t('You’ve practiced $d today. Lovely!', 'आज आपने $d अभ्यास किया। बहुत बढ़िया!');
  String get startBreathing => _t('Start Breathing', 'श्वास शुरू करें');
  String get emergencyCalm => _t('Emergency Calm Mode', 'आपातकालीन शांत मोड');
  String get emergencyCalmSubtitle =>
      _t('Feeling overwhelmed? Start gentle breathing instantly.', 'घबराहट हो रही है? तुरंत कोमल श्वास शुरू करें।');
  String get explore => _t('Explore', 'खोजें');
  String get exploreTechniques => _t('Explore Techniques', 'तकनीकें देखें');
  String get exploreTechniquesSub => _t('10 guided breathing exercises', '10 निर्देशित श्वास अभ्यास');
  String get moodBreathing => _t('Mood-Based Breathing', 'मूड-आधारित श्वास');
  String get moodBreathingSub => _t('Breathing that fits how you feel', 'आपके मूड के अनुसार श्वास');
  String get dailyChallenge => _t('Daily Challenge', 'दैनिक चैलेंज');
  String get dailyChallengeSub => _t('A small goal for today', 'आज का छोटा लक्ष्य');
  String get favorites => _t('Favorites', 'पसंदीदा');
  String get favoritesSub => _t('Your saved techniques', 'आपकी सेव की गई तकनीकें');
  String get viewAll => _t('View all', 'सभी देखें');
  String get viewProgress => _t('View progress', 'प्रगति देखें');
  String get recentlyPracticed => _t('Recently practiced', 'हाल ही में किए गए');
  String get noRecent => _t(
    'Techniques you practice will appear here for quick access.',
    'आपके द्वारा की गई तकनीकें जल्दी पहुँच के लिए यहाँ दिखेंगी।',
  );
  String get thisWeek => _t('This week', 'इस सप्ताह');
  String get minutesThisWeek => _t('this week', 'इस सप्ताह');
  String get activeDays => _t('active days', 'सक्रिय दिन');
  String get dayStreak => _t('day streak', 'दिन की स्ट्रीक');
  String get weekEmpty =>
      _t('Your weekly breathing activity will grow here.', 'आपकी साप्ताहिक श्वास गतिविधि यहाँ दिखेगी।');

  // Techniques
  String get breathingTechniques => _t('Breathing Techniques', 'श्वास तकनीकें');
  String get techniquesIntro => _t(
    'Choose a technique to learn how it works, then start a guided session.',
    'कोई तकनीक चुनें, जानें यह कैसे काम करती है, फिर निर्देशित सत्र शुरू करें।',
  );
  String get all => _t('All', 'सभी');
  String tagLabel(TechniqueTag tag) => switch (tag) {
    TechniqueTag.beginner => _t('Beginner', 'शुरुआती'),
    TechniqueTag.relax => _t('Relax', 'विश्राम'),
    TechniqueTag.focus => _t('Focus', 'एकाग्रता'),
    TechniqueTag.calm => _t('Calm', 'शांति'),
    TechniqueTag.balance => _t('Balance', 'संतुलन'),
  };
  String get beginnerFriendly => _t('Beginner-friendly', 'शुरुआती के लिए');
  String minutesCount(int m) => _t('$m min', '$m मिनट');
  String minutesShort(int m) => _t('$m min', '$m मिनट');
  String get secondsShort => _t('s', 'से');
  String get addFavorite => _t('Add to favorites', 'पसंदीदा में जोड़ें');
  String get removeFavorite => _t('Remove from favorites', 'पसंदीदा से हटाएँ');
  String get addedToFavorites => _t('Added to favorites', 'पसंदीदा में जोड़ा गया');
  String get removedFromFavorites => _t('Removed from favorites', 'पसंदीदा से हटाया गया');
  String get benefitsAndPurpose => _t('Benefits & purpose', 'लाभ और उद्देश्य');
  String get howToPerform => _t('How to practice', 'कैसे करें');
  String get recommendedDuration => _t('Recommended duration', 'सुझाई गई अवधि');
  String recommendedMinutesText(int m) => _t(
    'We suggest about $m minutes. Pick any length that feels right.',
    'लगभग $m मिनट का सुझाव है। जो अवधि सही लगे, चुनें।',
  );
  String get gentleMode => _t('Gentle mode (no breath holds)', 'जेंटल मोड (बिना साँस रोके)');
  String get gentleModeSub =>
      _t('Skips every hold so you simply breathe in and out.', 'सभी ठहराव हटाता है, बस साँस लें और छोड़ें।');
  String get gentleModeOn => _t('Gentle mode · no holds', 'जेंटल मोड · बिना रोक');
  String get startPractice => _t('Start Practice', 'अभ्यास शुरू करें');
  String get stopAnytime => _t(
    'You can pause or stop at any time. Never force your breath.',
    'आप कभी भी रोक या बंद कर सकते हैं। साँस पर कभी ज़ोर न डालें।',
  );
  String get details => _t('Details', 'विवरण');

  String phaseCue(PhaseType t) => switch (t) {
    PhaseType.inhale => _t('Breathe in', 'साँस लें'),
    PhaseType.holdIn => _t('Hold gently', 'हल्का रोकें'),
    PhaseType.exhale => _t('Breathe out', 'साँस छोड़ें'),
    PhaseType.holdOut => _t('Rest', 'ठहरें'),
  };
  String phaseShort(PhaseType t) => switch (t) {
    PhaseType.inhale => _t('In', 'लें'),
    PhaseType.holdIn => _t('Hold', 'रोकें'),
    PhaseType.exhale => _t('Out', 'छोड़ें'),
    PhaseType.holdOut => _t('Rest', 'ठहरें'),
  };

  // Session
  String get getComfortable => _t('Get comfortable', 'आराम से बैठें');
  String get prepHint => _t('Relax your shoulders and soften your gaze.', 'कंधों को ढीला करें और नज़र को कोमल रखें।');
  String get followAtYourPace => _t('Follow the circle at a comfortable pace.', 'आरामदायक गति से घेरे का अनुसरण करें।');
  String get paused => _t('Paused', 'रुका हुआ');
  String get pause => _t('Pause', 'रोकें');
  String get resume => _t('Resume', 'फिर शुरू करें');
  String get endSession => _t('End Session', 'सत्र समाप्त करें');
  String timeLeft(String clock) => _t('$clock left', '$clock बाकी');
  String get voiceOn => _t('Turn voice guidance on', 'आवाज़ मार्गदर्शन चालू करें');
  String get voiceOff => _t('Turn voice guidance off', 'आवाज़ मार्गदर्शन बंद करें');
  String get sessionCompleteCue => _t('Well done. Your session is complete.', 'बहुत बढ़िया। आपका सत्र पूरा हुआ।');
  String get wellDone => _t('Well done', 'बहुत बढ़िया');
  String sessionSummary(String d, String name) =>
      _t('You breathed for $d with $name.', 'आपने $name के साथ $d श्वास अभ्यास किया।');
  String get sessionTooShort => _t(
    'Sessions shorter than 15 seconds aren’t saved — every breath still counts!',
    '15 सेकंड से छोटे सत्र सेव नहीं होते — फिर भी हर साँस मायने रखती है!',
  );
  String get today => _t('today', 'आज');
  String get challengeKeepGoing => _t('Keep going — you’re making progress!', 'जारी रखें — आप आगे बढ़ रहे हैं!');
  String get done => _t('Done', 'पूरा हुआ');
  String get practiceAgain => _t('Practice again', 'फिर से अभ्यास करें');

  // Emergency calm
  List<String> get calmMessages => _hi
      ? const [
          'एक आरामदायक साँस लें। ढीला छोड़ें। अपनी गति से एनिमेशन का अनुसरण करें।',
          'आप सुरक्षित हैं। बस इस पल पर ध्यान दें।',
          'कंधों को नीचे गिरने दें। जबड़े को ढीला करें।',
          'कोई जल्दी नहीं है। जितनी धीमी साँस सहज लगे, उतनी लें।',
          'हर साँस छोड़ने के साथ थोड़ा और ढीला छोड़ें।',
        ]
      : const [
          'Take a comfortable breath. Relax. Follow the animation at your own pace.',
          'You are doing well. Just focus on this moment.',
          'Let your shoulders drop. Soften your jaw.',
          'There is no rush. Breathe as slowly as feels comfortable.',
          'With each breath out, let go a little more.',
        ];
  String get shorterBreaths => _t('Shorter breaths', 'छोटी साँसें');
  String get stop => _t('Stop', 'बंद करें');
  String get medicalDisclaimer => _t(
    'This is a relaxation feature, not emergency medical treatment. If you have severe breathing difficulty, chest pain, fainting or other serious symptoms, seek urgent medical help immediately.',
    'यह एक विश्राम सुविधा है, आपातकालीन चिकित्सा उपचार नहीं। अगर साँस लेने में गंभीर कठिनाई, सीने में दर्द, बेहोशी या अन्य गंभीर लक्षण हों, तो तुरंत चिकित्सा सहायता लें।',
  );
  String get calmStoppedMessage =>
      _t('Well done for taking a moment to breathe.', 'साँस के लिए एक पल निकालने के लिए शाबाश।');

  // Mood
  String get howAreYouFeeling => _t('How are you feeling right now?', 'आप अभी कैसा महसूस कर रहे हैं?');
  String get moodPrivacyNote => _t(
    'Your answer is only used to suggest techniques. It is never saved.',
    'आपका जवाब केवल तकनीक सुझाने के लिए है। इसे कभी सेव नहीं किया जाता।',
  );
  String get close => _t('Close', 'बंद करें');
  String get youAreFeeling => _t('You’re feeling', 'आप महसूस कर रहे हैं');
  String get suggestedForYou => _t('Suggested for you', 'आपके लिए सुझाव');
  String get chooseAnotherMood => _t('Choose another mood', 'दूसरा मूड चुनें');
  String get notMedicalAdvice => _t(
    'BreatheCare offers relaxation exercises for everyday wellbeing. It is not medical advice or treatment.',
    'BreatheCare रोज़मर्रा की भलाई के लिए विश्राम अभ्यास प्रदान करता है। यह चिकित्सा सलाह या उपचार नहीं है।',
  );

  // Challenges
  String get dailyChallenges => _t('Daily Challenges', 'दैनिक चैलेंज');
  String get todaysChallenge => _t('Today’s challenge', 'आज का चैलेंज');
  String get challengeCompleted => _t('Completed 🎉', 'पूरा हुआ 🎉');
  String get challengeInProgress => _t('In progress', 'जारी है');
  String challengeStreak(int n) => n == 0
      ? _t('Complete today’s challenge to start a streak', 'स्ट्रीक शुरू करने के लिए आज का चैलेंज पूरा करें')
      : _t('🔥 $n-day challenge streak', '🔥 $n दिन की चैलेंज स्ट्रीक');
  String get challengeStreakLabel => _t('challenge streak', 'चैलेंज स्ट्रीक');
  String get completedLast30 => _t('completed (30 days)', 'पूरे हुए (30 दिन)');
  String get previousChallenges => _t('Previous challenges', 'पिछले चैलेंज');
  String get noChallengeHistory =>
      _t('Your challenge history will appear here from tomorrow.', 'आपका चैलेंज इतिहास कल से यहाँ दिखेगा।');
  String get missed => _t('Missed', 'छूट गया');
  String startWith(String name) => _t('Start $name', '$name शुरू करें');
  String challengeProgressText(ChallengeProgress p) {
    switch (p.def.kind) {
      case ChallengeKind.longSession:
      case ChallengeKind.totalMinutes:
        final cur = (p.current / 60).floor();
        return _t('$cur/${p.target ~/ 60} min', '$cur/${p.target ~/ 60} मिनट');
      case ChallengeKind.distinctDays:
        return _t('${p.current}/${p.target} days', '${p.current}/${p.target} दिन');
      default:
        return '${p.current}/${p.target}';
    }
  }

  String challengesCompleted(int done, int total) =>
      _t('$done of $total challenges completed', '$total में से $done चैलेंज पूरे');

  // Learn
  String get learnSubtitle => _t('Simple, friendly guides to breathing well.', 'अच्छी श्वास के लिए सरल और आसान गाइड।');
  String get featured => _t('Featured', 'विशेष');
  String get allArticles => _t('All articles', 'सभी लेख');
  String readMinutes(int m) => _t('$m min read', '$m मिनट पढ़ें');

  // Progress
  String get yourProgress => _t('Your Progress', 'आपकी प्रगति');
  String get progressSubtitle =>
      _t('Every mindful minute adds up. Here’s your journey so far.', 'हर सजग मिनट जुड़ता है। अब तक की आपकी यात्रा।');
  String get totalSessions => _t('total sessions', 'कुल सत्र');
  String get totalMinutes => _t('total minutes', 'कुल मिनट');
  String get currentStreak => _t('current streak (days)', 'वर्तमान स्ट्रीक (दिन)');
  String get longestStreak => _t('longest streak (days)', 'सबसे लंबी स्ट्रीक (दिन)');
  String get todaysActivity => _t('Today’s activity', 'आज की गतिविधि');
  String get weeklyActivity => _t('Weekly activity', 'साप्ताहिक गतिविधि');
  String get monthlyActivity => _t('Monthly activity', 'मासिक गतिविधि');
  String minutesThisWeekValue(String d) => _t('$d in the last 7 days', 'पिछले 7 दिनों में $d');
  String last28Days(String d, int days) =>
      _t('$d across $days days (last 4 weeks)', '$days दिनों में $d (पिछले 4 सप्ताह)');
  String get less => _t('Less', 'कम');
  String get more => _t('More', 'अधिक');
  String get mostPracticed => _t('Most practiced', 'सबसे ज़्यादा किए गए');
  String get sessionHistory => _t('Session history', 'सत्र इतिहास');
  String get noSessionsYet => _t(
    'No sessions yet. Your first breath starts the journey.',
    'अभी कोई सत्र नहीं। आपकी पहली साँस से यात्रा शुरू होती है।',
  );
  String sessionsCount(int n) => _hi ? '$n सत्र' : (n == 1 ? '1 session' : '$n sessions');
  String showAll(int n) => _t('Show all ($n)', 'सभी दिखाएँ ($n)');
  String get showLess => _t('Show less', 'कम दिखाएँ');

  String durationText(int seconds) {
    if (seconds < 60) return _t('$seconds sec', '$seconds सेकंड');
    final mins = (seconds / 60).round();
    if (mins < 60) return _t('$mins min', '$mins मिनट');
    final h = mins ~/ 60, m = mins % 60;
    return m == 0 ? _t('$h h', '$h घंटे') : _t('$h h $m min', '$h घंटे $m मिनट');
  }

  // Favorites
  String get noFavoritesTitle => _t('No favorites yet', 'अभी कोई पसंदीदा नहीं');
  String get noFavoritesBody => _t(
    'Tap the heart on any technique to save it here for quick access.',
    'किसी भी तकनीक पर दिल का निशान दबाएँ ताकि वह जल्दी पहुँच के लिए यहाँ सेव हो जाए।',
  );

  // Audio
  String get audioGuidance => _t('Audio guidance', 'ऑडियो मार्गदर्शन');
  String get audioDownloadHint => _t(
    'Download once and listen any time, even without internet.',
    'एक बार डाउनलोड करें और कभी भी सुनें, बिना इंटरनेट के भी।',
  );
  String get downloadAudio => _t('Download audio', 'ऑडियो डाउनलोड करें');
  String downloadingPercent(int p) => _t('Downloading… $p%', 'डाउनलोड हो रहा है… $p%');
  String get downloaded => _t('Downloaded', 'डाउनलोड हो गया');
  String get notDownloaded => _t('Not downloaded', 'डाउनलोड नहीं हुआ');
  String get retry => _t('Retry', 'फिर से कोशिश करें');
  String get cancel => _t('Cancel', 'रद्द करें');
  String get delete => _t('Delete', 'हटाएँ');
  String get deleteDownload => _t('Delete download', 'डाउनलोड हटाएँ');
  String get deleteDownloadTitle => _t('Delete this audio?', 'यह ऑडियो हटाएँ?');
  String get deleteDownloadBody => _t(
    'You can download it again any time when you are online.',
    'ऑनलाइन होने पर आप इसे कभी भी फिर से डाउनलोड कर सकते हैं।',
  );
  String get play => _t('Play', 'चलाएँ');
  String get replay => _t('Replay', 'फिर से चलाएँ');
  String get audioCorrupt => _t('This file could not be played.', 'यह फ़ाइल चलाई नहीं जा सकी।');
  String audioError(AudioError? e) => switch (e) {
    AudioError.notConfigured => _t(
      'Audio downloads are not available in this version yet.',
      'इस संस्करण में अभी ऑडियो डाउनलोड उपलब्ध नहीं है।',
    ),
    AudioError.notFound => _t(
      'This audio is not available yet. Please try again later.',
      'यह ऑडियो अभी उपलब्ध नहीं है। कृपया बाद में कोशिश करें।',
    ),
    AudioError.storage => _t('Not enough storage on this device.', 'इस डिवाइस पर पर्याप्त स्टोरेज नहीं है।'),
    _ => _t(
      'Download failed. Check your internet connection and retry.',
      'डाउनलोड विफल। इंटरनेट कनेक्शन जाँचें और फिर से कोशिश करें।',
    ),
  };
  String get downloadedAudio => _t('Downloaded audio', 'डाउनलोड किया गया ऑडियो');
  String downloadedCount(int n, String size) => _t('$n downloaded · $size', '$n डाउनलोड · $size');
  String storageUsed(String size) => _t('$size used', '$size उपयोग में');
  String get audioOfflineNote => _t(
    'Downloaded audio plays offline. Delete files any time to free space.',
    'डाउनलोड ऑडियो ऑफ़लाइन चलता है। जगह खाली करने के लिए कभी भी हटाएँ।',
  );
  String get deleteAllDownloads => _t('Delete all downloads', 'सभी डाउनलोड हटाएँ');
  String get deleteAllDownloadsBody =>
      _t('All downloaded audio will be removed from this device.', 'सभी डाउनलोड ऑडियो इस डिवाइस से हटा दिए जाएँगे।');
  String get cloudNotConfigured => _t(
    'Cloud features (account backup and audio downloads) are not available in this version yet. Everything else works fully offline.',
    'क्लाउड सुविधाएँ (अकाउंट बैकअप और ऑडियो डाउनलोड) इस संस्करण में अभी उपलब्ध नहीं हैं। बाकी सब कुछ पूरी तरह ऑफ़लाइन काम करता है।',
  );

  // Settings
  String get preferences => _t('Preferences', 'प्राथमिकताएँ');
  String get language => _t('Language', 'भाषा');
  String get theme => _t('Theme', 'थीम');
  String get light => _t('Light', 'लाइट');
  String get dark => _t('Dark', 'डार्क');
  String get system => _t('System', 'सिस्टम');
  String get audioSettings => _t('Audio', 'ऑडियो');
  String get voiceGuidance => _t('Voice guidance', 'आवाज़ मार्गदर्शन');
  String get voiceGuidanceSub => _t(
    'Spoken “breathe in / breathe out” cues during sessions',
    'सत्र के दौरान “साँस लें / साँस छोड़ें” बोलकर बताना',
  );
  String get voiceVolume => _t('Voice volume', 'आवाज़ का वॉल्यूम');
  String get hapticCues => _t('Gentle vibration cues', 'हल्के कंपन संकेत');
  String get hapticCuesSub => _t('A soft tap when each phase changes', 'हर चरण बदलने पर हल्का कंपन');
  String get gentleModeDefault => _t('Gentle mode by default', 'डिफ़ॉल्ट रूप से जेंटल मोड');
  String get account => _t('Account', 'अकाउंट');
  String get accountAndBackup => _t('Account & backup', 'अकाउंट और बैकअप');
  String get accountOptional =>
      _t('Optional — back up and restore your progress', 'वैकल्पिक — अपनी प्रगति का बैकअप और रीस्टोर');
  String signedInAs(String id) => _t('Signed in as $id', '$id के रूप में साइन इन');
  String get backupAvailable => _t('Back up or restore your progress', 'प्रगति का बैकअप या रीस्टोर करें');
  String get aboutSection => _t('About', 'जानकारी');
  String get privacyPolicy => _t('Privacy Policy', 'गोपनीयता नीति');
  String get terms => _t('Terms & Conditions', 'नियम और शर्तें');
  String get aboutApp => _t('About BreatheCare', 'BreatheCare के बारे में');
  String get adPrivacy => _t('Ad privacy choices', 'विज्ञापन गोपनीयता विकल्प');
  String get yourData => _t('Your data', 'आपका डेटा');
  String get deleteMyData => _t('Delete My Data', 'मेरा डेटा हटाएँ');
  String get deleteMyDataSub =>
      _t('Remove progress, favorites, downloads and settings', 'प्रगति, पसंदीदा, डाउनलोड और सेटिंग्स हटाएँ');
  String get deleteMyDataTitle => _t('Delete all your data?', 'अपना सारा डेटा हटाएँ?');
  String get deleteMyDataBody => _t(
    'This permanently removes your breathing history, favorites, challenge progress, downloaded audio and settings from this device. This cannot be undone.',
    'यह आपके श्वास इतिहास, पसंदीदा, चैलेंज प्रगति, डाउनलोड ऑडियो और सेटिंग्स को इस डिवाइस से स्थायी रूप से हटा देगा। इसे वापस नहीं किया जा सकता।',
  );
  String get alsoDeleteCloud => _t('Also delete my cloud backup and account', 'मेरा क्लाउड बैकअप और अकाउंट भी हटाएँ');
  String get deleteEverything => _t('Delete everything', 'सब कुछ हटाएँ');
  String get dataDeleted => _t('Your data has been deleted.', 'आपका डेटा हटा दिया गया है।');
  String get lastUpdated => _t('Last updated: November 2026', 'अंतिम अपडेट: नवंबर 2026');
  String versionLabel(String v) => _t('Version $v', 'संस्करण $v');
  String get advertisement => _t('Advertisement', 'विज्ञापन');

  // Account
  String get accountIntro => _t(
    'An account is completely optional. Create one to back up your progress and restore it on another device.',
    'अकाउंट पूरी तरह वैकल्पिक है। अपनी प्रगति का बैकअप लेने और दूसरे डिवाइस पर वापस पाने के लिए बनाएँ।',
  );
  String get userId => _t('User ID', 'यूज़र आईडी');
  String get userIdHelp => _t('4–20 letters, numbers or _', '4–20 अक्षर, अंक या _');
  String get pin => _t('PIN', 'पिन');
  String get pinHelp => _t('4–6 digits', '4–6 अंक');
  String get showPin => _t('Show PIN', 'पिन दिखाएँ');
  String get hidePin => _t('Hide PIN', 'पिन छिपाएँ');
  String get login => _t('Login', 'लॉगिन');
  String get createAccount => _t('Create Account', 'अकाउंट बनाएँ');
  String get maybeLater => _t('Maybe Later', 'बाद में');
  String get logout => _t('Log out', 'लॉग आउट');
  String get pinWarning => _t(
    'Please remember your PIN — it can’t be recovered without an e-mail address.',
    'कृपया अपना पिन याद रखें — ईमेल के बिना इसे वापस नहीं पाया जा सकता।',
  );
  String get accountCreated => _t(
    'Account created. You can now back up your progress.',
    'अकाउंट बन गया। अब आप अपनी प्रगति का बैकअप ले सकते हैं।',
  );
  String get signedIn => _t('Welcome back! You are signed in.', 'फिर से स्वागत है! आप साइन इन हैं।');
  String get inviteTitle => _t('Keep your progress safe', 'अपनी प्रगति सुरक्षित रखें');
  String get inviteBody => _t(
    'You’ve been breathing with BreatheCare for a while — wonderful! Create a free, optional account to back up your progress and restore it on another device.',
    'आप कुछ समय से BreatheCare के साथ अभ्यास कर रहे हैं — बहुत बढ़िया! अपनी प्रगति का बैकअप लेने और दूसरे डिवाइस पर पाने के लिए एक मुफ़्त, वैकल्पिक अकाउंट बनाएँ।',
  );
  String get backupNow => _t('Back up now', 'अभी बैकअप लें');
  String get backupDone => _t('Your progress is backed up.', 'आपकी प्रगति का बैकअप हो गया।');
  String get restore => _t('Restore', 'रीस्टोर करें');
  String get restoreTitle => _t('Restore from backup?', 'बैकअप से रीस्टोर करें?');
  String get restoreBody => _t(
    'Sessions and favorites from your backup will be merged with this device.',
    'आपके बैकअप के सत्र और पसंदीदा इस डिवाइस के डेटा के साथ जोड़ दिए जाएँगे।',
  );
  String get restoreDone => _t('Progress restored.', 'प्रगति रीस्टोर हो गई।');
  String get neverBackedUp => _t('Not backed up yet', 'अभी बैकअप नहीं लिया गया');
  String lastBackup(String when) => _t('Last backup: $when', 'पिछला बैकअप: $when');
  String accountError(AccountResult r) => switch (r) {
    AccountResult.notConfigured => cloudNotConfigured,
    AccountResult.invalidUserId => _t(
      'User ID must be 4–20 letters, numbers or underscores.',
      'यूज़र आईडी 4–20 अक्षर, अंक या अंडरस्कोर की होनी चाहिए।',
    ),
    AccountResult.invalidPin => _t('PIN must be 4 to 6 digits.', 'पिन 4 से 6 अंकों का होना चाहिए।'),
    AccountResult.userIdTaken => _t(
      'This User ID is already taken. Try another one, or log in.',
      'यह यूज़र आईडी पहले से ली गई है। दूसरी आज़माएँ या लॉगिन करें।',
    ),
    AccountResult.wrongCredentials => _t('User ID or PIN is incorrect.', 'यूज़र आईडी या पिन गलत है।'),
    AccountResult.tooManyAttempts => _t(
      'Too many attempts. Please wait a little and try again.',
      'बहुत अधिक प्रयास। कृपया थोड़ी देर बाद कोशिश करें।',
    ),
    AccountResult.network => _t(
      'No internet connection. Please try again when you are online.',
      'इंटरनेट कनेक्शन नहीं है। ऑनलाइन होने पर फिर से कोशिश करें।',
    ),
    AccountResult.noBackup => _t('No backup found for this account yet.', 'इस अकाउंट का अभी कोई बैकअप नहीं मिला।'),
    _ => _t('Something went wrong. Please try again.', 'कुछ गड़बड़ हुई। कृपया फिर से कोशिश करें।'),
  };

  // Redesign
  String get heroHeadline => _t('Breathe in calm.\nLet the day soften.', 'शांति भीतर लें।\nदिन को हल्का होने दें।');
  String todayPractice(String name, int m) => _t('Today: $name · $m min', 'आज: $name · $m मिनट');
  String get startSession => _t('Start session', 'सत्र शुरू करें');
  String get findYourRhythm => _t('Find your rhythm', 'अपनी लय खोजें');
  String get explorePractices => _t('Explore practices', 'अभ्यास देखें');
  String get explorePracticesSub => _t('Pick a rhythm for this moment.', 'इस पल के लिए एक लय चुनें।');
  String get allTechniquesOverline => _t('All 10 techniques', 'सभी 10 तकनीकें');
  String get breathingLibrary => _t('Breathing library', 'श्वास संग्रह');
  String get checkIn => _t('Check in', 'मन की बात');
  String get needCalmNow => _t('Need calm now?', 'अभी शांति चाहिए?');
  String roundOf(int i, int n) => _t('Round $i of $n', 'चक्र $i / $n');
  String get getReady => _t('Get ready', 'तैयार हो जाएँ');
  String phaseName(PhaseType t) => switch (t) {
    PhaseType.inhale => _t('Inhale', 'साँस लें'),
    PhaseType.holdIn => _t('Hold', 'रोकें'),
    PhaseType.exhale => _t('Exhale', 'साँस छोड़ें'),
    PhaseType.holdOut => _t('Rest', 'ठहरें'),
  };
  String get audioGuideOn => _t('Play audio guide', 'ऑडियो गाइड चलाएँ');
  String get audioGuideOff => _t('Stop audio guide', 'ऑडियो गाइड रोकें');
  String get audioGuideNotDownloaded => _t(
    'Download this technique’s audio guide from its detail page to play it here.',
    'यहाँ चलाने के लिए इस तकनीक का ऑडियो गाइड उसके विवरण पेज से डाउनलोड करें।',
  );
  String get hapticsOn => _t('Turn vibration cues on', 'कंपन संकेत चालू करें');
  String get hapticsOff => _t('Turn vibration cues off', 'कंपन संकेत बंद करें');
  String get end => _t('End', 'समाप्त');
  String get jumpBackIn => _t('Jump back in', 'फिर से शुरू करें');
  String savedCount(int n) => _t(n == 1 ? '1 saved technique' : '$n saved techniques', '$n सेव की गई तकनीकें');
  String weekSummary(String d, int days, int streak) => _t(
    '$d this week · $days active ${days == 1 ? 'day' : 'days'} · $streak-day streak',
    'इस सप्ताह $d · $days सक्रिय दिन · $streak दिन की स्ट्रीक',
  );
  String get progressTooltip => _t('Your progress', 'आपकी प्रगति');
}

extension AppStringsContext on BuildContext {
  AppStrings get s => AppStrings(Localizations.localeOf(this).languageCode);
}
