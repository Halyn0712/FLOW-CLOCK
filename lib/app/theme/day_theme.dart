import 'package:flutter/material.dart';

class DayTheme {
  const DayTheme({
    required this.plantAsset,
    required this.plantName,
    required this.plantEmoji,
    required this.primary,
    required this.background,
  });

  final String plantAsset;
  final String plantName;
  final String plantEmoji;
  final Color primary;
  final Color background;

  static DayTheme forDate(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return const DayTheme(
          plantAsset: 'assets/plants/week/monday_sakura.svg',
          plantName: '樱花',
          plantEmoji: '🌸',
          primary: Color(0xFFFFB7C5),
          background: Color(0xFFFFF5F7),
        );
      case DateTime.tuesday:
        return const DayTheme(
          plantAsset: 'assets/plants/week/tuesday_succulent.svg',
          plantName: '多肉',
          plantEmoji: '🌿',
          primary: Color(0xFF7CB89A),
          background: Color(0xFFF0F7F4),
        );
      case DateTime.wednesday:
        return const DayTheme(
          plantAsset: 'assets/plants/week/wednesday_sunflower.svg',
          plantName: '向日葵',
          plantEmoji: '🌻',
          primary: Color(0xFFF5C842),
          background: Color(0xFFFFFBF0),
        );
      case DateTime.thursday:
        return const DayTheme(
          plantAsset: 'assets/plants/week/thursday_bamboo.svg',
          plantName: '竹子',
          plantEmoji: '🎋',
          primary: Color(0xFF6B9E6B),
          background: Color(0xFFF2F8F2),
        );
      case DateTime.friday:
        return const DayTheme(
          plantAsset: 'assets/plants/week/friday_lavender.svg',
          plantName: '薰衣草',
          plantEmoji: '💜',
          primary: Color(0xFF9B8EC4),
          background: Color(0xFFF5F3FA),
        );
      case DateTime.saturday:
        return const DayTheme(
          plantAsset: 'assets/plants/week/saturday_cactus.svg',
          plantName: '仙人掌',
          plantEmoji: '🌵',
          primary: Color(0xFF5A9A6A),
          background: Color(0xFFF5FAF5),
        );
      case DateTime.sunday:
      default:
        return const DayTheme(
          plantAsset: 'assets/plants/week/sunday_maple.svg',
          plantName: '红枫',
          plantEmoji: '🍁',
          primary: Color(0xFFD4845A),
          background: Color(0xFFFFF8F2),
        );
    }
  }
}
