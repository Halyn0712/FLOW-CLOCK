import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app/theme/day_theme.dart';
import '../models/models.dart';

class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.date,
    required this.record,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final DailyRecord? record;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = DayTheme.forDate(date);
    final r = record;
    final hasData = r != null && r.completedBlocks > 0;
    final status = r?.calendarStatus ?? CalendarDayStatus.empty;

    Color borderColor = Colors.transparent;
    double borderWidth = 1.5;
    bool dashed = false;

    if (isToday) {
      borderColor = theme.primary;
      borderWidth = 2;
    } else if (status == CalendarDayStatus.claimed) {
      borderColor = const Color(0xFFE8B84A);
      borderWidth = 2;
    } else if (status == CalendarDayStatus.pendingClaim) {
      borderColor = Colors.grey.shade400;
      dashed = true;
    } else if (status == CalendarDayStatus.inProgress) {
      borderColor = theme.primary.withValues(alpha: 0.4);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: hasData ? 0.9 : 0.5),
          borderRadius: BorderRadius.circular(8),
          border: dashed
              ? null
              : Border.all(color: borderColor, width: borderWidth),
        ),
        child: dashed
            ? CustomPaint(
                painter: _DashedBorderPainter(color: borderColor),
                child: _cellContent(theme, r, hasData),
              )
            : _cellContent(theme, r, hasData),
      ),
    );
  }

  Widget _cellContent(DayTheme theme, DailyRecord? r, bool hasData) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey.shade700,
            ),
          ),
          if (hasData) ...[
            const SizedBox(height: 2),
            Expanded(
              child: Opacity(
                opacity: r!.isClaimed
                    ? 1.0
                    : r.isFullCrown
                        ? 0.45
                        : 0.75,
                child: SvgPicture.asset(
                  theme.plantAsset,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Text(
              'k=${r.completedBlocks}',
              style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const radius = 8.0;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    canvas.drawPath(
      _dashPath(path, dashArray: [4, 3]),
      paint,
    );
  }

  Path _dashPath(Path source, {required List<double> dashArray}) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final len = dashArray[draw ? 0 : 1];
        final next = distance + len;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, next.clamp(0, metric.length)),
            Offset.zero,
          );
        }
        distance = next;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
