// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
import 'package:get/state_manager.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/screens/all_songs/all_songs.dart';
import 'package:podds/paly_list_model/play_list_model.dart';

class PlayListcontroller extends GetxController {
  List<PlayListModel> playListNotifier = [];
  List<SongModel> selectPlaySong = [];

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
    getAllPlaylist();
    update();
  }

  showSelectSong(index) {
    final checkSong = playListNotifier[index].playlistSongs;
    selectPlaySong.clear();
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

