// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
import 'package:get/state_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/screens/all_songs/all_songs.dart';

class RecentSongsController extends GetxController {
  List<SongModel> recentsNotifier = [];
  List<int> recentPlayed = [];
  @override
  void onInit() {
    getRecentSongs();
    super.onInit();
  }

  getRecentSongs() async {
    final dbBox = await Hive.openBox<int>('recentsNotifier');
    recentPlayed.clear();
    recentPlayed.addAll(dbBox.values.toList());
    displayRecents();
    update();
  }

  addRecentlyPlayed(item) async {
    final dbBox = await Hive.openBox<int>('recentsNotifier');
    await dbBox.add(item);
    getRecentSongs();
    update();
  }

  displayRecents() async {
    final dbBox = await Hive.openBox<int>('recentsNotifier');
    final recentsItems = dbBox.values.toList();
    recentsNotifier.clear();
    // recentPlayed.clear();
    for (int i = 0; i < recentsItems.length; i++) {
      for (int j = 0; j < AllSongs.songs.length; j++) {
        if (recentsItems[i] == AllSongs.songs[j].id) {
          recentsNotifier.add(AllSongs.songs[j]);
          // recentPlayed.add(AllSongs.songs[j]);
        }
      }
    }
    update();
    // return recentPlayed.reversed.toList();
  }
}
