import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart';

class AudioPlaybackService {
  final _player = AudioPlayer();
  StreamSubscription<int?>? _indexStreamSubscription;

  Future<void> playSong(File songFile) async {
    try {
      await _player.setFilePath(songFile.path);
      await _player.play();
    } catch (e) {
      print("Error playing a song: $e");
    }
  }

  Future<void> playMultipleSongs(List<File> songFiles) async {
    var audioSources = songFiles.map((x) => AudioSource.file(x.path)).toList();
    final playlist = ConcatenatingAudioSource(children: audioSources);
    try {
      await _player.setAudioSource(playlist);
      await _player.play();
    } catch (e) {
      print("Error playing multiple songs: $e");
    }
  }

  Future<void> playSongAtIndex(int index) async {
    try {
      await _player.seek(const Duration(seconds: 0), index: index);
    } catch (e) {
      print("Failed to switch song to index $index, error: $e");
    }
  }

  void pause() => _player.pause();
  void stop() => _player.stop();
  void next() => _player.seekToNext();
  void previous() => _player.seekToPrevious();
  void loopOneSong() => _player.setLoopMode(LoopMode.one);
  void stopLooping() => _player.setLoopMode(LoopMode.off);

  void subscribeToIndexUpdates(void Function(int? index) callback) {
    if (_indexStreamSubscription != null) {
      _indexStreamSubscription?.cancel();
      _indexStreamSubscription = null;
    }

    _indexStreamSubscription = _player.currentIndexStream.listen((index) {
      callback(index);
    });
  }

  void dispose() {
    _indexStreamSubscription?.cancel();
    _player.dispose();
  }
}
