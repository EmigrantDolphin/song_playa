import 'package:song_playa/api/api_client.dart';
import 'package:song_playa/api/models/playlist.dart';

class SongServer {
  final ApiClient _apiClient;

  SongServer({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<Song>> getAllSongNames() async {
    final response = await _apiClient.dio.get("v1/songs");
    final jsonMap = response.data as Map<String, dynamic>;

    final List<Song> songs = (jsonMap['songs'] as List)
      .map((item) => Song.fromJson(item))
      .toList();

    print("songs: $songs");
    return songs;
  }


  Future<void> downloadSong(String fileName, String saveToPath) async {
    await _apiClient.dio.download("download/song/$fileName", saveToPath);
  }

  Future<List<Playlist>> getPlaylists() async {
    final res = await _apiClient.dio.get("playlists");

    if (res.statusCode != 200) {
      return [];
    }

    final List<dynamic> jsonData = res.data;

    return jsonData.map((item) => Playlist.fromJson(item)).toList();
  }
}
