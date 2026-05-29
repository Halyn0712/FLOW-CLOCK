import '../../app/theme/day_theme.dart';
import '../../core/utils/day_tier_utils.dart';
import '../../models/models.dart';

/// 分享卡渲染所需数据
class ShareCardData {
  const ShareCardData({
    required this.date,
    required this.dayTier,
    required this.theme,
    required this.completedBlocks,
    required this.totalFocusMinutes,
    required this.consecutiveClaimDays,
    this.reflection,
    this.showReflection = true,
  });

  final DateTime date;
  final DayTier dayTier;
  final DayTheme theme;
  final int completedBlocks;
  final int totalFocusMinutes;
  final int consecutiveClaimDays;
  final String? reflection;
  final bool showReflection;

  factory ShareCardData.fromDaily({
    required DailyRecord daily,
    required CustomRewardState rewards,
    bool showReflection = true,
  }) {
    return ShareCardData(
      date: daily.date,
      dayTier: dayTierFor(daily),
      theme: DayTheme.forDate(daily.date),
      completedBlocks: daily.completedBlocks,
      totalFocusMinutes: daily.totalFocusMinutes,
      consecutiveClaimDays: rewards.consecutiveClaimDays,
      reflection: daily.reflection,
      showReflection: showReflection,
    );
  }

  String get treeTitle {
    if (completedBlocks >= 8) return '满冠神树';
    if (completedBlocks >= 4) return '半日之树';
    return '今日之树';
  }

  String get focusHours {
    final h = totalFocusMinutes ~/ 60;
    final m = totalFocusMinutes % 60;
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  String get formattedDate =>
      '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

  /// 非今天的历史记录（月历回顾分享）
  bool get isHistorical {
    final now = DateTime.now();
    return date.year != now.year ||
        date.month != now.month ||
        date.day != now.day;
  }

  /// 月历历史日分享（不含连续收货 streak）
  factory ShareCardData.fromRecord(
    DailyRecord daily, {
    bool showReflection = true,
  }) {
    return ShareCardData(
      date: daily.date,
      dayTier: dayTierFor(daily),
      theme: DayTheme.forDate(daily.date),
      completedBlocks: daily.completedBlocks,
      totalFocusMinutes: daily.totalFocusMinutes,
      consecutiveClaimDays: 0,
      reflection: daily.reflection,
      showReflection: showReflection,
    );
  }
}
