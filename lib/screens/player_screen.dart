import 'package:flutter/material.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  var _isPlaying = false;
  var _currentSongIndex = 0;
  var _songs = ["song one", "song two", "song three"];

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
                  icon: !_isPlaying ? const Icon(Icons.play_arrow) : const Icon(Icons.pause), 
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