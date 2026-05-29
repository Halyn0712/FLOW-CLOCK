import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';
import '../../app/theme/day_theme.dart';
import '../../core/utils/ritual_utils.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common_widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(dailyProvider.notifier).reload();
      final session = ref.read(sessionProvider);
      if (session != null && mounted) context.goTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = DayTheme.forDate(DateTime.now());
    final daily = ref.watch(dailyProvider);
    final rewards = ref.watch(rewardsProvider);
    final settings = ref.watch(settingsProvider);
    final nextBlock = daily.nextBlockIndex;
    final progress = daily.completedBlocks / settings.dailyGoalBlocks;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Flow Clock',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.goRewards(),
                        icon: const Text('🎁', style: TextStyle(fontSize: 22)),
                      ),
                      IconButton(
                        onPressed: () => context.goSettings(),
                        icon: Icon(Icons.settings_outlined,
                            color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          PlantWidget(assetPath: theme.plantAsset, height: 160),
                          const SizedBox(height: 12),
                          Text(
                            '${theme.plantEmoji} ${theme.plantName}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CapsuleProgressBar(
                            progress: progress,
                            color: theme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'k=${daily.completedBlocks}/${settings.dailyGoalBlocks}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '今日专注 ${formatFocusMinutes(daily.totalFocusMinutes)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '🔥 连续收货 ${rewards.consecutiveClaimDays} 天',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (daily.isFullCrown && !daily.isClaimed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PrimaryButton(
                    label: '🌳 确认收货 · 今日之树',
                    color: theme.primary,
                    onPressed: () => context.goClose(),
                  ),
                )
              else if (daily.isFullCrown && daily.isClaimed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlineButton(
                    label: '✨ 今日已收货 · 查看收工',
                    color: theme.primary,
                    onPressed: () => context.goClose(),
                  ),
                )
              else
                PrimaryButton(
                  label: RitualUtils.needsHalfDayAnchorAfter(daily.completedBlocks)
                      ? '🍱 半日锚点 · 休息 ${settings.halfDayAnchorMinutes}min'
                      : RitualUtils.startButtonLabel(
                          nextBlock,
                          RitualUtils.planForBlock(nextBlock).type,
                        ),
                  color: theme.primary,
                  onPressed: daily.completedBlocks >= settings.dailyGoalBlocks
                      ? () => context.goClose()
                      : () async {
                          await ref
                              .read(sessionProvider.notifier)
                              .startNextBlock();
                          if (context.mounted) context.goTimer();
                        },
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => context.goCalendar(),
                    child: Text('🗓 月历', style: TextStyle(color: theme.primary)),
                  ),
                  TextButton(
                    onPressed: () => context.goRewards(),
                    child: Text('奖励进度 →',
                        style: TextStyle(color: theme.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
