// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/all_songs/all_songs.dart';
import 'package:podds/get_all_songs.dart';
import 'package:podds/paly_list_model/play_list_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class PlayListFunctions {
//   Future addPlayList(PlayListModel playListValue) async {
//     final playListBox = await Hive.openBox<PlayListModel>(playListDBname);
//     await playListBox.put(playListValue.id, playListValue);
//   }

//   Future<List<PlayListModel>> getPlaylist() async {
//     final playListBox = await Hive.openBox<PlayListModel>(playListDBname);
//     return playListBox.values.toList();
//   }

//   Future deletePlayList(String playListID) async {
//     final playListBox = await Hive.openBox<PlayListModel>(playListDBname);
//     await playListBox.delete(playListID);
//   }
// }
ValueNotifier<List<PlayListModel>> playListNotifier = ValueNotifier([]);
// List<SongModel> playListLoop = [];

void playlistAdd(PlayListModel value) async {
  final playListDB = await Hive.openBox<PlayListModel>('playlist_db');
  int id = await playListDB.add(value);
  value.id = id;
  playListNotifier.value.add(value);
  playListNotifier.notifyListeners();
}

Future<void> getAllPlaylist() async {
  final playListDB = await Hive.openBox<PlayListModel>('playlist_db');
  playListNotifier.value.clear();
  playListNotifier.value.addAll(playListDB.values);
  playListNotifier.notifyListeners();
}

void updateList(index, value) async {
  final playListDB = await Hive.openBox<PlayListModel>('playlist_db');
  await playListDB.putAt(index, value);
  await getAllPlaylist();

  await PlaysongCheck.showSelectSong(index);
  playListNotifier.notifyListeners();
}

void deletePlayList(index) async {
  final playListDB = await Hive.openBox<PlayListModel>('playlist_db');
  await playListDB.deleteAt(index);
  PlaysongCheck.selectPlaySong.notifyListeners();

  getAllPlaylist();
}

class PlaysongCheck {
  static ValueNotifier<List<SongModel>> selectPlaySong = ValueNotifier([]);
  static showSelectSong(index) {
    final checkSong = playListNotifier.value[index].playlistSongs;
    selectPlaySong.value.clear();
    // playListLoop.clear();
    for (int i = 0; i < checkSong.length; i++) {
      for (int j = 0; j < AllSongs.songs.length; j++) {
        if (AllSongs.songs[j].id == checkSong[i]) {
          selectPlaySong.value.add(AllSongs.songs[j]);
          selectPlaySong.notifyListeners();
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
