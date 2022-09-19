import 'dart:async';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:podds/screens/bottombar/base_screen.dart';

class SplshController extends GetxController {
  @override
  void onInit() {
    Permission.storage.request();
    Timer(const Duration(seconds: 1), () => Get.off(() => BaseScreen()));

    super.onInit();
  }

  // Future<void> checkLogin() async {
  //   final sharedpref = await SharedPreferences.getInstance();
  //   name = sharedpref.getString('name') ?? 'No data';
  //   final alreadyloged = sharedpref.getBool('loged') ?? false;
  //   if (alreadyloged == false) {
  //     Timer(const Duration(seconds: 2), () => Get.off(() => AddScreen()));
  //   } else {
  //   }
  // }
}
