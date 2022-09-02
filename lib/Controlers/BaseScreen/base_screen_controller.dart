import 'package:get/state_manager.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../db_functions/favorite_db.dart';
import '../../db_functions/playlist_db_functions.dart';
import '../../db_functions/recent_songs.dart';
import '../../favorites/fav_fuction.dart';
import '../../home_screen/homescreen_functns.dart';

class BottomController extends GetxController {
  @override
  void onInit() {
    init();
    super.onInit();
  }

  Future init() async {
    await Permission.storage.request();
    HomeAllSongs();
    await getAllPlaylist();
    await RecentSongs.displayRecents();
    await FavoriteDB.getAllSongs();
    const FavoriteFunction();
    update();
  }
}
