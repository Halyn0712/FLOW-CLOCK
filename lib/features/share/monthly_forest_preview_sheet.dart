import 'package:flutter/material.dart';

import 'monthly_forest_captions.dart';
import 'monthly_forest_data.dart';
import 'monthly_forest_widget.dart';
import 'share_service.dart';

/// 月末森林长图预览与分享
class MonthlyForestPreviewSheet extends StatefulWidget {
  const MonthlyForestPreviewSheet({super.key, required this.data});

  final MonthlyForestData data;

  static Future<void> show(
    BuildContext context, {
    required MonthlyForestData data,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MonthlyForestPreviewSheet(data: data),
    );
  }

  @override
  State<MonthlyForestPreviewSheet> createState() =>
      _MonthlyForestPreviewSheetState();
}

class _MonthlyForestPreviewSheetState extends State<MonthlyForestPreviewSheet> {
  final _captureKey = GlobalKey();
  bool _longCaption = false;
  bool _sharing = false;

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      final png = await ShareService.captureFromKey(_captureKey);
      if (png == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('生成长图失败，请重试')),
          );
        }
        return;
      }
      await ShareService.shareCard(
        pngBytes: png,
        caption: monthlyForestCaption(widget.data, long: _longCaption),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final maxH = MediaQuery.sizeOf(context).height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '预览 · 本月自律森林长图',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Opacity(
                    opacity: 0,
                    child: RepaintBoundary(
                      key: _captureKey,
                      child: MonthlyForestWidget(data: widget.data),
                    ),
                  ),
                  Transform.scale(
                    scale: 0.55,
                    alignment: Alignment.topCenter,
                    child: MonthlyForestWidget(data: widget.data),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 12 + bottom),
            child: Column(
              children: [
                FilterChip(
                  label: const Text('长文案'),
                  selected: _longCaption,
                  onSelected: (v) => setState(() => _longCaption = v),
                ),
                const SizedBox(height: 8),
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
                        : const Text('分享本月森林长图'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
