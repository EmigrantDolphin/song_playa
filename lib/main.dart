import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:song_playa/api/models/playlist.dart';
import 'package:song_playa/app_config.dart';
import 'package:song_playa/api/api_client.dart';
import 'package:song_playa/screens/playlists_screen.dart';
import 'package:song_playa/screens/player_screen.dart';
import 'package:song_playa/services/audio_playback_service.dart';
import 'package:song_playa/api/song_server.dart';
import 'package:song_playa/services/song_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig();
  await config.load();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppConfig>(create: (_) => config),
        Provider<ApiClient>(
          create: (context) => ApiClient(config.getServerUrl()),
        ),
        ProxyProvider<ApiClient, SongServer>(
          update: (_, apiClient, _) => SongServer(apiClient: apiClient),
        ),
        ProxyProvider2<ApiClient, SongServer, SongStorageService>(
          update: (_, apiClient, songServer, _) => SongStorageService(apiClient: apiClient, songServer: songServer),
        ),
        Provider<AudioPlaybackService>(
          create: (_) => AudioPlaybackService(),
          dispose: (_, service) => service.dispose(),
        ),
      ],
      child: const MyApp(),
    ),
  );
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
      // home: const MusicPlayerScreen(),
      home: const RootHandler()
    );
  }
}


class RootHandler extends StatelessWidget {
  const RootHandler({super.key});

  Future<Playlist?> _lastLoadedPlaylistId(SongStorageService service) async {
    final prefs = await SharedPreferences.getInstance();

    final lastLoadedId = prefs.getInt("last_loaded_playlist_id");
    if (lastLoadedId == null) return null;

    final playlists = await service.getPlaylists();

    return playlists.singleWhere((playlist) => playlist.id == lastLoadedId);
  }

  @override
  Widget build(BuildContext context) {
    final songStorageService = context.read<SongStorageService>();

    return FutureBuilder<Playlist?>(
      future: _lastLoadedPlaylistId(songStorageService),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final lastPlaylist = snapshot.data;
        if (lastPlaylist == null) {
          return const PlaylistsScreen();
        } else {
          return MusicPlayerScreen(playlist: lastPlaylist);
        }
      },
    );
  }
}
