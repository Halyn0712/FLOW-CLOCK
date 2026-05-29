import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../widgets/common_widgets.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  final _tier1Controller = TextEditingController();
  final _tier2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rewards = ref.read(rewardsProvider);
      _tier1Controller.text = rewards.tier1Text ?? '';
      _tier2Controller.text = rewards.tier2Text ?? '';
    });
  }

  @override
  void dispose() {
    _tier1Controller.dispose();
    _tier2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rewards = ref.watch(rewardsProvider);
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('我的奖励')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '🔥 连续收货 ${rewards.consecutiveClaimDays} 天',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            '须 8h 满冠 + 确认收货才计数',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          _RewardCard(
            title: '🥈 二级奖励（连续收货 2 天）',
            controller: _tier2Controller,
            progress: rewards.tier2Progress,
            goal: 2,
            canRedeem: rewards.canRedeemTier2,
            onSave: () => ref
                .read(rewardsProvider.notifier)
                .setTier2(_tier2Controller.text.trim()),
            onRedeem: () async {
              await ref.read(rewardsProvider.notifier).redeemTier2();
              _tier2Controller.clear();
              if (mounted) setState(() {});
            },
          ),
          const SizedBox(height: 16),
          _RewardCard(
            title: '🥇 一级奖励（连续收货 5 天）',
            controller: _tier1Controller,
            progress: rewards.tier1Progress,
            goal: 5,
            canRedeem: rewards.canRedeemTier1,
            onSave: () => ref
                .read(rewardsProvider.notifier)
                .setTier1(_tier1Controller.text.trim()),
            onRedeem: () async {
              await ref.read(rewardsProvider.notifier).redeemTier1();
              _tier1Controller.clear();
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.title,
    required this.controller,
    required this.progress,
    required this.goal,
    required this.canRedeem,
    required this.onSave,
    required this.onRedeem,
  });

  final String title;
  final TextEditingController controller;
  final int progress;
  final int goal;
  final bool canRedeem;
  final VoidCallback onSave;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: '+ 设置你的奖励',
              suffixIcon: IconButton(
                icon: const Icon(Icons.check),
                onPressed: onSave,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          CapsuleProgressBar(
            progress: progress / goal,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 6),
          Text('$progress / $goal'),
          if (canRedeem) ...[
            const SizedBox(height: 12),
            FilledButton(onPressed: onRedeem, child: const Text('兑换')),
          ],
        ],
      ),
    );
  }
}
