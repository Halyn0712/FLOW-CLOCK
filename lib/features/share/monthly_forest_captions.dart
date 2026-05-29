import 'monthly_forest_data.dart';

String monthlyForestCaption(MonthlyForestData data, {bool long = false}) {
  final s = data.stats;
  final focusH = s.totalFocusMinutes ~/ 60;
  final month = data.monthLabel;

  if (long) {
    final badge = s.hasEfficiencyBadge ? '\n🏅 高效之月' : '';
    return '''$month 自律森林全景 🌳

📊 收货 ${s.claimedDays} 天 · 专注 ${focusH}h
🔥 巅峰日 ×${s.peakDays} · 丰收日 ×${s.harvestDays}$badge

一眼看见这个月的成长轨迹。

#FlowClock #自律森林 #月相日历 #专注 #回顾''';
  }

  return '🌳 $month 自律森林\n'
      '收货 ${s.claimedDays} 天 · 专注 ${focusH}h · 巅峰 ×${s.peakDays}\n'
      'Flow Clock 月度回顾 ✨';
}
