import 'package:flutter_test/flutter_test.dart';

import 'package:flow_clock/core/utils/tree_stage_utils.dart';

void main() {
  group('growthFractionForStage', () {
    test('k=0 最低可见', () {
      expect(growthFractionForStage(0), lessThan(0.15));
    });

    test('k=4 约半高', () {
      expect(growthFractionForStage(4), greaterThan(0.45));
      expect(growthFractionForStage(4), lessThan(0.65));
    });

    test('k=8 满冠', () {
      expect(growthFractionForStage(8), 1.0);
    });

    test('越界 clamp', () {
      expect(growthFractionForStage(99), 1.0);
      expect(growthFractionForStage(-1), growthFractionForStage(0));
    });
  });

  group('milestones', () {
    test('半日冠仅 k=4', () {
      expect(isHalfDayMilestone(4), isTrue);
      expect(isHalfDayMilestone(5), isFalse);
    });

    test('满冠 k>=8', () {
      expect(isFullCrownMilestone(8), isTrue);
      expect(isFullCrownMilestone(7), isFalse);
    });
  });
}
