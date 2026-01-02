import 'package:json_annotation/json_annotation.dart';

part 'playlist.g.dart';

@JsonSerializable()
class Playlist {
  final int id;
  final String name;
  final List<Song> songs;

  Playlist({required this.id, required this.name, this.songs = const []});

  factory Playlist.fromJson(Map<String, dynamic> json) => _$PlaylistFromJson(json);
  Map<String, dynamic> toJson() => _$PlaylistToJson(this);

  factory Playlist.getAllPlaylist() => Playlist(id: -1, name: "All");
  bool isAllPlaylist() => id == -1;
}

@JsonSerializable()
class Song {
  final int id;
  final String name;

  Song({required this.id, required this.name});

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);
  Map<String, dynamic> toJson() => _$SongToJson(this);
}