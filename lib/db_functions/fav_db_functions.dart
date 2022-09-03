// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
import 'package:get/state_manager.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/all_songs/all_songs.dart';

class FavDbFunctions extends GetxController {
  List<dynamic> favorites = [];
  List<int> favsong = [];
  List<SongModel> favloop = [];
  @override
  void onInit() {
    getAllFavSongs();
    favloop;

    super.onInit();
  }

  Future<void> getAllFavSongs() async {
    final dbBox = await Hive.openBox<int>('favorites');
    favsong = dbBox.values.toList();
    update();
  }

  addSongtoFav(item) async {
    final dbBox = await Hive.openBox<int>('favorites');
    await dbBox.add(item);
    getAllFavSongs();
    update();
  }

  deleteFromFav(index) async {
    final dbBox = await Hive.openBox<int>('favorites');
    await dbBox.deleteAt(index);
    getAllFavSongs();
    update();
  }

  deleteFromFavorites(id) async {
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

  displaySongs() async {
    final dbBox = await Hive.openBox<int>('favorites');
    final musicitems = dbBox.values.toList();
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
