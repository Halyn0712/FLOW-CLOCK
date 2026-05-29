import 'package:flutter_test/flutter_test.dart';
import 'package:flow_clock/core/utils/ritual_utils.dart';
import 'package:flow_clock/models/enums.dart';

void main() {
  test('block 1 uses 5min micro + 55min flow', () {
    final plan = RitualUtils.planForBlock(1);
    expect(plan.type, RitualType.micro);
    expect(plan.ritualMinutes, 5);
    expect(plan.flowMinutes, 55);
  });

  test('block 4 is direct with 60min flow', () {
    final plan = RitualUtils.planForBlock(4);
    expect(plan.ritualMinutes, 0);
    expect(plan.flowMinutes, 60);
  });

  test('half day anchor after 4 blocks', () {
    expect(RitualUtils.needsHalfDayAnchorAfter(4), isTrue);
    expect(RitualUtils.needsHalfDayAnchorAfter(3), isFalse);
  });
}
