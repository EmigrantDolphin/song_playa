import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_playa/services/song_server.dart';
import 'package:song_playa/services/song_storage_service.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  late final SongServer _songServer;
  late final SongStorageService _songStorage;
  var _isPlaying = false;
  var _currentSongIndex = 0;
  var _songs = ["song one", "song two", "song three"];

  var _songsToDownload = <String>[];

  @override
  void initState() {
    super.initState();
    _songServer = context.read<SongServer>();
    _songStorage = context.read<SongStorageService>();
  }

  Future<void> _startDownloadingSong() async {
    var songNames = await _songServer.getAllSongNames();
    setState(() {
      _songsToDownload = songNames;
    });


    while (_songsToDownload.isNotEmpty) {
      var songName = _songsToDownload.last;
      await _songStorage.downloadSong(fileName: songName);

      setState(() {
        _songsToDownload.removeLast();
      });

      print("running loop");
    }

    var files = await _songStorage.listLocalSongs();
    print("local files: ${files.map((x) => x.path).toList()}");

  }

  // Empty logic functions as requested
  void _togglePlayStop() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _nextSong() {
    setState(() {
      if (_songs.length <= _currentSongIndex + 1) {
        _currentSongIndex = 0;
      } else {
        _currentSongIndex += 1;
      }
    });
  }

  void _previousSong() {
    setState(() {
      if (_currentSongIndex - 1 < 0) {
        _currentSongIndex = _songs.length - 1;
      } else {
        _currentSongIndex -= 1;
      }
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
                _songs[_currentSongIndex],
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
          ],
        ),
      ),
    );
  }
}
