import 'package:get/state_manager.dart';

import '../../../functions/get_all_songs/get_all_songs.dart';

class NowPlayingController extends GetxController {
  int currentIndex1 = 0;

  @override
  void onInit() {
    GetAllSongs.audioPlayer.currentIndexStream.listen(
      (index) {
        if (index != null /*&& mounted*/) {
          currentIndex1 = index;
          GetAllSongs.getCurrentIndex = index;
        }
      },
    );
    super.onInit();
  }

  playPrevious() async {
    if (GetAllSongs.audioPlayer.hasPrevious) {
      await GetAllSongs.audioPlayer.seekToPrevious();
      await GetAllSongs.audioPlayer.play();
      update();
    } else {
      await GetAllSongs.audioPlayer.play();
      update();
    }
  }
}
