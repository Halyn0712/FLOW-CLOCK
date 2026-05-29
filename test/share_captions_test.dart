import 'package:flutter_test/flutter_test.dart';

import 'package:flow_clock/features/share/share_captions.dart';
import 'package:flow_clock/features/share/share_card_data.dart';
import 'package:flow_clock/models/models.dart';

void main() {
  test('历史日分享文案含日期', () {
    final data = ShareCardData.fromRecord(
      DailyRecord(
        dateKey: '2026-05-20',
        completedBlocks: 8,
        totalFocusMinutes: 480,
      ),
    );
    expect(data.isHistorical, isTrue);
    final caption = shareCaption(data, ShareCaptionStyle.short);
    expect(caption, contains('2026.05.20'));
    expect(caption, contains('回顾'));
  });

  test('今日分享文案不含回顾', () {
    final now = DateTime.now();
    final data = ShareCardData.fromRecord(
      DailyRecord(
        dateKey: DailyRecord.keyFor(now),
        completedBlocks: 3,
        totalFocusMinutes: 180,
      ),
    );
    expect(data.isHistorical, isFalse);
    final caption = shareCaption(data, ShareCaptionStyle.short);
    expect(caption, contains('今日'));
    expect(caption, isNot(contains('回顾')));
  });
}
