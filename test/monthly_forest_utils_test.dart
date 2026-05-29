import 'package:flutter_test/flutter_test.dart';

import 'package:flow_clock/core/utils/monthly_forest_utils.dart';
import 'package:flow_clock/models/models.dart';

void main() {
  group('MonthlyForestStats', () {
    test('统计收货、巅峰与专注', () {
      final stats = MonthlyForestStats.fromRecords({
        '2026-05-01': DailyRecord(
          dateKey: '2026-05-01',
          completedBlocks: 8,
          totalFocusMinutes: 480,
          isClaimed: true,
        ),
        '2026-05-02': DailyRecord(
          dateKey: '2026-05-02',
          completedBlocks: 6,
          totalFocusMinutes: 360,
        ),
        '2026-05-03': DailyRecord(
          dateKey: '2026-05-03',
          completedBlocks: 0,
        ),
      });

      expect(stats.activeDays, 2);
      expect(stats.claimedDays, 1);
      expect(stats.peakDays, 1);
      expect(stats.harvestDays, 2);
      expect(stats.totalFocusMinutes, 840);
      expect(stats.hasEfficiencyBadge, isFalse);
    });

    test('巅峰日≥15 获高效之月徽章', () {
      final records = <String, DailyRecord>{};
      for (var i = 1; i <= 15; i++) {
        final key =
            '2026-05-${i.toString().padLeft(2, '0')}';
        records[key] = DailyRecord(
          dateKey: key,
          completedBlocks: 8,
          totalFocusMinutes: 480,
        );
      }
      expect(MonthlyForestStats.fromRecords(records).hasEfficiencyBadge, isTrue);
    });
  });
}
