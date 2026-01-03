
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:song_playa/api/models/playlist.dart';
import 'package:song_playa/services/song_storage_service.dart';

class PlaylistsScreenViewModel extends ChangeNotifier {
  final SongStorageService _songStorage;

  PlaylistsScreenViewModel({required SongStorageService songStorage}) : _songStorage = songStorage;
  
  List<Playlist> _playlists = [];
  List<Playlist> get playlists => _playlists;

  Future<void> loadPlaylists() async {
    final playlists = await _songStorage.getPlaylists();

    _playlists = playlists;
    notifyListeners();
  }

  Future<void> saveLastLoadedPlaylistId(Playlist playlist) async {
      var pref = await SharedPreferences.getInstance();
      pref.setInt("last_loaded_playlist_id", playlist.id);
  }
  Future<void> removeLastLoadedPlaylistId() async {
      var pref = await SharedPreferences.getInstance();
      pref.remove("last_loaded_playlist_id");
  }
}
