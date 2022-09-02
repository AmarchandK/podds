// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'package:flutter/foundation.dart';
import 'package:get/state_manager.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/all_songs/all_songs.dart';

class FavDbFunctions extends GetxController {
/////////   Favorite Functions   //////////

  ValueNotifier<List<dynamic>> favorites = ValueNotifier([]);
  List<dynamic> favsong = [];
  List<SongModel> favloop = [];

  addSongtoFav(item) async {
    final dbBox = await Hive.openBox('favorites');
    await dbBox.add(item);
    getAllSongs();
    update();
  }

  getAllSongs() async {
    final dbBox = await Hive.openBox('favorites');
    favsong = dbBox.values.toList();
    displaySongs();
    update();
  }

  deleteFromFav(index) async {
    final dbBox = await Hive.openBox('favorites');
    await dbBox.deleteAt(index);
    getAllSongs();
    update();
  }

  displaySongs() async {
    final dbBox = await Hive.openBox('favorites');
    final musicitems = dbBox.values.toList();
    favorites.value.clear();
    favloop.clear();
    for (int i = 0; i < musicitems.length; i++) {
      for (int j = 0; j < AllSongs.songs.length; j++) {
        if (musicitems[i] == AllSongs.songs[j].id) {
          favorites.value.add(j);
          favloop.add(AllSongs.songs[j]);
        }
      }
    }
    update();
  }
}
