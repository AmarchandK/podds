// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/functions/styles.dart';

class FavoriteDB {
  static ValueNotifier<List<dynamic>> favorites = ValueNotifier([]);
  static List<dynamic> favsong = [];
  static List<SongModel> favloop = [];
  static addSongtoFav(item) async {
    final dbBox = await Hive.openBox('favorites');
    await dbBox.add(item);
    getAllSongs();
  }

  static getAllSongs() async {
    final dbBox = await Hive.openBox('favorites');
    favsong = dbBox.values.toList();
    displaySongs();
    favorites.notifyListeners();
  }

  static deleteFromFav(index) async {
    final dbBox = await Hive.openBox('favorites');
    await dbBox.deleteAt(index);
    getAllSongs();
  }

  static displaySongs() async {
    final dbBox = await Hive.openBox('favorites');
    final musicitems = dbBox.values.toList();
    favorites.value.clear();
    favloop.clear();
    for (int i = 0; i < musicitems.length; i++) {
      for (int j = 0; j < StylesPage.songs.length; j++) {
        if (musicitems[i] == StylesPage.songs[j].id) {
          favorites.value.add(j);
          favloop.add(StylesPage.songs[j]);
        }
      }
    }
    favorites.notifyListeners();
  }
}
