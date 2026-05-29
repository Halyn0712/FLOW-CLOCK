import 'package:flutter_test/flutter_test.dart';

import 'package:flow_clock/core/services/notification_service.dart';
import 'package:flow_clock/core/utils/session_recovery_utils.dart';
import 'package:flow_clock/models/enums.dart';

void main() {
  group('shouldScheduleForPhase', () {
    test('心流/休息/半日锚点需预约', () {
      expect(NotificationService.shouldScheduleForPhase(SessionPhase.flow), isTrue);
      expect(NotificationService.shouldScheduleForPhase(SessionPhase.break), isTrue);
      expect(
        NotificationService.shouldScheduleForPhase(SessionPhase.halfDayAnchor),
        isTrue,
      );
    });

    test('仪式无声不预约', () {
      expect(
        NotificationService.shouldScheduleForPhase(SessionPhase.ritual),
        isFalse,
      );
    });
  });

  group('session recovery', () {
    test('未超时阶段应播放 App 内闹钟', () {
      final ends = DateTime.now().add(const Duration(seconds: 2));
      expect(shouldPlayInAppAlarm(ends), isTrue);
    });

    test('超时阶段跳过 App 内闹钟', () {
      final ends = DateTime.now().subtract(const Duration(seconds: 10));
      expect(shouldPlayInAppAlarm(ends), isFalse);
    });

    test('sessionNeedsTicker', () {
      expect(
        sessionNeedsTicker(
          SessionPhase.flow,
          DateTime.now().add(const Duration(minutes: 5)),
        ),
        isTrue,
      );
      expect(sessionNeedsTicker(SessionPhase.ritual, null), isFalse);
    });
  });
}
