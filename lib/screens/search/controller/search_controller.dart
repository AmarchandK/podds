import 'package:get/state_manager.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../all_songs/all_songs.dart';

class Searchcontroller extends GetxController {
  final List<SongModel> _allSongs = AllSongs.songs;
  late List<SongModel> foundSongs = [];
  String temp = '';
  List<SongModel> _results = [];

  @override
  void onInit() {
    foundSongs = _allSongs;
    super.onInit();
  }

  void runFilter(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      _results = _allSongs;
    } else {
      _results = _allSongs
          .where(
            (name) => name.title.toLowerCase().contains(
                  enteredKeyword.toLowerCase(),
                ),
          )
          .toList();
    }
    foundSongs = _results;
    update();
  }
}
