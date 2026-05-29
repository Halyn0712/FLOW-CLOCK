import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/models.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static DailyRecord getTodayRecord() {
    return getRecordForDate(DateTime.now());
  }

  static DailyRecord getRecordForDate(DateTime date) {
    final key = DailyRecord.keyFor(date);
    final raw = _prefs.getString('daily_$key');
    if (raw == null) return DailyRecord(dateKey: key);
    return DailyRecord.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// 返回指定年月的所有有记录的 DailyRecord（含空记录占位由调用方生成）
  static Map<String, DailyRecord> getRecordsForMonth(int year, int month) {
    final result = <String, DailyRecord>{};
    final daysInMonth = DateTime(year, month + 1, 0).day;
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(year, month, d);
      final key = DailyRecord.keyFor(date);
      final raw = _prefs.getString('daily_$key');
      if (raw != null) {
        result[key] =
            DailyRecord.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    }
    return result;
  }

  static Future<void> saveTodayRecord(DailyRecord record) async {
    await _prefs.setString(
      'daily_${record.dateKey}',
      jsonEncode(record.toJson()),
    );
  }

  static ActiveSession? getActiveSession() {
    final raw = _prefs.getString('active_session');
    if (raw == null) return null;
    return ActiveSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static Future<void> saveActiveSession(ActiveSession? session) async {
    if (session == null) {
      await _prefs.remove('active_session');
    } else {
      await _prefs.setString(
        'active_session',
        jsonEncode(session.toJson()),
      );
    }
  }

  static CustomRewardState getRewards() {
    final raw = _prefs.getString('rewards');
    if (raw == null) return CustomRewardState();
    return CustomRewardState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static Future<void> saveRewards(CustomRewardState rewards) async {
    await _prefs.setString('rewards', jsonEncode(rewards.toJson()));
  }

  static AppSettings getSettings() {
    final raw = _prefs.getString('settings');
    if (raw == null) return AppSettings();
    return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setString('settings', jsonEncode(settings.toJson()));
  }
}
