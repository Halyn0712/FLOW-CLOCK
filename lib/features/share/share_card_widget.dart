import 'package:flutter/material.dart';

import 'share_card_data.dart';
import 'share_card_skin.dart';

/// 分享卡 UI（逻辑尺寸 360×480，渲染时 ×3 = 1080×1440）
class ShareCardWidget extends StatelessWidget {
  const ShareCardWidget({
    super.key,
    required this.data,
    this.skin = ShareCardSkin.minimal,
  });

  final ShareCardData data;
  final ShareCardSkin skin;

  static const double cardWidth = 360;
  static const double cardHeight = 480;

  @override
  Widget build(BuildContext context) {
    final palette = ShareCardPalette.forSkin(skin, data);
    final dateStr = data.formattedDate;
    final headerText =
        '${palette.headerPrefix ?? ''}$dateStr  ${data.dayTier.label} ${data.dayTier.emoji}';

    final headline = data.completedBlocks >= 8
        ? '✨🌳 满冠神树 ✨'
        : '${data.theme.plantEmoji} ${data.treeTitle}';

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: palette.background,
          borderRadius: BorderRadius.circular(24),
          border: palette.border,
          boxShadow: [
            BoxShadow(
              color: palette.shadowColor,
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (skin == ShareCardSkin.forest) ..._forestDecor(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                children: [
                  Text(
                    headerText,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: palette.headerColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    headline,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: palette.titleColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    data.theme.plantEmoji,
                    style: TextStyle(
                      fontSize: skin == ShareCardSkin.dark ? 80 : 72,
                      shadows: skin == ShareCardSkin.dark
                          ? [
                              Shadow(
                                color: palette.titleColor.withValues(alpha: 0.4),
                                blurRadius: 16,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '专注 ${data.focusHours} · ${data.completedBlocks} 块 · M=${data.completedBlocks}',
                    style: TextStyle(
                      fontSize: 14,
                      color: palette.bodyColor,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (data.consecutiveClaimDays > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '连续收货 ×${data.consecutiveClaimDays}',
                      style: TextStyle(
                        fontSize: 13,
                        color: palette.subtleColor,
                      ),
                    ),
                  ],
                  if (data.showReflection &&
                      data.reflection != null &&
                      data.reflection!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      '「${data.reflection}」',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: palette.subtleColor,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const Spacer(),
                  Text(
                    '${palette.footerPrefix ?? ''}Flow Clock',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.2,
                      color: palette.watermarkColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _forestDecor() {
    return [
      const Positioned(top: 12, left: 16, child: Text('🌿', style: TextStyle(fontSize: 18))),
      const Positioned(top: 20, right: 20, child: Text('🍃', style: TextStyle(fontSize: 16))),
      const Positioned(bottom: 48, left: 24, child: Text('🌱', style: TextStyle(fontSize: 14))),
      const Positioned(bottom: 56, right: 28, child: Text('🌿', style: TextStyle(fontSize: 16))),
    ];
  }
}
