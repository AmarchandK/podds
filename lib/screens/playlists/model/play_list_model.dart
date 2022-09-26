import 'package:hive_flutter/adapters.dart';
part 'play_list_model.g.dart';

@HiveType(typeId: 1)
class PlayListModel {
  @HiveField(0)
  int? id;
  @HiveField(1)
  final String playListName;
  @HiveField(2)
 List<dynamic> playlistSongs = [];
  PlayListModel(
      {required this.playListName,
      this.id,
      required this.playlistSongs});
}
