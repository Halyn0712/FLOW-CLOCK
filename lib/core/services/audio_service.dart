import 'package:audioplayers/audioplayers.dart';

import '../../models/enums.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> init() async {
    await _player.setReleaseMode(ReleaseMode.stop);
  }

  static Future<void> play(AlarmSound sound) async {
    final asset = switch (sound) {
      AlarmSound.flowEnd => 'audio/flow_end.wav',
      AlarmSound.breakEnd => 'audio/break_end.wav',
      AlarmSound.halfdayEnd => 'audio/halfday_end.wav',
      AlarmSound.dayComplete => 'audio/day_complete.wav',
    };
    await _player.stop();
    await _player.play(AssetSource(asset));
  }
}
