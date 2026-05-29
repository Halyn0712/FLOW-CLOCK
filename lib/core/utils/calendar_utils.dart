/// 生成月历网格：前置空白 + 当月日期
List<DateTime?> buildMonthGrid(int year, int month) {
  final firstDay = DateTime(year, month, 1);
  final daysInMonth = DateTime(year, month + 1, 0).day;
  // weekday: Mon=1 .. Sun=7 → 格子从周一开始
  final leadingEmpty = firstDay.weekday - 1;

  final cells = <DateTime?>[
    ...List.filled(leadingEmpty, null),
  ];
  for (var d = 1; d <= daysInMonth; d++) {
    cells.add(DateTime(year, month, d));
  }
  // 补齐到完整行（7 的倍数）
  while (cells.length % 7 != 0) {
    cells.add(null);
  }
  return cells;
}

String monthTitle(int year, int month) => '$year年$month月';

const weekdayLabels = ['一', '二', '三', '四', '五', '六', '日'];
