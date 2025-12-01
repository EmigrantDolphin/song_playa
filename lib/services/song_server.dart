

class SongServer {
  final String _serverUrl;

  SongServer({required String serverUrl}) : _serverUrl = serverUrl;
  Future<List<String>> GetAllSongNames() async {
    print('server url $_serverUrl');
    return [];
  }

}