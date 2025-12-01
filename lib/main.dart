import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_playa/app_config.dart';
import 'package:song_playa/screens/player_screen.dart';
import 'package:song_playa/services/song_server.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig();
  await config.load();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppConfig>(create: (_) => config),
        ProxyProvider<AppConfig, SongServer>(
          update: (context, config, previous) =>
              SongServer(serverUrl: config.getServerUrl()),
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
