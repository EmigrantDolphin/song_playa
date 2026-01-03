import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:song_playa/api/models/playlist.dart';
import 'package:song_playa/api/song_server.dart';

class SongStorageService {
  final String _songsDirectory = 'downloaded_songs';
  final SongServer _songServer;

  SongStorageService({required SongServer songServer}) : _songServer = songServer;

  Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final songsDir = Directory('${directory.path}/$_songsDirectory');

    if (!await songsDir.exists()) {
      await songsDir.create(recursive: true);
    }

    return songsDir.path;
  }

  Future<String?> downloadSong({
    required String fileName,
  }) async {
    try {
      final localPath = await _getLocalPath();
      final filePath = '$localPath/$fileName';

      await _songServer.downloadSong(fileName, filePath);

      return filePath;
    } catch (e) {
      print('Error downloading a song: $e');
      return null;
    }
  }

  Future<void> syncPlaylists() async {
    var playlists = await _songServer.getPlaylists();
    if (playlists.isEmpty) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = playlists
      .map((playlist) => playlist.toJson())
      .toList();

    final json = jsonEncode(jsonList);

    await prefs.setString("playlists", json);
  }

  Future<List<Playlist>> getPlaylists() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString("playlists");

    if (json == null) return [];

    final List<dynamic> decoded = jsonDecode(json);

    List<Playlist> playlists = [Playlist.getAllPlaylist()];

    var storedPlaylists = decoded
      .map((item) => Playlist.fromJson(item))
      .toList();

    playlists.addAll(storedPlaylists);

    return playlists;
  }

  Future<List<File>> listLocalSongs() async {
    try {
      final localPath = await _getLocalPath();
      final directory = Directory(localPath);

      final List<FileSystemEntity> files = await directory.list().toList();

      final List<File> songFiles = files.whereType<File>().toList();

      return songFiles;
    } catch (e) {
      print('Error listing files: $e');
      return [];
    }
  }
}
