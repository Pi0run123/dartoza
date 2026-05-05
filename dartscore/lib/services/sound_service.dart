import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static final AudioPlayer _commentaryPlayer = AudioPlayer();
  static final AudioPlayer _heartbeatPlayer = AudioPlayer();

  static Future<void> playEffect(String assetPath) async {
    await _player.play(AssetSource(assetPath));
  }

  static Future<void> playCommentary(String assetPath) async {
    await _commentaryPlayer.play(AssetSource(assetPath));
  }

  static void startHeartbeat(double pressure) {
    if (pressure > 0.5) {
      _heartbeatPlayer.setReleaseMode(ReleaseMode.loop);
      _heartbeatPlayer.setVolume(pressure);
      _heartbeatPlayer.play(AssetSource('audio/heartbeat.mp3'));
    } else {
      _heartbeatPlayer.stop();
    }
  }

  static void stopHeartbeat() {
    _heartbeatPlayer.stop();
  }

  static void dispose() {
    _player.dispose();
    _commentaryPlayer.dispose();
    _heartbeatPlayer.dispose();
  }
}
