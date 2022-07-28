import 'dart:async';
import 'package:flutter/material.dart';
import 'package:podds/add_profile.dart';
import 'package:podds/base_screen.dart';
import 'package:podds/db_functions/favorite_db.dart';
import 'package:shared_preferences/shared_preferences.dart';

const savekey = 'userlogedin';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    checkLogin();
    FavoriteDB.getAllSongs();

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
    final alreadyloged = sharedpref.getBool(savekey);
    if (alreadyloged == null || alreadyloged == false) {
      Timer(
        const Duration(seconds: 3),
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
            builder: (context) =>  const BaseScreen(),
          ),
        ),
      );
    }
  }
}
