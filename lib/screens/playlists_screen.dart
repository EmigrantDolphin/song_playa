import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:song_playa/api/models/playlist.dart';
import 'package:song_playa/screens/player_screen.dart';
import 'package:song_playa/services/song_storage_service.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  late final SongStorageService _songStorage;
  List<Playlist> _playlists = [];

  @override
  void initState() {
    super.initState();
    _songStorage = context.read<SongStorageService>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlaylists();
    });
  }

  Future<void> _loadPlaylists() async {
    await _songStorage.syncPlaylists();
    final playlists = await _songStorage.getPlaylists();


    setState(() {
      _playlists = playlists;
    });
  }

  Future<void> _onPlaylistSelect(Playlist playlist) async {
    var pref = await SharedPreferences.getInstance();
    pref.setInt("last_loaded_playlist_id", playlist.id);

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MusicPlayerScreen(playlist: playlist),
      ),
    );

    pref.remove("last_loaded_playlist_id");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _playlists.isEmpty
            ? Center(child: Text("No playlists found"))
            : ListView.builder(
                itemCount: _playlists.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_playlists[index].name),
                    onTap: () => _onPlaylistSelect(_playlists[index]),
                  );
                },
              ),
      ),
    );
  }
}
