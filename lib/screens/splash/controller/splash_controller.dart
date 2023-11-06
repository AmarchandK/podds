import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:podds/screens/bottombar/view/base_screen.dart';

class SplshController extends GetxController {
  @override
  void onInit() async {
    PermissionStatus status = await Permission.storage.request();
    log("1$status");
    Timer(const Duration(seconds: 1), () => Get.off(() => BaseScreen()));
    log("2");

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
