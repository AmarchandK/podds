import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

const savekey = 'userlogedin';
String name = '';

class SplashScreen extends GetView {
  const SplashScreen({Key? key}) : super(key: key);

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
