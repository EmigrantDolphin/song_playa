import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_playa/api/models/playlist.dart';
import 'package:song_playa/screens/playlists_screen.dart';
import 'package:song_playa/screens/widgets/music_controls_bar.dart';
import 'package:song_playa/services/audio_playback_service.dart';
import 'package:song_playa/api/song_server.dart';
import 'package:song_playa/services/song_storage_service.dart';
import 'package:path/path.dart' as p;

class MusicPlayerScreen extends StatefulWidget {
  final Playlist playlist;
  const MusicPlayerScreen({super.key, required this.playlist});

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
  var _currentSongIndex = 0;

  var _songsToDownload = <Song>[];

  @override
  void initState() {
    super.initState();
    _songServer = context.read<SongServer>();
    _songStorage = context.read<SongStorageService>();
    _audioPlayer = context.read<AudioPlaybackService>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSongsFromStorage();
    });
  }

  void _goToPlaylists() {
    _audioPlayer.stop();
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const PlaylistsScreen()));
    }
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
      var song = _songsToDownload.last;
      await _songStorage.downloadSong(fileName: song.name);

      setState(() {
        _songsToDownload.removeLast();
      });

      print("running loop");
    }

    await _loadSongsFromStorage();
  }

  Future<void> _loadSongsFromStorage() async {
    var files = await _songStorage.listLocalSongs();

    if (!widget.playlist.isAllPlaylist()) {
      files = files
        .where((file) => widget.playlist.songs
          .map((song) => song.name)
          .toList()
          .contains(p.basenameWithoutExtension(file.path)))
        .toList();
    }

    setState(() {
      _loadedSongFiles = files;
    });

    if (_loadedSongFiles.isEmpty) return;

    _audioPlayer.setSongs(_loadedSongFiles);

    _audioPlayer.subscribeToIndexUpdates((index) {
      if (index == null || index >= _loadedSongFiles.length) {
        setState(() {
          _isPlaying = false;
        });
        return;
      }

      setState(() {
        _currentSongIndex = index;
      });
    });
  }

  Future<void> _togglePlayStop() async {
    if (_isPlaying) {
      _audioPlayer.pause();

      setState(() {
        _isPlaying = false;
      });
    } else {
      _audioPlayer.play();

      setState(() {
        _isPlaying = true;
      });
    }
  }

  String _getLoadedSongName(int index) {
    if (_loadedSongFiles.isEmpty) return "Nothing";
    if (_loadedSongFiles.length < index) return "Nothing";

    return p.basenameWithoutExtension(_loadedSongFiles[index].path);
  }

  void _nextSong() {
    _audioPlayer.next();
  }

  void _previousSong() {
    _audioPlayer.previous();
  }

  void _seekSongAtIndex(int index) {
    _audioPlayer.seekSong(index);
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
        child: ListView.builder(
          itemCount: _loadedSongFiles.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_getLoadedSongName(index)),
              tileColor: _isPlaying && _currentSongIndex == index
                  ? Color.fromRGBO(20, 20, 120, 0.1)
                  : null,
              onTap: () => _seekSongAtIndex(index),
            );
          },
        ),
      ),
      bottomNavigationBar: MusicControlsBar(
        onTogglePlayStop: _togglePlayStop,
        onPreviousSong: _previousSong,
        onNextSong: _nextSong,
        onToggleOneSongLoop: _toggleOneSongLoop,
        isPlaying: _isPlaying,
        isOneSongLooping: _isOneSongLooping,
        currentSongName: _getLoadedSongName(_currentSongIndex),
        songsToDownload: _songsToDownload.length,
        onStartDownloadingSong: _startDownloadingSong,
        onGoToPlaylist: _goToPlaylists,
      ),
    );
  }
}
