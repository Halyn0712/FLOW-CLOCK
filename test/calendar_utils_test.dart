import 'package:flutter_test/flutter_test.dart';
import 'package:flow_clock/core/utils/calendar_utils.dart';

void main() {
  test('May 2026 grid starts on Friday', () {
    final cells = buildMonthGrid(2026, 5);
    // 2026-05-01 is Friday → 4 leading nulls (Mon-Thu)
    expect(cells[0], isNull);
    expect(cells[3], isNull);
    expect(cells[4]?.day, 1);
  });

  test('grid length is multiple of 7', () {
    final cells = buildMonthGrid(2026, 5);
    expect(cells.length % 7, 0);
  });
}
