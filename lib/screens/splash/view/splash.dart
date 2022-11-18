import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podds/screens/splash/controller/splash_controller.dart';

class SplashScreen extends GetView {
  SplashScreen({Key? key}) : super(key: key);
  final SplshController screen = Get.put(SplshController());

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Image.asset(
        'assets/Splash.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
