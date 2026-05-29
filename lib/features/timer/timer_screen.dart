import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';
import '../../app/theme/day_theme.dart';
import '../../core/services/audio_service.dart';
import '../../models/enums.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/daily_tree_widget.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final daily = ref.watch(dailyProvider);
    final theme = DayTheme.forDate(DateTime.now());

    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.goHome();
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final remaining = ref.watch(remainingProvider) ?? Duration.zero;
    final isRitualDone =
        session.phase == SessionPhase.ritual && session.phaseEndsAt == null;
    final isRitual = session.phase == SessionPhase.ritual && !isRitualDone;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await ref.read(sessionProvider.notifier).clearSession();
            if (context.mounted) context.goHome();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Text(
              isRitualDone
                  ? '00:00'
                  : isRitual
                      ? formatDuration(remaining)
                      : formatDuration(remaining),
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w300,
                color: Colors.grey.shade800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _phaseSubtitle(session),
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            DailyTreeWidget(
              stage: daily.completedBlocks,
              assetPath: theme.plantAsset,
              primary: theme.primary,
              height: 100,
              animate: false,
            ),
            const Spacer(),
            if (isRitualDone) ...[
              PrimaryButton(
                label: '进入心流',
                color: theme.primary,
                onPressed: () =>
                    ref.read(sessionProvider.notifier).enterFlowEarly(),
              ),
              const SizedBox(height: 12),
              Text(
                '仪式阶段无声提醒 · 准备好了再进入',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ] else if (isRitual) ...[
              OutlineButton(
                label: '进入心流',
                color: theme.primary,
                onPressed: () =>
                    ref.read(sessionProvider.notifier).enterFlowEarly(),
              ),
              const SizedBox(height: 8),
              Text(
                '可随时跳过仪式，直接开始',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ] else if (session.phase == SessionPhase.flow) ...[
              OutlineButton(
                label: '暂停',
                color: theme.primary,
                onPressed: null,
              ),
            ] else ...[
              PrimaryButton(
                label: '结束休息',
                color: theme.primary,
                onPressed: () async {
                  await ref.read(sessionProvider.notifier).skipBreak();
                  if (context.mounted) context.goHome();
                },
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _phaseSubtitle(session) {
    switch (session.phase) {
      case SessionPhase.ritual:
        return '${session.ritualType.label} · 第 ${session.blockIndex} 块';
      case SessionPhase.flow:
        return '心流块 · 第 ${session.blockIndex} 块';
      case SessionPhase.break:
        return '块间休息';
      case SessionPhase.halfDayAnchor:
        return '半日锚点 · 好好休息';
      default:
        return '';
    }
  }
}
