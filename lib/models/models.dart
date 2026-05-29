import 'enums.dart';

class DailyRecord {
  DailyRecord({
    required this.dateKey,
    this.completedBlocks = 0,
    this.totalFocusMinutes = 0,
    this.isClaimed = false,
    this.claimedAt,
    this.reflection,
  });

  final String dateKey;
  int completedBlocks;
  int totalFocusMinutes;
  bool isClaimed;
  DateTime? claimedAt;
  String? reflection;

  bool get isFullCrown => completedBlocks >= 8;

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'completedBlocks': completedBlocks,
        'totalFocusMinutes': totalFocusMinutes,
        'isClaimed': isClaimed,
        'claimedAt': claimedAt?.toIso8601String(),
        'reflection': reflection,
      };

  factory DailyRecord.fromJson(Map<String, dynamic> json) => DailyRecord(
        dateKey: json['dateKey'] as String,
        completedBlocks: json['completedBlocks'] as int? ?? 0,
        totalFocusMinutes: json['totalFocusMinutes'] as int? ?? 0,
        isClaimed: json['isClaimed'] as bool? ?? false,
        claimedAt: json['claimedAt'] != null
            ? DateTime.parse(json['claimedAt'] as String)
            : null,
        reflection: json['reflection'] as String?,
      );

  static String keyFor(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  DateTime get date => DateTime.parse(dateKey);

  /// 树阶段 0~8，用于月历缩略展示
  int get treeStage => completedBlocks.clamp(0, 8);

  /// 月历格状态
  CalendarDayStatus get calendarStatus {
    if (completedBlocks == 0) return CalendarDayStatus.empty;
    if (isClaimed) return CalendarDayStatus.claimed;
    if (isFullCrown) return CalendarDayStatus.pendingClaim;
    return CalendarDayStatus.inProgress;
  }
}

enum CalendarDayStatus { empty, inProgress, pendingClaim, claimed }

class ActiveSession {
  ActiveSession({
    this.phase = SessionPhase.idle,
    this.blockIndex = 1,
    this.phaseEndsAt,
    this.ritualType = RitualType.micro,
    this.ritualMinutes = 0,
    this.flowMinutes = 60,
    this.breakMinutes = 5,
    this.pauseCount = 0,
  });

  SessionPhase phase;
  int blockIndex;
  DateTime? phaseEndsAt;
  RitualType ritualType;
  int ritualMinutes;
  int flowMinutes;
  int breakMinutes;
  int pauseCount;

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'blockIndex': blockIndex,
        'phaseEndsAt': phaseEndsAt?.toIso8601String(),
        'ritualType': ritualType.name,
        'ritualMinutes': ritualMinutes,
        'flowMinutes': flowMinutes,
        'breakMinutes': breakMinutes,
        'pauseCount': pauseCount,
      };

  factory ActiveSession.fromJson(Map<String, dynamic> json) => ActiveSession(
        phase: SessionPhase.values.byName(json['phase'] as String),
        blockIndex: json['blockIndex'] as int? ?? 1,
        phaseEndsAt: json['phaseEndsAt'] != null
            ? DateTime.parse(json['phaseEndsAt'] as String)
            : null,
        ritualType:
            RitualType.values.byName(json['ritualType'] as String? ?? 'micro'),
        ritualMinutes: json['ritualMinutes'] as int? ?? 0,
        flowMinutes: json['flowMinutes'] as int? ?? 60,
        breakMinutes: json['breakMinutes'] as int? ?? 5,
        pauseCount: json['pauseCount'] as int? ?? 0,
      );
}

class CustomRewardState {
  CustomRewardState({
    this.tier1Text,
    this.tier2Text,
    this.tier1Progress = 0,
    this.tier2Progress = 0,
    this.consecutiveClaimDays = 0,
  });

  String? tier1Text;
  String? tier2Text;
  int tier1Progress;
  int tier2Progress;
  int consecutiveClaimDays;

  bool get canRedeemTier2 =>
      tier2Progress >= 2 && (tier2Text?.isNotEmpty ?? false);

  bool get canRedeemTier1 =>
      tier1Progress >= 5 && (tier1Text?.isNotEmpty ?? false);

  Map<String, dynamic> toJson() => {
        'tier1Text': tier1Text,
        'tier2Text': tier2Text,
        'tier1Progress': tier1Progress,
        'tier2Progress': tier2Progress,
        'consecutiveClaimDays': consecutiveClaimDays,
      };

  factory CustomRewardState.fromJson(Map<String, dynamic> json) =>
      CustomRewardState(
        tier1Text: json['tier1Text'] as String?,
        tier2Text: json['tier2Text'] as String?,
        tier1Progress: json['tier1Progress'] as int? ?? 0,
        tier2Progress: json['tier2Progress'] as int? ?? 0,
        consecutiveClaimDays: json['consecutiveClaimDays'] as int? ?? 0,
      );
}

class AppSettings {
  AppSettings({
    this.halfDayAnchorMinutes = 30,
    this.dailyGoalBlocks = 8,
    this.lastClaimDateKey,
  });

  int halfDayAnchorMinutes;
  int dailyGoalBlocks;
  String? lastClaimDateKey;

  Map<String, dynamic> toJson() => {
        'halfDayAnchorMinutes': halfDayAnchorMinutes,
        'dailyGoalBlocks': dailyGoalBlocks,
        'lastClaimDateKey': lastClaimDateKey,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        halfDayAnchorMinutes: json['halfDayAnchorMinutes'] as int? ?? 30,
        dailyGoalBlocks: json['dailyGoalBlocks'] as int? ?? 8,
        lastClaimDateKey: json['lastClaimDateKey'] as String?,
      );
}
