import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/day_theme.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/calendar_utils.dart';
import '../../core/utils/day_tier_utils.dart';
import '../../features/share/monthly_forest_data.dart';
import '../../features/share/monthly_forest_preview_sheet.dart';
import '../../features/share/share_card_data.dart';
import '../../features/share/share_service.dart';
import '../../models/models.dart';
import '../../widgets/calendar_day_cell.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/daily_tree_widget.dart';

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

  void _shareDay(DailyRecord record) {
    if (record.completedBlocks < 1) return;
    SharePreviewSheet.show(
      context,
      data: ShareCardData.fromRecord(record),
      initialReflection: record.reflection,
    );
  }

  void _shareMonthlyForest() {
    final data = MonthlyForestData.fromMonth(
      year: _year,
      month: _month,
      records: _records,
    );
    if (!data.canShare) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('本月还没有专注记录，无法生成森林长图')),
      );
      return;
    }
    MonthlyForestPreviewSheet.show(context, data: data);
  }

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
              DailyTreeWidget(
                stage: record.completedBlocks,
                assetPath: theme.plantAsset,
                primary: theme.primary,
                height: 120,
                showStageBadge: true,
                animate: false,
              ),
              const SizedBox(height: 12),
              Text(
                '${theme.plantEmoji} ${theme.plantName}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              _detailRow('日等级',
                  '${dayTierFor(record).emoji} ${dayTierFor(record).label}'),
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
              const SizedBox(height: 20),
              OutlineButton(
                label: record.isFullCrown
                    ? '📤 分享这一天的满冠之树'
                    : '📤 分享这一天的进度',
                color: theme.primary,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _shareDay(record);
                },
              ),
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
        actions: [
          if (_records.values.any((r) => r.completedBlocks > 0))
            IconButton(
              onPressed: _shareMonthlyForest,
              tooltip: '分享本月森林长图',
              icon: const Icon(Icons.forest_outlined),
            ),
        ],
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
            child: Column(
              children: [
                Row(
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
                if (_records.values.any((r) => r.completedBlocks > 0)) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _shareMonthlyForest,
                      icon: const Icon(Icons.forest_outlined, size: 18),
                      label: const Text('分享本月自律森林长图'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.primary,
                        side: BorderSide(color: theme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
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
                    onLongPress: _records[key] != null &&
                            _records[key]!.completedBlocks >= 1
                        ? () => _shareDay(_records[key]!)
                        : null,
                  );
                },
              ),
            ),
          ),
          // 图例
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendDot(const Color(0xFFE8B84A), '已收货'),
                    const SizedBox(width: 16),
                    _legendDot(Colors.grey.shade400, '待收货', dashed: true),
                    const SizedBox(width: 16),
                    _legendDot(theme.primary.withValues(alpha: 0.5), '进行中'),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '长按有记录的日子可快速分享',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
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
