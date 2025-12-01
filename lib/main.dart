import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      theme: ThemeData(
        // Using Material 3 for modern Android styling
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MusicPlayerPage(),
    );
  }
}

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({super.key});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  // Hardcoded song data
  final String _currentSong = "Bohemian Rhapsody - Queen";

  // Empty logic functions as requested
  void _togglePlayStop() {
    // Logic to play/stop audio would go here
  }

  void _nextSong() {
    // Logic to skip to next song would go here
  }

  void _previousSong() {
    // Logic to skip to previous song would go here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Android Music Player"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Song Name Label
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _currentSong,
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
                  icon: const Icon(Icons.play_arrow), 
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