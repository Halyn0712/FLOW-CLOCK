import 'package:flutter_test/flutter_test.dart';

import 'package:flow_clock/core/utils/day_tier_utils.dart';
import 'package:flow_clock/models/models.dart';

void main() {
  group('dayTierFor', () {
    test('k=0 为起步日', () {
      final daily = DailyRecord(dateKey: '2026-05-29');
      expect(dayTierFor(daily), DayTier.starter);
    });

    test('k=4 且 4h 为成长日', () {
      final daily = DailyRecord(
        dateKey: '2026-05-29',
        completedBlocks: 4,
        totalFocusMinutes: 240,
      );
      expect(dayTierFor(daily), DayTier.growth);
    });

    test('k=8 且 8h 为巅峰日', () {
      final daily = DailyRecord(
        dateKey: '2026-05-29',
        completedBlocks: 8,
        totalFocusMinutes: 480,
      );
      expect(dayTierFor(daily), DayTier.peak);
    });
  });
}
