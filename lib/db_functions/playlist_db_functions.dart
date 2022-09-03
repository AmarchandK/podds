// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
import 'dart:developer';
import 'package:get/state_manager.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/all_songs/all_songs.dart';
import 'package:podds/paly_list_model/play_list_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/get_all_songs.dart';

class PlayListcontroller extends GetxController {
  List<PlayListModel> playListNotifier = [];
  @override
  void onInit() async {
    getAllPlaylist();
    super.onInit();
  }

  Future<void> getAllPlaylist() async {
    final playListDB = await Hive.openBox<PlayListModel>('playlist_db');
    playListNotifier.clear();
    playListNotifier.addAll(playListDB.values);
    update();
  }

  void playlistAdd(PlayListModel value) async {
    final playListDB = await Hive.openBox<PlayListModel>('playlist_db');
    playListDB.add(value);
    getAllPlaylist();
    update();
  }

  void updateList(index, value) async {
    final playListDB = await Hive.openBox<PlayListModel>('playlist_db');
    await playListDB.putAt(index, value);
    await getAllPlaylist();
    await showSelectSong(index);
    update();
  }

  void deletePlayList(index) async {
    final playListDB = await Hive.openBox<PlayListModel>('playlist_db');
    await playListDB.deleteAt(index);
    // selectPlaySong.notifyListeners();
    getAllPlaylist();
    update();
  }

  List<SongModel> selectPlaySong = [];
  showSelectSong(index) {
    final checkSong = playListNotifier[index].playlistSongs;
    selectPlaySong.clear();
    // playListLoop.clear();
    for (int i = 0; i < checkSong.length; i++) {
      for (int j = 0; j < AllSongs.songs.length; j++) {
        if (AllSongs.songs[j].id == checkSong[i]) {
          selectPlaySong.add(AllSongs.songs[j]);
          update();
          break;
        }
      }
    }
  }
}

void resetApp() async {
  final playListDB = await Hive.openBox<PlayListModel>('playlist_db');
  final favBoxdb = await Hive.openBox('favorites');
  final recentbocdb = await Hive.openBox('recentsNotifier');
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.clear();
  await playListDB.clear();
  await favBoxdb.clear();
  await recentbocdb.clear();
  GetAllSongs.audioPlayer.pause();
}
