/// k = 今日已完成块数，取值 0~8
/// [stageGrowthFraction] = 植物可视高度比例（从底部向上「长出来」）
const List<double> stageGrowthFractions = [
  0.08, // k=0 破土
  0.18, // k=1 发芽
  0.30, // k=2 抽枝
  0.42, // k=3 展叶
  0.54, // k=4 半日冠
  0.66, // k=5 疏枝
  0.78, // k=6 含苞
  0.90, // k=7 开花
  1.00, // k=8 满冠
];

int clampTreeStage(int stage) => stage.clamp(0, 8);

double growthFractionForStage(int stage) {
  return stageGrowthFractions[clampTreeStage(stage)];
}

/// 是否半日冠里程碑（k=4）
bool isHalfDayMilestone(int stage) => stage == 4;

/// 是否满冠里程碑（k=8）
bool isFullCrownMilestone(int stage) => stage >= 8;

String treeStageLabel(int stage) {
  switch (clampTreeStage(stage)) {
    case 0:
      return '破土';
    case 1:
      return '发芽';
    case 2:
      return '抽枝';
    case 3:
      return '展叶';
    case 4:
      return '半日冠';
    case 5:
      return '疏枝';
    case 6:
      return '含苞';
    case 7:
      return '开花';
    case 8:
      return '满冠神树';
    default:
      return '';
  }
}

String treeStageEmoji(int stage) {
  switch (clampTreeStage(stage)) {
    case 0:
      return '🌱';
    case 1:
      return '🌱';
    case 2:
      return '🌿';
    case 3:
      return '🍃';
    case 4:
      return '🌳';
    case 5:
      return '🌳';
    case 6:
      return '🌳';
    case 7:
      return '🌸';
    case 8:
      return '✨';
    default:
      return '🌱';
  }
}

/// 树腰发光位置（相对高度 0~1，从底部算）
const double halfDayGlowHeight = 0.54;

/// 树冠金冠位置
const double fullCrownGlowHeight = 0.92;
