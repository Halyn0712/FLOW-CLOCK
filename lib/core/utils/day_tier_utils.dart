import '../../models/models.dart';

/// 日等级 —— 对应 SOP §4.2
enum DayTier { starter, growth, harvest, peak }

extension DayTierInfo on DayTier {
  String get label {
    switch (this) {
      case DayTier.starter:
        return '起步日';
      case DayTier.growth:
        return '成长日';
      case DayTier.harvest:
        return '丰收日';
      case DayTier.peak:
        return '巅峰日';
    }
  }

  String get emoji {
    switch (this) {
      case DayTier.starter:
        return '☁️';
      case DayTier.growth:
        return '🌤️';
      case DayTier.harvest:
        return '☀️';
      case DayTier.peak:
        return '🔥';
    }
  }
}

DayTier dayTierFor(DailyRecord daily) {
  final k = daily.completedBlocks;
  final focus = daily.totalFocusMinutes;
  if (k >= 8 && focus >= 480) return DayTier.peak;
  if (k >= 6 && focus >= 360) return DayTier.harvest;
  if (k >= 4 && focus >= 240) return DayTier.growth;
  return DayTier.starter;
}
