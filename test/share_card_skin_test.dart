import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow_clock/app/theme/day_theme.dart';
import 'package:flow_clock/core/utils/day_tier_utils.dart';
import 'package:flow_clock/features/share/share_card_data.dart';
import 'package:flow_clock/features/share/share_card_skin.dart';

void main() {
  test('三套皮肤均可生成调色板', () {
    final data = ShareCardData(
      date: DateTime(2026, 5, 29),
      dayTier: DayTier.peak,
      theme: DayTheme.forDate(DateTime(2026, 5, 29)),
      completedBlocks: 8,
      totalFocusMinutes: 480,
      consecutiveClaimDays: 3,
    );

    for (final skin in ShareCardSkin.values) {
      final palette = ShareCardPalette.forSkin(skin, data);
      expect(palette.titleColor, isNotNull);
      expect(palette.background, isNotNull);
    }
  });

  test('深色满冠使用金色强调', () {
    final data = ShareCardData(
      date: DateTime(2026, 5, 29),
      dayTier: DayTier.peak,
      theme: DayTheme.forDate(DateTime(2026, 5, 29)),
      completedBlocks: 8,
      totalFocusMinutes: 480,
      consecutiveClaimDays: 0,
    );
    final palette = ShareCardPalette.forSkin(ShareCardSkin.dark, data);
    expect(palette.titleColor, const Color(0xFFE8C547));
  });
}
