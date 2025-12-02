import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_playa/app_config.dart';
import 'package:song_playa/api/api_client.dart';
import 'package:song_playa/screens/player_screen.dart';
import 'package:song_playa/services/audio_playback_service.dart';
import 'package:song_playa/services/song_server.dart';
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
        ProxyProvider<ApiClient, SongStorageService>(
          update: (_, apiClient, _) => SongStorageService(apiClient: apiClient),
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
      home: const MusicPlayerScreen(),
    );
  }
}
