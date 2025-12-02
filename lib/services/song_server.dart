import 'package:song_playa/core/api_client.dart';

class SongServer {
  final ApiClient _apiClient;

  SongServer({required ApiClient apiClient}) : _apiClient = apiClient;
  Future<List<String>> getAllSongNames() async {
    final response = await _apiClient.dio.get("songs");
    final jsonMap = response.data as Map<String, dynamic>;
    final rawSongs = jsonMap['songs'] as List<dynamic>;
    var songs = rawSongs.map((x) => x.toString()).toList();

    print("songs: $songs");
    return songs;
  }
}
