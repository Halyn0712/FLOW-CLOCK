import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/utils/tree_stage_utils.dart';

/// DailyTree — 随 k=0~8 从底部生长，k=4 半日冠光晕，k=8 满冠金效
class DailyTreeWidget extends StatefulWidget {
  const DailyTreeWidget({
    super.key,
    required this.stage,
    required this.assetPath,
    required this.primary,
    this.height = 160,
    this.animate = true,
    this.showStageBadge = false,
  });

  final int stage;
  final String assetPath;
  final Color primary;
  final double height;
  final bool animate;

  /// 首页可显示「半日冠」「满冠神树」等小标签
  final bool showStageBadge;

  @override
  State<DailyTreeWidget> createState() => _DailyTreeWidgetState();
}

class _DailyTreeWidgetState extends State<DailyTreeWidget>
    with TickerProviderStateMixin {
  late AnimationController _growController;
  late AnimationController _glowController;
  late Animation<double> _growAnim;
  int _displayStage = 0;

  @override
  void initState() {
    super.initState();
    _displayStage = clampTreeStage(widget.stage);
    _growController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _growAnim = AlwaysStoppedAnimation(
      growthFractionForStage(_displayStage),
    );
  }

  @override
  void didUpdateWidget(DailyTreeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newStage = clampTreeStage(widget.stage);
    if (newStage != _displayStage) {
      final from = growthFractionForStage(_displayStage);
      final to = growthFractionForStage(newStage);
      _displayStage = newStage;
      if (widget.animate) {
        _growAnim = Tween<double>(begin: from, end: to).animate(
          CurvedAnimation(parent: _growController, curve: Curves.easeOutCubic),
        );
        _growController.forward(from: 0);
      } else {
        _growAnim = AlwaysStoppedAnimation(to);
      }
    }
  }

  @override
  void dispose() {
    _growController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stage = _displayStage;
    final showHalfGlow = stage >= 4;
    final showCrownGlow = stage >= 8;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          width: widget.height * 0.85,
          child: AnimatedBuilder(
            animation: Listenable.merge([_growAnim, _glowController]),
            builder: (context, _) {
              final fraction = _growAnim.value.clamp(0.05, 1.0);
              final glow = 0.55 + _glowController.value * 0.45;

              return Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  if (stage == 0)
                    Positioned(
                      bottom: 4,
                      child: Text(
                        '🌱',
                        style: TextStyle(fontSize: widget.height * 0.22),
                      ),
                    ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        heightFactor: fraction,
                        child: SvgPicture.asset(
                          widget.assetPath,
                          height: widget.height,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  if (showHalfGlow)
                    Positioned(
                      bottom: widget.height * halfDayGlowHeight - 8,
                      child: _GlowRing(
                        size: widget.height * 0.28,
                        color: widget.primary,
                        opacity: (stage == 4 ? glow : 0.35).clamp(0.2, 0.85),
                      ),
                    ),
                  if (showCrownGlow)
                    Positioned(
                      bottom: widget.height * fullCrownGlowHeight,
                      child: _GlowRing(
                        size: widget.height * 0.32,
                        color: const Color(0xFFE8B84A),
                        opacity: glow.clamp(0.5, 1.0),
                      ),
                    ),
                  if (showCrownGlow)
                    Positioned(
                      bottom: widget.height * fullCrownGlowHeight + 12,
                      child: Text(
                        '✨',
                        style: TextStyle(fontSize: widget.height * 0.14),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        if (widget.showStageBadge) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: widget.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${treeStageEmoji(stage)} ${treeStageLabel(stage)}',
              style: TextStyle(
                fontSize: 12,
                color: widget.primary.darken(0.2),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _GlowRing extends StatelessWidget {
  const _GlowRing({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity),
            blurRadius: size * 0.4,
            spreadRadius: size * 0.05,
          ),
        ],
      ),
    );
  }
}

extension on Color {
  Color darken(double amount) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}
