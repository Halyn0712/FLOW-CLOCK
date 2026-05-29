enum SessionPhase { idle, ritual, flow, break, halfDayAnchor, done }

enum RitualType { micro, bridge, lite, direct, reboot }

enum AlarmSound { flowEnd, breakEnd, halfdayEnd, dayComplete }

extension SessionPhaseLabel on SessionPhase {
  String get label {
    switch (this) {
      case SessionPhase.idle:
        return '待开始';
      case SessionPhase.ritual:
        return '启动仪式';
      case SessionPhase.flow:
        return '心流块';
      case SessionPhase.break:
        return '块间休息';
      case SessionPhase.halfDayAnchor:
        return '半日锚点';
      case SessionPhase.done:
        return '已完成';
    }
  }
}

extension RitualTypeLabel on RitualType {
  String get label {
    switch (this) {
      case RitualType.micro:
        return '微启动';
      case RitualType.bridge:
        return '桥接过渡';
      case RitualType.lite:
        return '轻过渡';
      case RitualType.direct:
        return '直启';
      case RitualType.reboot:
        return '午后重启';
    }
  }
}
