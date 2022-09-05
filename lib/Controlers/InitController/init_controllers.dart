import 'package:get/instance_manager.dart';
import 'package:podds/Controlers/SplashScreen/splash_controller.dart';
import 'package:podds/Controlers/miniplayer/miniplayer_controller.dart';
import 'package:podds/db_functions/fav_db_functions.dart';
import 'package:podds/db_functions/playlist_db_functions.dart';
import 'package:podds/screens/now_playing/controler/nowplaying_controller.dart';

Future<void> init() async {
  Get.put(FavDbFunctions());
  Get.put(PlayListcontroller());
  // Get.put(RecentSongsController());
  Get.put(SplshController());
  Get.put(NowPlayingController());
  Get.put(MiniPlayerController());
}
