import 'package:flutter/material.dart';

import '../../app/theme/day_theme.dart';
import 'share_card_data.dart';

/// 分享卡皮肤：简约 / 森林插画 / 深色
enum ShareCardSkin { minimal, forest, dark }

extension ShareCardSkinInfo on ShareCardSkin {
  String get label {
    switch (this) {
      case ShareCardSkin.minimal:
        return '简约';
      case ShareCardSkin.forest:
        return '森林';
      case ShareCardSkin.dark:
        return '深色';
    }
  }
}

/// 各皮肤的配色与装饰
class ShareCardPalette {
  const ShareCardPalette({
    required this.background,
    required this.headerColor,
    required this.titleColor,
    required this.bodyColor,
    required this.subtleColor,
    required this.watermarkColor,
    required this.shadowColor,
    this.border,
    this.headerPrefix,
    this.footerPrefix,
  });

  final Gradient background;
  final Color headerColor;
  final Color titleColor;
  final Color bodyColor;
  final Color subtleColor;
  final Color watermarkColor;
  final Color shadowColor;
  final BoxBorder? border;
  final String? headerPrefix;
  final String? footerPrefix;

  static ShareCardPalette forSkin(ShareCardSkin skin, ShareCardData data) {
    final theme = data.theme;
    final isCrown = data.completedBlocks >= 8;

    switch (skin) {
      case ShareCardSkin.minimal:
        return ShareCardPalette(
          background: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.background, Colors.white],
          ),
          headerColor: Colors.grey.shade700,
          titleColor: theme.primary.darken(0.25),
          bodyColor: Colors.grey.shade700,
          subtleColor: Colors.grey.shade600,
          watermarkColor: Colors.grey.shade400,
          shadowColor: theme.primary.withValues(alpha: 0.25),
        );

      case ShareCardSkin.forest:
        return ShareCardPalette(
          background: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9), Color(0xFFFFFDE7)],
          ),
          headerColor: const Color(0xFF4A6741),
          titleColor: const Color(0xFF2E5C3E),
          bodyColor: const Color(0xFF5A6B52),
          subtleColor: const Color(0xFF6B7B63),
          watermarkColor: const Color(0xFF8FA888),
          shadowColor: const Color(0xFF6B9E6B).withValues(alpha: 0.35),
          border: Border.all(color: theme.primary.withValues(alpha: 0.55), width: 2),
          headerPrefix: '🌲 ',
          footerPrefix: '🍃 ',
        );

      case ShareCardSkin.dark:
        final accent = isCrown
            ? const Color(0xFFE8C547)
            : theme.primary.lighten(0.15);
        return ShareCardPalette(
          background: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2D2D3A), Color(0xFF1A1A24)],
          ),
          headerColor: const Color(0xFFB8B8C8),
          titleColor: accent,
          bodyColor: const Color(0xFFD8D8E0),
          subtleColor: const Color(0xFF9E9EAE),
          watermarkColor: const Color(0xFF6E6E7E),
          shadowColor: accent.withValues(alpha: 0.35),
          border: Border.all(
            color: accent.withValues(alpha: 0.45),
            width: 1.5,
          ),
          headerPrefix: isCrown ? '✨ ' : null,
        );
    }
  }
}

extension on Color {
  Color darken(double amount) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  Color lighten(double amount) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }
}
