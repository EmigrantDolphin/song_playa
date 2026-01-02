import 'package:flutter/material.dart';

class MusicControlsBar extends StatelessWidget {
  final VoidCallback onTogglePlayStop;
  final VoidCallback onPreviousSong;
  final VoidCallback onNextSong;
  final bool isPlaying;
  final bool isOneSongLooping;
  final VoidCallback onToggleOneSongLoop;
  final String currentSongName;
  final int songsToDownload;
  final VoidCallback onStartDownloadingSong;
  final VoidCallback onGoToPlaylist;

  const MusicControlsBar({
    super.key,
    required this.onTogglePlayStop,
    required this.onPreviousSong,
    required this.onNextSong,
    required this.onToggleOneSongLoop,
    required this.isPlaying,
    required this.isOneSongLooping,
    required this.currentSongName,
    required this.songsToDownload,
    required this.onStartDownloadingSong,
    required this.onGoToPlaylist
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      color: Color.fromRGBO(255, 235, 255, 1),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),

            child: Text(
              "$currentSongName\n",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous Button
              IconButton(
                iconSize: 48,
                icon: const Icon(Icons.skip_previous),
                onPressed: onPreviousSong,
              ),

              // Play/Stop Button
              IconButton(
                iconSize: 64,
                icon: !isPlaying
                    ? const Icon(Icons.play_arrow)
                    : const Icon(Icons.pause),
                onPressed: onTogglePlayStop,
              ),

              // Next Button
              IconButton(
                iconSize: 48,
                icon: const Icon(Icons.skip_next),
                onPressed: onNextSong,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(songsToDownload == 0 ? "0" : songsToDownload.toString()),
                  IconButton(
                    iconSize: 24,
                    icon: const Icon(Icons.download),
                    onPressed: onStartDownloadingSong,
                  ),
                ],
              ),
              IconButton(
                iconSize: 24,
                icon: !isOneSongLooping
                    ? const Icon(Icons.loop)
                    : const Icon(
                        Icons.loop,
                        color: Color.fromRGBO(100, 200, 100, 1),
                      ),
                onPressed: onToggleOneSongLoop,
              ),
              IconButton(
                iconSize: 24,
                icon: const Icon(Icons.list_alt),
                onPressed: onGoToPlaylist,
              )
            ],
          ),
        ],
      ),
    );
  }
}
