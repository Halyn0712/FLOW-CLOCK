import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';
import '../../app/theme/day_theme.dart';
import '../../core/services/audio_service.dart';
import '../../models/enums.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/daily_tree_widget.dart';
import '../share/share_card_data.dart';
import '../share/share_service.dart';

class CloseDayScreen extends ConsumerStatefulWidget {
  const CloseDayScreen({super.key});

  @override
  ConsumerState<CloseDayScreen> createState() => _CloseDayScreenState();
}

class _CloseDayScreenState extends ConsumerState<CloseDayScreen> {
  final _reflectionController = TextEditingController();

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  Future<void> _claim() async {
    final ok = await ref.read(dailyProvider.notifier).claimDay(
          reflection: _reflectionController.text.trim().isEmpty
              ? null
              : _reflectionController.text.trim(),
        );
    if (ok) {
      await AudioService.play(AlarmSound.dayComplete);
    }
    if (mounted) setState(() {});
  }

  Future<void> _openShare() async {
    final daily = ref.read(dailyProvider);
    final rewards = ref.read(rewardsProvider);
    if (daily.completedBlocks < 1) return;

    await SharePreviewSheet.show(
      context,
      data: ShareCardData.fromDaily(daily: daily, rewards: rewards),
      initialReflection: _reflectionController.text.trim().isEmpty
          ? daily.reflection
          : _reflectionController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = DayTheme.forDate(DateTime.now());
    final daily = ref.watch(dailyProvider);
    final rewards = ref.watch(rewardsProvider);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.goHome(),
        ),
        title: const Text('收工仪式'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            const Text('✨', style: TextStyle(fontSize: 32)),
            DailyTreeWidget(
              stage: daily.completedBlocks,
              assetPath: theme.plantAsset,
              primary: theme.primary,
              height: 160,
              showStageBadge: daily.completedBlocks >= 4,
            ),
            const SizedBox(height: 16),
            Text(
              daily.isFullCrown ? '满冠神树' : '今日之树',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '${daily.completedBlocks} 块 · ${formatFocusMinutes(daily.totalFocusMinutes)}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (!daily.isFullCrown) ...[
              const SizedBox(height: 12),
              Text(
                '满冠（8h）后才可确认收货',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
            const SizedBox(height: 24),
            TextField(
              controller: _reflectionController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: '写一句今日 Reflection（可选）',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const Spacer(),
            if (daily.isFullCrown && !daily.isClaimed)
              PrimaryButton(
                label: '🌳 确认收货 · 今日之树',
                color: theme.primary,
                onPressed: _claim,
              )
            else if (daily.isClaimed)
              Text(
                '✅ 已收货 · 连续 ${rewards.consecutiveClaimDays} 天',
                style: TextStyle(color: theme.primary, fontSize: 16),
              ),
            const SizedBox(height: 12),
            OutlineButton(
              label: daily.isFullCrown
                  ? '📤 分享我的自律之树'
                  : '📤 分享今日进度',
              color: theme.primary,
              onPressed:
                  daily.completedBlocks >= 1 ? _openShare : null,
            ),
            const SizedBox(height: 8),
            if (daily.isFullCrown && !daily.isClaimed)
              TextButton(
                onPressed: () => context.goHome(),
                child: Text(
                  '跳过，今日不计入收货',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
