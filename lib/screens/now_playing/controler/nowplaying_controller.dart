import 'package:get/state_manager.dart';
import '../../../functions/get_all_songs/get_all_songs.dart';
class NowPlayingController extends GetxController {
  RxInt currentIndex1 = 0.obs;

  @override
  void onInit() {
    GetAllSongs.audioPlayer.currentIndexStream.listen(
      (index) {
        if (index != null /*&& mounted*/) {
          currentIndex1.value = index;
          GetAllSongs.getCurrentIndex = index;
        }
      },
    );
    super.onInit();
  }

  void changeToSeconds(int seconds) {
    Duration duration = Duration(seconds: seconds);
    GetAllSongs.audioPlayer.seek(duration);
    update();
  }
  stream(){}
}
