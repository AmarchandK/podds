import 'package:get/instance_manager.dart';
import 'package:podds/Controlers/SplashScreen/splash_controller.dart';
import 'package:podds/db_functions/fav_db_functions.dart';
import 'package:podds/db_functions/playlist_db_functions.dart';
import 'package:podds/db_functions/recent_songs.dart';

init() {
  Get.put(FavDbFunctions());
  Get.put(PlayListcontroller());
  Get.lazyPut(() => RecentSongsController());
  Get.put(SplshController());
}
