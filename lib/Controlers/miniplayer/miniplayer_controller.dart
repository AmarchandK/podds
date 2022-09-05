import 'package:get/state_manager.dart';

import '../../functions/get_all_songs/get_all_songs.dart';

class MiniPlayerController extends GetxController {
  @override
  void onInit() {
    GetAllSongs.audioPlayer.currentIndexStream.listen((index) {
      if (index != null) {}
    });
    super.onInit();
    update();
  }
}
