import '../../models/enums.dart';

/// 阶段是否已超时（用于避免恢复时重复响铃）
bool isPhaseOverdue(DateTime? phaseEndsAt, {Duration grace = const Duration(seconds: 5)}) {
  if (phaseEndsAt == null) return false;
  return DateTime.now().difference(phaseEndsAt) > grace;
}

/// 是否应在 App 内播放声音/弹通知（刚结束 vs 很久前已结束）
bool shouldPlayInAppAlarm(DateTime? phaseEndsAt) {
  return !isPhaseOverdue(phaseEndsAt);
}

bool sessionNeedsTicker(SessionPhase phase, DateTime? phaseEndsAt) {
  return phaseEndsAt != null &&
      phase != SessionPhase.idle &&
      phase != SessionPhase.done;
}
