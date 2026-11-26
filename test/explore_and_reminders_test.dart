import 'package:breathecare/data/explore.dart';
import 'package:breathecare/data/music_categories.dart';
import 'package:breathecare/data/techniques.dart';
import 'package:breathecare/models/article.dart';
import 'package:breathecare/services/reminder_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('explore content is complete and unique', () {
    final ids = allExploreItems.map((a) => a.id).toSet();
    expect(ids.length, allExploreItems.length);
    for (final c in ExploreCategory.values) {
      expect(exploreItemsIn(c), isNotEmpty, reason: c.name);
    }
    expect(exploreItemsIn(ExploreCategory.yoga).every((a) => a.youtubeQuery != null), isTrue);
    for (final a in allExploreItems) {
      for (final t in [a.title, a.summary, ...a.sections.map((x) => x.body)]) {
        expect(t.en.trim(), isNotEmpty, reason: a.id);
        expect(t.hi.trim(), isNotEmpty, reason: a.id);
      }
    }
    // Herbs always carry the safety note.
    for (final a in exploreItemsIn(ExploreCategory.herbs)) {
      expect(a.sections.any((x) => x.heading == Headings.goodToKnow), isTrue, reason: a.id);
    }
  });

  test('youtube links are search URLs', () {
    final a = exploreItemsIn(ExploreCategory.yoga).first;
    final uri = a.youtubeSearchUri!;
    expect(uri.host, 'www.youtube.com');
    expect(uri.path, '/results');
    expect(uri.queryParameters['search_query'], a.youtubeQuery);
  });

  test('search works in both languages', () {
    expect(searchExplore('haldi').map((a) => a.id), contains('herb_haldi'));
    expect(searchExplore('हल्दी').map((a) => a.id), contains('herb_haldi'));
    expect(searchExplore('tree', category: ExploreCategory.herbs), isEmpty);
  });

  test('pick of the day rotates', () {
    final a = explorePickOfTheDay(DateTime(2026, 1, 1));
    final b = explorePickOfTheDay(DateTime(2026, 1, 2));
    expect(a.id, isNot(b.id));
  });

  test('every reminder points somewhere real', () {
    expect(morningMessages.length, 7);
    expect(eveningMessages.length, 7);
    for (final m in [...morningMessages, ...eveningMessages]) {
      final parts = m.payload.split(':');
      final arg = parts.length > 1 ? parts[1] : null;
      switch (parts.first) {
        case 'breathe':
          if (arg != null) expect(techniqueById(arg), isNotNull, reason: m.payload);
        case 'explore':
          expect(exploreCategoryByName(arg!), isNotNull, reason: m.payload);
        case 'music':
          expect(musicCategoryById(arg!), isNotNull, reason: m.payload);
        case 'challenge':
          break;
        default:
          fail('Unknown payload ${m.payload}');
      }
    }
  });

  test('next reminder is always in the future, on the right weekday', () async {
    SharedPreferences.setMockInitialValues({});
    final r = ReminderService(await SharedPreferences.getInstance());
    final now = DateTime(2026, 11, 25, 9, 30); // a Wednesday
    for (var wd = DateTime.monday; wd <= DateTime.sunday; wd++) {
      final at = r.nextWeekdayAt(now, wd, 8, 0);
      expect(at.weekday, wd);
      expect(at.isAfter(now.toUtc()), isTrue);
      expect(at.difference(now.toUtc()).inDays, lessThan(7));
    }
    expect(r.morning, isFalse);
    expect(r.morningTime.hour, 8);
    expect(r.eveningTime.hour, 21);
    expect(r.shouldAsk(activeDays: 3), isFalse); // not initialised in tests
  });
}
