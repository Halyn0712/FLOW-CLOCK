import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/calendar/calendar_screen.dart';
import '../features/close/close_day_screen.dart';
import '../features/home/home_screen.dart';
import '../features/rewards/rewards_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/timer/timer_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/timer', builder: (_, __) => const TimerScreen()),
    GoRoute(path: '/close', builder: (_, __) => const CloseDayScreen()),
    GoRoute(path: '/rewards', builder: (_, __) => const RewardsScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
  ],
);

extension GoContext on BuildContext {
  void goHome() => go('/');
  void goTimer() => push('/timer');
  void goClose() => push('/close');
  void goRewards() => push('/rewards');
  void goSettings() => push('/settings');
  void goCalendar() => push('/calendar');
}
