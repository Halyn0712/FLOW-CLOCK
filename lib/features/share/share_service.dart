import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'share_card_data.dart';
import 'share_card_skin.dart';
import 'share_card_widget.dart';
import 'share_captions.dart';

class ShareService {
  /// 从 [RepaintBoundary] 捕获分享卡 PNG
  static Future<Uint8List?> captureFromKey(GlobalKey key) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  static Future<void> shareCard({
    required Uint8List pngBytes,
    required String caption,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/flow_clock_share_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(pngBytes);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'image/png')],
      text: caption,
    );
  }
}

/// 分享预览底部弹层
class SharePreviewSheet extends StatefulWidget {
  const SharePreviewSheet({
    super.key,
    required this.data,
    this.initialReflection,
  });

  final ShareCardData data;
  final String? initialReflection;

  static Future<void> show(
    BuildContext context, {
    required ShareCardData data,
    String? initialReflection,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SharePreviewSheet(
        data: data,
        initialReflection: initialReflection,
      ),
    );
  }

  @override
  State<SharePreviewSheet> createState() => _SharePreviewSheetState();
}

class _SharePreviewSheetState extends State<SharePreviewSheet> {
  final _cardKey = GlobalKey();
  late bool _showReflection;
  ShareCaptionStyle _captionStyle = ShareCaptionStyle.short;
  ShareCardSkin _skin = ShareCardSkin.minimal;
  late final TextEditingController _reflectionController;
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    _showReflection = widget.data.showReflection;
    _reflectionController = TextEditingController(
      text: widget.initialReflection ?? widget.data.reflection ?? '',
    );
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  ShareCardData get _currentData => ShareCardData(
        date: widget.data.date,
        dayTier: widget.data.dayTier,
        theme: widget.data.theme,
        completedBlocks: widget.data.completedBlocks,
        totalFocusMinutes: widget.data.totalFocusMinutes,
        consecutiveClaimDays: widget.data.consecutiveClaimDays,
        reflection: _reflectionController.text.trim().isEmpty
            ? null
            : _reflectionController.text.trim(),
        showReflection: _showReflection,
      );

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      final png = await ShareService.captureFromKey(_cardKey);
      if (png == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('生成分享卡失败，请重试')),
          );
        }
        return;
      }
      final caption = shareCaption(_currentData, _captionStyle);
      await ShareService.shareCard(pngBytes: png, caption: caption);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '预览分享卡',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 0,
                child: RepaintBoundary(
                  key: _cardKey,
                  child: ShareCardWidget(data: _currentData, skin: _skin),
                ),
              ),
              Transform.scale(
                scale: 0.72,
                child: ShareCardWidget(data: _currentData, skin: _skin),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reflectionController,
            maxLines: 2,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '编辑 Reflection（可选）',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '卡片皮肤',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: ShareCardSkin.values.map((s) {
              return ChoiceChip(
                label: Text(s.label),
                selected: _skin == s,
                onSelected: (_) => setState(() => _skin = s),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FilterChip(
                label: const Text('显示 Reflection'),
                selected: _showReflection,
                onSelected: (v) => setState(() => _showReflection = v),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('长文案'),
                selected: _captionStyle == ShareCaptionStyle.long,
                onSelected: (v) => setState(() {
                  _captionStyle =
                      v ? ShareCaptionStyle.long : ShareCaptionStyle.short;
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _sharing ? null : _share,
              child: _sharing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('分享到微信 / 小红书 / …'),
            ),
          ),
        ],
      ),
    );
  }
}
