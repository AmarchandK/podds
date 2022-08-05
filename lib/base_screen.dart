import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:podds/bottom_sheet.dart';
import 'package:podds/db_functions/favorite_db.dart';
import 'package:podds/db_functions/playlist_db_functions.dart';
import 'package:podds/db_functions/recent_songs.dart';
import 'package:podds/favorites/fav_fuction.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/get_all_songs.dart';
import 'package:podds/home_screen/home.dart';
import 'package:podds/all_songs/libary.dart';
import 'package:podds/home_screen/homescreen_functns.dart';
import 'package:podds/miniplayer.dart';
import 'package:podds/playlist/playlist.dart';

int baseIndex = 0;

class BaseScreen extends StatefulWidget {
  const BaseScreen({Key? key}) : super(key: key);
  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  @override
  void initState() {
    init();
    setState(() {});
    super.initState();
  }

  final screens = const [HomeScreen(), LibaryScreen(), PlaylistScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color2,
      body: screens[baseIndex],
      bottomNavigationBar: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          (GetAllSongs.audioPlayer.playing) ||
                  (GetAllSongs.audioPlayer.currentIndex != null)
              ? const MiniPlayer()
              : const SizedBox(),
          NavigationBarTheme(
              data: const NavigationBarThemeData(
                indicatorColor: color1,
                backgroundColor: color2,
              ),
              child: NavigationBar(
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
                animationDuration: const Duration(seconds: 1),
                height: 60,
                selectedIndex: baseIndex,
                onDestinationSelected: (index) {
                  if (index == 3) {
                    showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (ctx) {
                          return Settings(context: context);
                        });
                  } else {
                    setState(() {
                      baseIndex = index;
                    });
                  }
                },
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                  NavigationDestination(
                      icon: Icon(Icons.library_music_sharp), label: 'Libary'),
                  NavigationDestination(
                      icon: Icon(Icons.playlist_play_rounded),
                      label: 'Playlist'),
                  NavigationDestination(
                      icon: Icon(Icons.settings), label: 'Settings'),
                ],
              )),
        ],
      ),
    );
  }

  Future init() async {
    await Permission.storage.request();
    HomeAllSongs();
    await getAllPlaylist();
    await RecentSongs.displayRecents();
    await FavoriteDB.getAllSongs();
    const FavoriteFunction();
  }
}
