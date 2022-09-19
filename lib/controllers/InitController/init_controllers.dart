import 'package:get/instance_manager.dart';
import 'package:podds/controllers/miniplayer_controller.dart';
import 'package:podds/db_functions/fav_db_functions.dart';
import 'package:podds/db_functions/playlist_db_functions.dart';
import 'package:podds/controllers/nowplaying_controller.dart';

import '../../db_functions/recent_songs.dart';

Future<void> init() async {
  Get.lazyPut(() => FavDbFunctions());
  Get.put(PlayListcontroller());
  Get.lazyPut(() => RecentSongsController());
  Get.put(NowPlayingController());
  Get.put(MiniPlayerController());
}
