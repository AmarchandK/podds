// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
import 'package:get/state_manager.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../view/widgets/all_songs.dart';

class FavDbController extends GetxController {
  List<dynamic> favorites = [];
  List<int> favsong = [];
  List<SongModel> favloop = [];
  @override
  void onInit() {
    getAllFavSongs();
    super.onInit();
  }

  void getAllFavSongs() async {
    final dbBox = await Hive.openBox<int>('favorites');
    favsong.clear();
    favsong.addAll(dbBox.values.toList());
    displaySongs();
    update();
  }

  void addSongtoFav(int id) async {
    final dbBox = await Hive.openBox<int>('favorites');
    await dbBox.add(id);
    getAllFavSongs();
    update();
  }

  void deleteFromFav(index) async {
    final dbBox = await Hive.openBox<int>('favorites');
    await dbBox.deleteAt(index);
    getAllFavSongs();
    update();
  }

  void deleteFromFavorites(int id) async {
    final dbBox = await Hive.openBox<int>('favorites');
    // favsong.removeWhere((item) => item == id);
    int index = favsong.indexOf(id);
    await dbBox.deleteAt(index);
    getAllFavSongs();
    update();
  }

  bool isInFav(int id) {
    return favsong.contains(id);
  }

  void displaySongs() async {
    final dbBox = await Hive.openBox<int>('favorites');
    final List<int> musicitems = dbBox.values.toList();
    favorites.clear();
    favloop.clear();
    for (int i = 0; i < musicitems.length; i++) {
      for (int j = 0; j < AllSongs.songs.length; j++) {
        if (musicitems[i] == AllSongs.songs[j].id) {
          favorites.add(j);
          favloop.add(AllSongs.songs[j]);
        }
      }
    }
    update();
  }
}
