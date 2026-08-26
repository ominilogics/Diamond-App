import 'package:flutter/foundation.dart';
import '../../domain/entities/event_entity.dart';

class SystemOccasionsDataSource {
  /// Returns the active fixed upcoming secular occasions.
  /// Applies the strict timing rules:
  /// - Appearence: 7 Days Before event date
  /// - Notification: 1 Day Before event date (at 9:00 AM)
  /// - Wipe Out / Rollover: 3 Days After event date (on Day 4, rolls over +1 Year)
  List<EventEntity> getUpcomingSystemOccasions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    debugPrint('📅 [UPCOMING_EVENTS_DEBUG] Evaluating system occasions for today: $today (now: $now)');

    final rawOccasions = [
      _OccasionDefinition('New Year\'s Day', 'new_year', (year) => DateTime(year, 1, 1)),
      _OccasionDefinition('International Women\'s Day', 'womens_day', (year) => DateTime(year, 3, 8)),
      _OccasionDefinition('World Health Day', 'health_day', (year) => DateTime(year, 4, 7)),
      _OccasionDefinition('Earth Day', 'earth_day', (year) => DateTime(year, 4, 22)),
      _OccasionDefinition('Labour Day', 'labour_day', (year) => DateTime(year, 5, 1)),
      _OccasionDefinition('International Nurses Day', 'nurses_day', (year) => DateTime(year, 5, 12)),
      _OccasionDefinition('Mother\'s Day', 'mothers_day', (year) => _nthWeekdayOfMonth(year, 5, DateTime.sunday, 2)),
      _OccasionDefinition('Father\'s Day', 'fathers_day', (year) => _nthWeekdayOfMonth(year, 6, DateTime.sunday, 3)),
      _OccasionDefinition('International Friendship Day', 'friendship_day', (year) => DateTime(year, 7, 30)),
      _OccasionDefinition('Grandparents Day', 'grandparents_day', (year) => _grandparentsDay(year)),
      _OccasionDefinition('World Teachers\' Day', 'teachers_day', (year) => DateTime(year, 10, 5)),
      _OccasionDefinition('World Mental Health Day', 'mental_health_day', (year) => DateTime(year, 10, 10)),
      _OccasionDefinition('Breast Cancer Awareness Day', 'breast_cancer_day', (year) => DateTime(year, 10, 13)),
      _OccasionDefinition('Boss\'s Day', 'boss_day', (year) => DateTime(year, 10, 16)),
      _OccasionDefinition('Halloween', 'halloween', (year) => DateTime(year, 10, 31)),
      _OccasionDefinition('Thanksgiving', 'thanksgiving', (year) => _nthWeekdayOfMonth(year, 11, DateTime.thursday, 4)),
      _OccasionDefinition('World Children\'s Day', 'childrens_day', (year) => DateTime(year, 11, 20)),
      _OccasionDefinition('New Year\'s Eve', 'new_years_eve', (year) => DateTime(year, 12, 31)),
    ];

    final List<EventEntity> activeOccasions = [];
    int syntheticId = -100;

    for (final def in rawOccasions) {
      DateTime eventDate = def.getDate(now.year);
      
      // If 3 days have already passed since the event date, roll over to next year
      if (today.isAfter(eventDate.add(const Duration(days: 3)))) {
        eventDate = def.getDate(now.year + 1);
      }

      final startDate = eventDate.subtract(const Duration(days: 7));
      final endDate = eventDate.add(const Duration(days: 3));

      // Check if current date is within [eventDate - 7 days, eventDate + 3 days]
      if ((today.isAfter(startDate) || today.isAtSameMomentAs(startDate)) &&
          (today.isBefore(endDate) || today.isAtSameMomentAs(endDate))) {
        final notificationTime = DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
          9,
          0,
        ).subtract(const Duration(days: 1)).toUtc();

        debugPrint('✅ [UPCOMING_EVENTS_DEBUG] Active calendar occasion matched: "${def.title}" (slug: ${def.categorySlug}) on $eventDate (UTC Notif time: $notificationTime)');

        activeOccasions.add(
          EventEntity(
            id: syntheticId--,
            remoteId: 'system_occasion_${def.categorySlug}_${eventDate.year}',
            title: def.title,
            date: eventDate,
            reminder: 'One Day Before',
            isCustom: false,
            notificationTime: notificationTime,
            isNotified: notificationTime.isBefore(now.toUtc()),
          ),
        );
      }
    }

    activeOccasions.sort((a, b) => a.date.compareTo(b.date));
    debugPrint('📊 [UPCOMING_EVENTS_DEBUG] Total upcoming system occasions returned: ${activeOccasions.length}');
    return activeOccasions;
  }

  static DateTime _nthWeekdayOfMonth(int year, int month, int weekday, int n) {
    var date = DateTime(year, month, 1);
    while (date.weekday != weekday) {
      date = date.add(const Duration(days: 1));
    }
    date = date.add(Duration(days: 7 * (n - 1)));
    return date;
  }

  static DateTime _grandparentsDay(int year) {
    // First Sunday after Labor Day (1st Monday in September)
    var laborDay = DateTime(year, 9, 1);
    while (laborDay.weekday != DateTime.monday) {
      laborDay = laborDay.add(const Duration(days: 1));
    }
    var grandparentsDay = laborDay.add(const Duration(days: 1));
    while (grandparentsDay.weekday != DateTime.sunday) {
      grandparentsDay = grandparentsDay.add(const Duration(days: 1));
    }
    return grandparentsDay;
  }
}

class _OccasionDefinition {
  final String title;
  final String categorySlug;
  final DateTime Function(int year) getDate;

  _OccasionDefinition(this.title, this.categorySlug, this.getDate);
}
