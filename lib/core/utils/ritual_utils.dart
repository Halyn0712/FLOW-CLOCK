import '../models/enums.dart';
import '../models/models.dart';

/// 根据块序号 n 计算仪式类型与时长
class RitualUtils {
  static RitualPlan planForBlock(int blockIndex) {
    switch (blockIndex) {
      case 1:
        return const RitualPlan(RitualType.micro, 5, 55, 5);
      case 2:
        return const RitualPlan(RitualType.bridge, 10, 50, 10);
      case 3:
        return const RitualPlan(RitualType.lite, 5, 55, 5);
      case 4:
        return const RitualPlan(RitualType.direct, 0, 60, 0);
      case 5:
        return const RitualPlan(RitualType.reboot, 3, 57, 5);
      default:
        return const RitualPlan(RitualType.direct, 0, 60, 5);
    }
  }

  static String startButtonLabel(int nextBlock, RitualType type) {
    if (nextBlock == 1) return '🚀 开始第一块 · 微启动 5min';
    if (nextBlock == 2) return '🌉 开始第二块 · 桥接 10min';
    if (nextBlock == 3) return '🍃 开始第三块 · 轻过渡 5min';
    if (nextBlock == 4) return '⚡ 开始第四块 · 上午收官';
    if (nextBlock == 5) return '🌅 开始第五块 · 午后重启 3min';
    return '⚡ 继续第 $nextBlock 块';
  }

  static bool needsHalfDayAnchorAfter(int completedBlocks) =>
      completedBlocks == 4;
}

class RitualPlan {
  const RitualPlan(
    this.type,
    this.ritualMinutes,
    this.flowMinutes,
    this.breakMinutes,
  );

  final RitualType type;
  final int ritualMinutes;
  final int flowMinutes;
  final int breakMinutes;
}

extension DailyRecordX on DailyRecord {
  int get nextBlockIndex => completedBlocks + 1;
}
