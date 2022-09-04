import 'dart:async';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:podds/screens/bottombar/base_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../functions/constants/styles.dart';
import '../../screens/add_screen/add_profile.dart';

class SplshController extends GetxController {
  @override
  void onInit() {
    Permission.storage.request();
    checkLogin();
    super.onInit();
  }

  Future<void> checkLogin() async {
    final sharedpref = await SharedPreferences.getInstance();
    name = sharedpref.getString('name') ?? 'No data';
    final alreadyloged = sharedpref.getBool('loged') ?? false;
    if (alreadyloged == false) {
      Timer(const Duration(seconds: 2), () => Get.off(() => AddScreen()));
    } else {
      Timer(const Duration(seconds: 3), () => Get.off(() => BaseScreen()));
    }
  }
}
