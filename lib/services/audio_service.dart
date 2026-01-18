import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playAsset(String assetPath) async {
    try {
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      // Audio file might not exist yet, silently fail
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}
