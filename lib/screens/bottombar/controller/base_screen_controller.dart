import 'package:get/get_instance/get_instance.dart';
import 'package:get/state_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:podds/screens/home_screen/controller/recent_controller.dart';
import '../../libary/view/widgets/fav_fuction.dart';
import '../../home_screen/view/widgets/all_songs.dart';

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
    await _controller.displayRecents();
    FavoriteFunction();
    update();
  }
}
