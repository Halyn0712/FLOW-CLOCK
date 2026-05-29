import 'package:flutter/material.dart';

import '../../app/theme/day_theme.dart';
import '../../core/utils/calendar_utils.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import 'monthly_forest_data.dart';

/// 月末森林长图（逻辑宽 360，渲染 ×3 ≈ 1080px 宽）
class MonthlyForestWidget extends StatelessWidget {
  const MonthlyForestWidget({super.key, required this.data});

  final MonthlyForestData data;

  static const double canvasWidth = 360;

  @override
  Widget build(BuildContext context) {
    final theme = data.accentTheme;
    final s = data.stats;

    return SizedBox(
      width: canvasWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.background, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '🌲 ${data.monthLabel}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '本月自律森林',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _statBox(
                      '收货',
                      '${s.claimedDays} 天',
                      theme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _statBox(
                      '专注',
                      formatFocusMinutes(s.totalFocusMinutes),
                      theme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _statBox(
                      '巅峰日',
                      '×${s.peakDays}',
                      const Color(0xFFE8B84A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _statBox(
                      '有记录',
                      '${s.activeDays} 天',
                      theme.primary,
                    ),
                  ),
                ],
              ),
              if (s.hasEfficiencyBadge) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8B84A).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '🏅 高效之月 · 巅峰日 ≥15',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: weekdayLabels
                    .map(
                      (w) => Expanded(
                        child: Center(
                          child: Text(
                            w,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 6),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 0.82,
                ),
                itemCount: data.gridCells.length,
                itemBuilder: (_, i) {
                  final date = data.gridCells[i];
                  if (date == null) return const SizedBox.shrink();
                  return _MiniForestCell(
                    date: date,
                    record: data.recordFor(date),
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendChip(const Color(0xFFE8B84A), '已收货'),
                  const SizedBox(width: 10),
                  _legendChip(Colors.grey.shade400, '待收货'),
                  const SizedBox(width: 10),
                  _legendChip(theme.primary, '进行中'),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Flow Clock',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendChip(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: color, width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
      ],
    );
  }
}

class _MiniForestCell extends StatelessWidget {
  const _MiniForestCell({required this.date, this.record});

  final DateTime date;
  final DailyRecord? record;

  @override
  Widget build(BuildContext context) {
    final theme = DayTheme.forDate(date);
    final r = record;
    final hasData = r != null && r.completedBlocks > 0;
    final status = r?.calendarStatus ?? CalendarDayStatus.empty;

    Color borderColor = Colors.transparent;
    if (status == CalendarDayStatus.claimed) {
      borderColor = const Color(0xFFE8B84A);
    } else if (status == CalendarDayStatus.pendingClaim) {
      borderColor = Colors.grey.shade400;
    } else if (status == CalendarDayStatus.inProgress) {
      borderColor = theme.primary.withValues(alpha: 0.5);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: hasData ? 0.9 : 0.5),
        borderRadius: BorderRadius.circular(6),
        border: borderColor != Colors.transparent
            ? Border.all(color: borderColor, width: 1.2)
            : null,
      ),
      padding: const EdgeInsets.all(2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: TextStyle(fontSize: 9, color: Colors.grey.shade700),
          ),
          if (hasData) ...[
            const SizedBox(height: 1),
            Text(
              theme.plantEmoji,
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'k${r!.completedBlocks}',
              style: TextStyle(fontSize: 8, color: Colors.grey.shade500),
            ),
          ] else
            const SizedBox(height: 14),
        ],
      ),
    );
  }
}
