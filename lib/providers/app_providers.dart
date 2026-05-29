import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/audio_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/storage_service.dart';
import '../core/utils/ritual_utils.dart';
import '../models/enums.dart';
import '../models/models.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

final rewardsProvider =
    StateNotifierProvider<RewardsNotifier, CustomRewardState>((ref) {
  return RewardsNotifier();
});

final dailyProvider = StateNotifierProvider<DailyNotifier, DailyRecord>((ref) {
  return DailyNotifier(ref);
});

final sessionProvider =
    StateNotifierProvider<SessionNotifier, ActiveSession?>((ref) {
  return SessionNotifier(ref);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(StorageService.getSettings());

  Future<void> updateHalfDayMinutes(int minutes) async {
    state = AppSettings(
      halfDayAnchorMinutes: minutes,
      dailyGoalBlocks: state.dailyGoalBlocks,
      lastClaimDateKey: state.lastClaimDateKey,
    );
    await StorageService.saveSettings(state);
  }
}

class RewardsNotifier extends StateNotifier<CustomRewardState> {
  RewardsNotifier() : super(StorageService.getRewards());

  Future<void> setTier1(String? text) async {
    state.tier1Text = text;
    await StorageService.saveRewards(state);
    state = CustomRewardState.fromJson(state.toJson());
  }

  Future<void> setTier2(String? text) async {
    state.tier2Text = text;
    await StorageService.saveRewards(state);
    state = CustomRewardState.fromJson(state.toJson());
  }

  Future<void> redeemTier2() async {
    state.tier2Text = null;
    state.tier2Progress = 0;
    await StorageService.saveRewards(state);
    state = CustomRewardState.fromJson(state.toJson());
  }

  Future<void> redeemTier1() async {
    state.tier1Text = null;
    state.tier1Progress = 0;
    await StorageService.saveRewards(state);
    state = CustomRewardState.fromJson(state.toJson());
  }
}

class DailyNotifier extends StateNotifier<DailyRecord> {
  DailyNotifier(this.ref) : super(StorageService.getTodayRecord());

  final Ref ref;

  Future<void> reload() async {
    state = StorageService.getTodayRecord();
  }

  Future<void> completeBlock(int flowMinutes) async {
    state.completedBlocks += 1;
    state.totalFocusMinutes += flowMinutes;
    await StorageService.saveTodayRecord(state);
    state = DailyRecord.fromJson(state.toJson());
  }

  Future<bool> claimDay({String? reflection}) async {
    if (!state.isFullCrown || state.isClaimed) return false;
    state.isClaimed = true;
    state.claimedAt = DateTime.now();
    state.reflection = reflection;
    await StorageService.saveTodayRecord(state);

    final settings = StorageService.getSettings();
    final rewards = StorageService.getRewards();
    final todayKey = state.dateKey;
    final yesterdayKey = DailyRecord.keyFor(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    if (settings.lastClaimDateKey == yesterdayKey) {
      rewards.consecutiveClaimDays += 1;
    } else if (settings.lastClaimDateKey != todayKey) {
      rewards.consecutiveClaimDays = 1;
    }
    rewards.tier1Progress += 1;
    rewards.tier2Progress += 1;

    settings.lastClaimDateKey = todayKey;
    await StorageService.saveSettings(settings);
    await StorageService.saveRewards(rewards);

    ref.read(rewardsProvider.notifier).state =
        CustomRewardState.fromJson(rewards.toJson());
    ref.read(settingsProvider.notifier).state =
        AppSettings.fromJson(settings.toJson());

    state = DailyRecord.fromJson(state.toJson());
    return true;
  }
}

class SessionNotifier extends StateNotifier<ActiveSession?> {
  SessionNotifier(this.ref) : super(StorageService.getActiveSession()) {
    _resumeIfNeeded();
  }

  final Ref ref;
  Timer? _tickTimer;

  void _resumeIfNeeded() {
    if (state?.phaseEndsAt != null &&
        state!.phase != SessionPhase.idle &&
        state!.phase != SessionPhase.done) {
      _startTicker();
      if (DateTime.now().isAfter(state!.phaseEndsAt!)) {
        _onPhaseComplete();
      }
    }
  }

  Future<void> startNextBlock() async {
    final daily = ref.read(dailyProvider);
    if (RitualUtils.needsHalfDayAnchorAfter(daily.completedBlocks)) {
      await _startHalfDayAnchor();
      return;
    }
    final n = daily.nextBlockIndex;
    final plan = RitualUtils.planForBlock(n);
    if (plan.ritualMinutes == 0) {
      await _startFlow(n, plan);
    } else {
      await _startRitual(n, plan);
    }
  }

  Future<void> _startHalfDayAnchor() async {
    final minutes = ref.read(settingsProvider).halfDayAnchorMinutes;
    state = ActiveSession(
      phase: SessionPhase.halfDayAnchor,
      blockIndex: 4,
      phaseEndsAt: DateTime.now().add(Duration(minutes: minutes)),
      breakMinutes: minutes,
    );
    await _persist();
    _startTicker();
  }

  Future<void> _startRitual(int blockIndex, RitualPlan plan) async {
    state = ActiveSession(
      phase: SessionPhase.ritual,
      blockIndex: blockIndex,
      ritualType: plan.type,
      ritualMinutes: plan.ritualMinutes,
      flowMinutes: plan.flowMinutes,
      breakMinutes: plan.breakMinutes,
      phaseEndsAt:
          DateTime.now().add(Duration(minutes: plan.ritualMinutes)),
    );
    await _persist();
    _startTicker();
  }

  Future<void> enterFlowEarly() async {
    if (state?.phase != SessionPhase.ritual) return;
    await _startFlow(state!.blockIndex, RitualPlan(
      state!.ritualType,
      state!.ritualMinutes,
      state!.flowMinutes,
      state!.breakMinutes,
    ));
  }

  Future<void> _startFlow(int blockIndex, RitualPlan plan) async {
    state = ActiveSession(
      phase: SessionPhase.flow,
      blockIndex: blockIndex,
      ritualType: plan.type,
      ritualMinutes: plan.ritualMinutes,
      flowMinutes: plan.flowMinutes,
      breakMinutes: plan.breakMinutes,
      phaseEndsAt: DateTime.now().add(Duration(minutes: plan.flowMinutes)),
    );
    await _persist();
    _startTicker();
  }

  Future<void> skipBreak() async {
    await clearSession();
  }

  Future<void> clearSession() async {
    _tickTimer?.cancel();
    state = null;
    await StorageService.saveActiveSession(null);
  }

  Future<void> _persist() async {
    await StorageService.saveActiveSession(state);
  }

  void _startTicker() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state?.phaseEndsAt == null) return;
      if (DateTime.now().isAfter(state!.phaseEndsAt!)) {
        _onPhaseComplete();
      } else {
        state = ActiveSession.fromJson(state!.toJson());
      }
    });
  }

  Future<void> _onPhaseComplete() async {
    _tickTimer?.cancel();
    final current = state;
    if (current == null) return;

    switch (current.phase) {
      case SessionPhase.ritual:
        // 仪式结束：无声，等待用户手动进入心流
        state = ActiveSession(
          phase: SessionPhase.ritual,
          blockIndex: current.blockIndex,
          ritualType: current.ritualType,
          ritualMinutes: current.ritualMinutes,
          flowMinutes: current.flowMinutes,
          breakMinutes: current.breakMinutes,
          phaseEndsAt: null,
        );
        await _persist();
      case SessionPhase.flow:
        await AudioService.play(AlarmSound.flowEnd);
        await NotificationService.showAlarm('这一块完成了', '站起来走走 🚶');
        await ref
            .read(dailyProvider.notifier)
            .completeBlock(current.flowMinutes);
        if (current.breakMinutes > 0) {
          state = ActiveSession(
            phase: SessionPhase.break,
            blockIndex: current.blockIndex,
            ritualType: current.ritualType,
            flowMinutes: current.flowMinutes,
            breakMinutes: current.breakMinutes,
            phaseEndsAt:
                DateTime.now().add(Duration(minutes: current.breakMinutes)),
          );
          await _persist();
          _startTicker();
        } else if (RitualUtils.needsHalfDayAnchorAfter(
            ref.read(dailyProvider).completedBlocks)) {
          await _startHalfDayAnchor();
        } else {
          await clearSession();
        }
      case SessionPhase.break:
        await AudioService.play(AlarmSound.breakEnd);
        await NotificationService.showAlarm('休息结束', '准备开始下一块');
        await clearSession();
      case SessionPhase.halfDayAnchor:
        await AudioService.play(AlarmSound.halfdayEnd);
        await NotificationService.showAlarm('半日锚点结束', '下午继续 🌤️');
        await clearSession();
      default:
        await clearSession();
    }
  }

  Duration? get remaining {
    if (state?.phaseEndsAt == null) return null;
    final diff = state!.phaseEndsAt!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }
}

final remainingProvider = Provider<Duration?>((ref) {
  ref.watch(sessionProvider);
  return ref.read(sessionProvider.notifier).remaining;
});
