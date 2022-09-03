import 'package:get/instance_manager.dart';
import 'package:podds/db_functions/fav_db_functions.dart';
import 'package:podds/db_functions/playlist_db_functions.dart';
import 'package:podds/db_functions/recent_songs.dart';

Future<void> init() async {
  Get.put(FavDbFunctions());
  Get.lazyPut(() => PlayListcontroller());
  Get.lazyPut(() => RecentSongsController());
}
