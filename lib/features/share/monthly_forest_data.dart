import '../../app/theme/day_theme.dart';
import '../../core/utils/calendar_utils.dart';
import '../../core/utils/monthly_forest_utils.dart';
import '../../models/models.dart';

/// 月末森林长图数据
class MonthlyForestData {
  const MonthlyForestData({
    required this.year,
    required this.month,
    required this.records,
    required this.stats,
    required this.gridCells,
    required this.accentTheme,
  });

  final int year;
  final int month;
  final Map<String, DailyRecord> records;
  final MonthlyForestStats stats;
  final List<DateTime?> gridCells;
  final DayTheme accentTheme;

  factory MonthlyForestData.fromMonth({
    required int year,
    required int month,
    required Map<String, DailyRecord> records,
  }) {
    return MonthlyForestData(
      year: year,
      month: month,
      records: records,
      stats: MonthlyForestStats.fromRecords(records),
      gridCells: buildMonthGrid(year, month),
      accentTheme: DayTheme.forDate(DateTime(year, month, 15)),
    );
  }

  String get monthLabel => monthTitle(year, month);

  DailyRecord? recordFor(DateTime date) {
    return records[DailyRecord.keyFor(date)];
  }

  bool get canShare => stats.activeDays > 0;
}
