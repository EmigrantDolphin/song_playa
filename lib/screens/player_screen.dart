import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_playa/services/audio_playback_service.dart';
import 'package:song_playa/services/song_server.dart';
import 'package:song_playa/services/song_storage_service.dart';
import 'package:path/path.dart' as p;

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  late final SongServer _songServer;
  late final SongStorageService _songStorage;
  late final AudioPlaybackService _audioPlayer;
  var _isPlaying = false;
  var _isOneSongLooping = false;
  var _loadedSongFiles = <File>[];
  var _currentSongName = "Nothing";

  var _songsToDownload = <String>[];

  @override
  void initState() {
    super.initState();
    _songServer = context.read<SongServer>();
    _songStorage = context.read<SongStorageService>();
    _audioPlayer = context.read<AudioPlaybackService>();
  }

  Future<void> _startDownloadingSong() async {
    var songNames = await _songServer.getAllSongNames();
    var previousLocalSongs = await _songStorage.listLocalSongs();
    var previousLocalSongNames = previousLocalSongs.map(
      (x) => p.basename(x.path),
    );
    var newSongs = songNames
        .where((x) => !previousLocalSongNames.contains(x))
        .toList();

    setState(() {
      _songsToDownload = newSongs;
    });

    while (_songsToDownload.isNotEmpty) {
      var songName = _songsToDownload.last;
      await _songStorage.downloadSong(fileName: songName);

      setState(() {
        _songsToDownload.removeLast();
      });

      print("running loop");
    }
  }

  Future<void> _togglePlayStop() async {
    if (_loadedSongFiles.isEmpty) {
      var files = await _songStorage.listLocalSongs();
      setState(() {
        _loadedSongFiles = files;
      });

      if (_loadedSongFiles.isEmpty) return;
    }

    if (_isPlaying) {
      _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      // _audioPlayer.playSong(_loadedSongFiles[0]);
      _audioPlayer.playMultipleSongs(_loadedSongFiles);
      _audioPlayer.subscribeToIndexUpdates((index) {
        if (index == null || index >= _loadedSongFiles.length) {
          setState(() {
            _isPlaying = false;
          });
          return;
        }

        var currentSong = _loadedSongFiles[index];
        setState(() {
          _currentSongName = p.basenameWithoutExtension(currentSong.path);
        });
      });
      setState(() {
        _isPlaying = true;
      });
    }
  }

  void _nextSong() {
    _audioPlayer.next();
  }

  void _previousSong() {
    _audioPlayer.previous();
  }

  void _toggleOneSongLoop() {
    if (_isOneSongLooping) {
      _audioPlayer.stopLooping();
    } else {
      _audioPlayer.loopOneSong();
    }

    setState(() {
      _isOneSongLooping = !_isOneSongLooping;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Songs left to download: ${_songsToDownload.length}"),
            IconButton(
              iconSize: 48,
              icon: const Icon(Icons.download),
              onPressed: _startDownloadingSong,
            ),
            // Song Name Label
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _currentSongName,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),

            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous Button
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.skip_previous),
                  onPressed: _previousSong,
                ),

                // Play/Stop Button
                IconButton(
                  iconSize: 64,
                  // Using play_arrow, could be swapped for Icons.stop or Icons.pause based on state later
                  icon: !_isPlaying
                      ? const Icon(Icons.play_arrow)
                      : const Icon(Icons.pause),
                  onPressed: _togglePlayStop,
                ),

                // Next Button
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.skip_next),
                  onPressed: _nextSong,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 48,
                  icon: _isOneSongLooping
                      ? const Icon(Icons.loop)
                      : const Icon(Icons.loop, color: Color.fromRGBO(100, 200, 100, 1)),
                  onPressed: _toggleOneSongLoop,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
