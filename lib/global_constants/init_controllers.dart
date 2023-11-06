import 'package:get/instance_manager.dart';
import 'package:podds/screens/libary/controller/fav_db_controller.dart';
import 'package:podds/screens/miniplayer/controller/miniplayer_controller.dart';
import 'package:podds/screens/playlists/controller/playlist_db_controller.dart';
import 'package:podds/screens/now_playing/controller/nowplaying_controller.dart';
import 'package:podds/screens/splash/controller/splash_controller.dart';
import '../screens/home_screen/controller/recent_controller.dart';

Future<void> init() async {
  Get.put(PlayListcontroller());
  Get.lazyPut(() => RecentSongsController());
  Get.put(NowPlayingController());
  Get.put(MiniPlayerController());
}
