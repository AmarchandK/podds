import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:podds/all_songs/all_songs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_profile.dart';
import 'base_screen.dart';

const savekey = 'userlogedin';
String name = '';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Permission.storage.request();
    checkLogin();
    AllSongs();
    super.initState();
  }

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

  Future<void> checkLogin() async {
    final sharedpref = await SharedPreferences.getInstance();
    name = sharedpref.getString('name') ?? 'No data';
    final alreadyloged = sharedpref.getBool('loged') ?? false;

    if (alreadyloged == false) {
      Timer(
        const Duration(seconds: 2),
        () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddScreen(),
          ),
        ),
      );
    } else {
      Timer(
        const Duration(seconds: 3),
        () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BaseScreen(),
          ),
        ),
      );
    }
  }
}
