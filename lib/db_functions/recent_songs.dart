// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
import 'package:get/state_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/all_songs/all_songs.dart';

class RecentSongsController extends GetxController {
  @override
  void onInit() {
    getRecentSongs();
    recentPlayed;
    recentsNotifier;
    super.onInit();
  }

  List<SongModel> recentsNotifier = [];
  List<dynamic> recentPlayed = [];
  addRecentlyPlayed(item) async {
    final dbBox = await Hive.openBox('recentsNotifier');
    await dbBox.add(item);
    getRecentSongs();
    update();
  }

  getRecentSongs() async {
    final dbBox = await Hive.openBox('recentsNotifier');
    recentPlayed = dbBox.values.toList();
    displayRecents();
    update();
  }

  displayRecents() async {
    final dbBox = await Hive.openBox('recentsNotifier');
    final recentsItems = dbBox.values.toList();
    recentsNotifier.clear();
    recentPlayed.clear();
    for (int i = 0; i < recentsItems.length; i++) {
      for (int j = 0; j < AllSongs.songs.length; j++) {
        if (recentsItems[i] == AllSongs.songs[j].id) {
          recentsNotifier.add(AllSongs.songs[j]);
          recentPlayed.add(AllSongs.songs[j]);
        }
      }
    }
    recentPlayed.reversed.toList();
    update();
  }
}
