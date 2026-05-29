import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/day_theme.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/calendar_utils.dart';
import '../../models/models.dart';
import '../../widgets/calendar_day_cell.dart';
import '../../widgets/common_widgets.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late int _year;
  late int _month;
  late Map<String, DailyRecord> _records;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _loadMonth();
  }

  void _loadMonth() {
    _records = StorageService.getRecordsForMonth(_year, _month);
  }

  void _changeMonth(int delta) {
    setState(() {
      var m = _month + delta;
      var y = _year;
      if (m > 12) {
        m = 1;
        y++;
      } else if (m < 1) {
        m = 12;
        y--;
      }
      _month = m;
      _year = y;
      _loadMonth();
    });
  }

  int get _claimedDays => _records.values.where((r) => r.isClaimed).length;

  int get _totalFocusMinutes =>
      _records.values.fold(0, (sum, r) => sum + r.totalFocusMinutes);

  void _showDayDetail(DateTime date) {
    final key = DailyRecord.keyFor(date);
    final record = _records[key] ?? DailyRecord(dateKey: key);
    final theme = DayTheme.forDate(date);
    final isToday = _isSameDay(date, DateTime.now());

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              DateFormat('M月d日 EEEE', 'zh_CN').format(date),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isToday)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '今天',
                  style: TextStyle(color: theme.primary, fontSize: 13),
                ),
              ),
            const SizedBox(height: 16),
            if (record.completedBlocks > 0) ...[
              Opacity(
                opacity: record.isClaimed ? 1.0 : 0.6,
                child: PlantWidget(
                  assetPath: theme.plantAsset,
                  height: 120,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${theme.plantEmoji} ${theme.plantName}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              _detailRow('完成块数', '${record.completedBlocks} / 8'),
              _detailRow(
                '专注时长',
                formatFocusMinutes(record.totalFocusMinutes),
              ),
              _detailRow('收货状态', _claimLabel(record)),
              if (record.reflection != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '「${record.reflection}」',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ] else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  '这一天还没有专注记录',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _claimLabel(DailyRecord r) {
    if (r.isClaimed) return '✅ 已确认收货';
    if (r.isFullCrown) return '⏳ 满冠待收货';
    if (r.completedBlocks > 0) return '🌱 进行中';
    return '—';
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final theme = DayTheme.forDate(DateTime.now());
    final cells = buildMonthGrid(_year, _month);
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('月历'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // 月份切换 + 摘要
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  monthTitle(_year, _month),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryChip('收货', '$_claimedDays 天', theme.primary),
                _summaryChip(
                  '专注',
                  formatFocusMinutes(_totalFocusMinutes),
                  theme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 星期标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: weekdayLabels
                  .map(
                    (w) => Expanded(
                      child: Center(
                        child: Text(
                          w,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 4),
          // 月历网格
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 0.75,
                ),
                itemCount: cells.length,
                itemBuilder: (_, i) {
                  final date = cells[i];
                  if (date == null) return const SizedBox.shrink();
                  final key = DailyRecord.keyFor(date);
                  return CalendarDayCell(
                    date: date,
                    record: _records[key],
                    isToday: _isSameDay(date, today),
                    onTap: () => _showDayDetail(date),
                  );
                },
              ),
            ),
          ),
          // 图例
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot(const Color(0xFFE8B84A), '已收货'),
                const SizedBox(width: 16),
                _legendDot(Colors.grey.shade400, '待收货', dashed: true),
                const SizedBox(width: 16),
                _legendDot(theme.primary.withValues(alpha: 0.5), '进行中'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label, {bool dashed = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: color,
              width: 1.5,
              style: dashed ? BorderStyle.solid : BorderStyle.solid,
            ),
            color: dashed ? Colors.transparent : color.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }
}
