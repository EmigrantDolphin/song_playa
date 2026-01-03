import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_playa/api/models/playlist.dart';
import 'package:song_playa/screens/player_screen.dart';
import 'package:song_playa/screens/playlists_screen_view_model.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaylistsScreenViewModel>().loadPlaylists();
    });
  }

  Future<void> onPlaylistSelect(BuildContext context, Playlist playlist) async {
    final vm = context.read<PlaylistsScreenViewModel>();

    await vm.saveLastLoadedPlaylistId(playlist);

    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MusicPlayerScreen(playlist: playlist),
      ),
    );

    await vm.removeLastLoadedPlaylistId();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlaylistsScreenViewModel>();

    return Scaffold(
      body: Center(
        child: vm.playlists.isEmpty
            ? Center(child: Text("No playlists found"))
            : ListView.builder(
                itemCount: vm.playlists.length,
                itemBuilder: (context, index) {
                  final playlist = vm.playlists[index];
                  return ListTile(
                    title: Text(playlist.name),
                    onTap: () => onPlaylistSelect(context, playlist)
                  );
                },
              ),
      ),
    );
  }


}
