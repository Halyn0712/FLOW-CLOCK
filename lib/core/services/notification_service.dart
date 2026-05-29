import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../models/enums.dart';

/// 阶段结束闹钟 —— 固定 ID，与 [SessionPhase] 预约通知
class NotificationService {
  static const int phaseAlarmId = 9001;

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    const channel = AndroidNotificationChannel(
      'flow_clock_alarms',
      'Flow Clock 闹钟',
      description: '心流结束、休息结束等提醒',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  static NotificationDetails get _alarmDetails => const NotificationDetails(
        android: AndroidNotificationDetails(
          'flow_clock_alarms',
          'Flow Clock 闹钟',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
        ),
      );

  /// 仪式阶段无声 —— 仅 flow / break / halfDayAnchor 预约
  static bool shouldScheduleForPhase(SessionPhase phase) {
    return phase == SessionPhase.flow ||
        phase == SessionPhase.break ||
        phase == SessionPhase.halfDayAnchor;
  }

  static ({String title, String body}) contentForPhase(SessionPhase phase) {
    switch (phase) {
      case SessionPhase.flow:
        return (title: '这一块完成了', body: '站起来走走 🚶');
      case SessionPhase.break:
        return (title: '休息结束', body: '准备开始下一块');
      case SessionPhase.halfDayAnchor:
        return (title: '半日锚点结束', body: '下午继续 🌤️');
      default:
        return (title: 'Flow Clock', body: '阶段结束');
    }
  }

  /// 在 [at] 时刻触发系统闹钟（App 被杀/锁屏时仍响）
  static Future<void> schedulePhaseAlarm({
    required DateTime at,
    required SessionPhase phase,
  }) async {
    if (!shouldScheduleForPhase(phase)) {
      await cancelPhaseAlarm();
      return;
    }
    if (!at.isAfter(DateTime.now())) {
      await cancelPhaseAlarm();
      return;
    }

    final content = contentForPhase(phase);
    final scheduled = tz.TZDateTime.from(at, tz.local);

    await _plugin.zonedSchedule(
      phaseAlarmId,
      content.title,
      content.body,
      scheduled,
      _alarmDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: phase.name,
    );
  }

  static Future<void> cancelPhaseAlarm() async {
    await _plugin.cancel(phaseAlarmId);
  }

  /// App 在前台时立即提醒（与预约闹钟互补）
  static Future<void> showAlarm(String title, String body) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      _alarmDetails,
    );
  }
}
