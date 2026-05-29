import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '半日锚点时长：${settings.halfDayAnchorMinutes} 分钟',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Slider(
            min: 15,
            max: 90,
            divisions: 15,
            label: '${settings.halfDayAnchorMinutes} min',
            value: settings.halfDayAnchorMinutes.toDouble(),
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .updateHalfDayMinutes(v.round()),
          ),
          const SizedBox(height: 8),
          Text(
            '每日目标：${settings.dailyGoalBlocks} 块（8h）',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const Divider(height: 32),
          Text(
            '仪式阶段无提示音；心流/休息/半日/收工有闹钟。',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
