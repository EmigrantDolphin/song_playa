import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_playa/api/models/playlist.dart';
import 'package:song_playa/screens/player_screen_view_model.dart';
import 'package:song_playa/screens/playlists_screen.dart';
import 'package:song_playa/screens/widgets/music_controls_bar.dart';

class MusicPlayerScreen extends StatefulWidget {
  final Playlist playlist;
  const MusicPlayerScreen({super.key, required this.playlist});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayerScreenViewModel>().loadSongsFromStorage(widget.playlist);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlayerScreenViewModel>();

    return Scaffold(
      body: Center(
        child: ListView.builder(
          itemCount: vm.loadedSongFiles.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(vm.getLoadedSongName(index)),
              tileColor: vm.isPlaying && vm.currentSongIndex == index
                  ? Color.fromRGBO(20, 20, 120, 0.1)
                  : null,
              onTap: () => vm.seekSongAtIndex(index),
            );
          },
        ),
      ),
      bottomNavigationBar: MusicControlsBar(
        onTogglePlayStop: vm.togglePlayStop,
        onPreviousSong: vm.previousSong,
        onNextSong: vm.nextSong,
        onToggleOneSongLoop: vm.toggleOneSongLoop,
        isPlaying: vm.isPlaying,
        isOneSongLooping: vm.isOneSongLooping,
        currentSongName: vm.getLoadedSongName(vm.currentSongIndex),
        songsToDownload: vm.songsToDownload.length,
        onStartDownloadingSong: () => vm.startDownloadingSong(widget.playlist),
        onGoToPlaylist: () async {
          final tvm = context.read<PlayerScreenViewModel>();
          await tvm.stopPlaying();

          if (!context.mounted) return;
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PlaylistsScreen()));
          }
        },
      ),
    );
  }
}
