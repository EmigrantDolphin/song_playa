
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:song_playa/api/models/playlist.dart';
import 'package:song_playa/api/song_server.dart';
import 'package:song_playa/services/audio_playback_service.dart';
import 'package:song_playa/services/song_storage_service.dart';
import 'package:path/path.dart' as p;

class PlayerScreenViewModel extends ChangeNotifier {
  final SongServer _songServer;
  final SongStorageService _songStorage;
  final AudioPlaybackService _audioPlayer;

  PlayerScreenViewModel({required SongServer songServer, required SongStorageService songStorage, required AudioPlaybackService audioPlayback}) : 
    _songServer = songServer, _songStorage = songStorage, _audioPlayer = audioPlayback;

  var _isPlaying = false;
  bool get isPlaying => _isPlaying;

  var _isOneSongLooping = false;
  bool get isOneSongLooping => _isOneSongLooping;

  var _loadedSongFiles = <File>[];
  List<File> get loadedSongFiles => _loadedSongFiles;

  var _currentSongIndex = 0;
  int get currentSongIndex => _currentSongIndex;

  var _songsToDownload = <Song>[];
  List<Song> get songsToDownload => _songsToDownload;


  Future<void> stopPlaying() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> startDownloadingSong(Playlist playlist) async {
    var songNames = await _songServer.getAllSongNames();
    var previousLocalSongs = await _songStorage.listLocalSongs();
    var previousLocalSongNames = previousLocalSongs.map(
      (x) => p.basename(x.path),
    );
    var newSongs = songNames
        .where((x) => !previousLocalSongNames.contains(x.name))
        .toList();

    _songsToDownload = newSongs;
    notifyListeners();

    while (_songsToDownload.isNotEmpty) {
      var song = _songsToDownload.last;
      await _songStorage.downloadSong(fileName: song.name);

      _songsToDownload.removeLast();
      notifyListeners();

      print("running loop");
    }

    await _songStorage.syncPlaylists();
    await loadSongsFromStorage(playlist);
  }

  Future<void> loadSongsFromStorage(Playlist playlist) async {
    var files = await _songStorage.listLocalSongs();

    if (!playlist.isAllPlaylist()) {
      files = files
        .where((file) => playlist.songs
          .map((song) => song.name)
          .toList()
          .contains(p.basenameWithoutExtension(file.path)))
        .toList();
    }

    _loadedSongFiles = files;
    notifyListeners();

    if (_loadedSongFiles.isEmpty) return;

    _audioPlayer.setSongs(_loadedSongFiles);

    _audioPlayer.subscribeToIndexUpdates((index) {
      if (index == null || index >= _loadedSongFiles.length) {
        _isPlaying = false;
        notifyListeners();
        return;
      }

      _currentSongIndex = index;
      notifyListeners();
    });
  }

  Future<void> togglePlayStop() async {
    if (_isPlaying) {
      _audioPlayer.pause();
      _isPlaying = false;
    } else {
      _audioPlayer.play();
      _isPlaying = true;
    }

    notifyListeners();
  }

  String getLoadedSongName(int index) {
    if (_loadedSongFiles.isEmpty) return "Nothing";
    if (_loadedSongFiles.length < index) return "Nothing";

    return p.basenameWithoutExtension(_loadedSongFiles[index].path);
  }

  void nextSong() {
    _audioPlayer.next();
  }

  void previousSong() {
    _audioPlayer.previous();
  }

  void seekSongAtIndex(int index) {
    _audioPlayer.seekSong(index);
  }

  void toggleOneSongLoop() {
    if (_isOneSongLooping) {
      _audioPlayer.stopLooping();
    } else {
      _audioPlayer.loopOneSong();
    }

    _isOneSongLooping = !_isOneSongLooping;
    notifyListeners();
  }

}