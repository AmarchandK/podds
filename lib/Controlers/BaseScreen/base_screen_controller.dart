import 'package:get/get_instance/get_instance.dart';
import 'package:get/state_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:podds/db_functions/recent_songs.dart';
import '../../screens/favorites/fav_fuction.dart';
import '../../screens/home_screen/widgets/all_songs.dart';

class BottomController extends GetxController {
 final RecentSongsController _controller = Get.put(RecentSongsController());

  @override
  void onInit() {
    init();
    super.onInit();
  }

  Future init() async {
    await Permission.storage.request();
    HomeAllSongs();
    // await getAllPlaylist();
    await _controller.displayRecents();
    // await FavoriteDB.getAllSongs();
    FavoriteFunction();
    update();
  }
}
