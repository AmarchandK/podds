import 'package:flutter/material.dart';
import 'package:podds/bottom_sheet.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/home.dart';
import 'package:podds/libary.dart';
import 'package:podds/playlist/playlist.dart';
  int baseIndex=0;
class BaseScreen extends StatefulWidget {
   const BaseScreen({Key? key}) : super(key: key);

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
 
  final screens =  const[HomeScreen(), LibaryScreen(), PlaylistScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: screens[baseIndex],
      bottomNavigationBar: NavigationBarTheme(
          data: const NavigationBarThemeData(
            indicatorColor: color1,
            backgroundColor: color2,
          ),
          child: NavigationBar(
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            animationDuration: const Duration(seconds: 1),
            height: 60,
            selectedIndex: baseIndex,
            onDestinationSelected: (index) {
              if (index == 3) {
                showOptions(context);
              } else {
                setState(() {
                  baseIndex = index;
                });
              }
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(
                icon: Icon(Icons.library_music_sharp),
                label: 'libary',
              ),
              NavigationDestination(
                  icon: Icon(Icons.playlist_play_rounded), label: 'Playlist'),
              NavigationDestination(
                  icon: Icon(Icons.settings), label: 'Settings'),
            ],
          )),
    );
  }
}
