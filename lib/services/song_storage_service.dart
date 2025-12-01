import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class SongStorageService {
  final Dio _dio = Dio();
  final String _songsDirectory = 'downloaded_songs';

  Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final songsDir = Directory('${directory.path}/$_songsDirectory');

    if (!await songsDir.exists()) {
      await songsDir.create(recursive: true);
    }

    return songsDir.path;
  }

  Future<String?> downloadSong({
    required String url,
    required String fileName,
    Function(int received, int total)? onReceiveProgress,
  }) async {
    try {
      final localPath = await _getLocalPath();
      final filePath = '$localPath/$fileName';

      await _dio.download(url, filePath, onReceiveProgress: onReceiveProgress);

      return filePath;
    } catch (e) {
      print('Error downloading a song: $e');
      return null;
    }
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
