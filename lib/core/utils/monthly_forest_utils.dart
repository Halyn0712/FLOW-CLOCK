import '../../models/models.dart';
import 'day_tier_utils.dart';

/// 月末森林长图统计数据
class MonthlyForestStats {
  const MonthlyForestStats({
    required this.claimedDays,
    required this.totalFocusMinutes,
    required this.peakDays,
    required this.harvestDays,
    required this.activeDays,
  });

  final int claimedDays;
  final int totalFocusMinutes;
  final int peakDays;
  final int harvestDays;
  final int activeDays;

  /// SOP §4.3：月内巅峰日 ≥15 → 「高效之月」
  bool get hasEfficiencyBadge => peakDays >= 15;

  factory MonthlyForestStats.fromRecords(Map<String, DailyRecord> records) {
    var claimed = 0;
    var focus = 0;
    var peak = 0;
    var harvest = 0;
    var active = 0;

    for (final r in records.values) {
      if (r.completedBlocks < 1) continue;
      active++;
      focus += r.totalFocusMinutes;
      if (r.isClaimed) claimed++;
      final tier = dayTierFor(r);
      if (tier == DayTier.peak) peak++;
      if (tier == DayTier.harvest || tier == DayTier.peak) harvest++;
    }

    return MonthlyForestStats(
      claimedDays: claimed,
      totalFocusMinutes: focus,
      peakDays: peak,
      harvestDays: harvest,
      activeDays: active,
    );
  }
}
