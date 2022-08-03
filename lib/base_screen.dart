import 'package:flutter/material.dart';
import 'package:podds/bottom_sheet.dart';
import 'package:podds/favorites/fav_fuction.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/get_all_songs.dart';
import 'package:podds/home_screen/home.dart';
import 'package:podds/all_songs/libary.dart';
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
    const FavoriteFunction();
    super.initState();
  }

  final screens = const [HomeScreen(), LibaryScreen(), PlaylistScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: screens[baseIndex],
      bottomNavigationBar: Padding(
        
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            (GetAllSongs.audioPlayer.playing) ||
                    (GetAllSongs.audioPlayer.currentIndex != null)
                ? const MiniPlayer()
                : const SizedBox(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: NavigationBarTheme(
                  data: const NavigationBarThemeData(
                    indicatorColor: color1,
                    backgroundColor: Colors.transparent,
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
                      NavigationDestination(
                          icon: Icon(Icons.home), label: 'Home'),
                      NavigationDestination(
                          icon: Icon(Icons.library_music_sharp),
                          label: 'Libary'),
                      NavigationDestination(
                          icon: Icon(Icons.playlist_play_rounded),
                          label: 'Playlist'),
                      NavigationDestination(
                          icon: Icon(Icons.settings), label: 'Settings'),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
