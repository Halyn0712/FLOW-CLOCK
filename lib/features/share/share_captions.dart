import 'share_card_data.dart';

enum ShareCaptionStyle { short, long }

String shareCaption(ShareCardData data, ShareCaptionStyle style) {
  final focus = data.focusHours;
  final blocks = data.completedBlocks;
  final dayRef = data.isHistorical ? data.formattedDate : '今日';

  switch (style) {
    case ShareCaptionStyle.short:
      if (blocks >= 8) {
        return data.isHistorical
            ? '🌳 $dayRef 自律之树满冠\n$focus 专注 · $blocks 块心流\nFlow Clock 回顾 ✨'
            : '🌳 今日自律之树满冠了！\n$focus 专注 · $blocks 块心流\nFlow Clock 见证我的成长 ✨';
      }
      return data.isHistorical
          ? '🌱 $dayRef 自律记录 $blocks 块 · $focus\nFlow Clock 回顾 ✨'
          : '🌱 今日自律进度 $blocks/$focus\nFlow Clock 见证我的成长 ✨';
    case ShareCaptionStyle.long:
      if (blocks >= 8) {
        return data.isHistorical
            ? '''回顾 $dayRef，这棵自律之树满冠了 🌳✨

📊 $focus 深度专注 · $blocks 个心流块
🌱 那天的节奏，树记得

#FlowClock #自律 #专注 #心流 #回顾'''
            : '''今天把这棵自律之树养满了 🌳✨

📊 $focus 深度专注 · $blocks 个心流块
🌱 从微启动到满冠，没有逼自己，但树长成了

自律不是硬扛，是找到属于自己的节奏。

#FlowClock #自律 #专注 #心流 #今日之树 #高效工作日''';
      }
      return data.isHistorical
          ? '''回顾 $dayRef 的自律之树 🌱

📊 已完成 $blocks 块 · $focus 专注
🌳 每一天的积累，都算数

#FlowClock #自律 #专注 #心流 #回顾'''
          : '''今日自律之树正在生长 🌱

📊 已完成 $blocks 块 · $focus 专注
🌳 一点点积累，树会越长越高

#FlowClock #自律 #专注 #心流''';
  }
}
