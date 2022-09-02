import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podds/bottom_sheet.dart';
import 'package:podds/db_functions/fav_db_functions.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/get_all_songs.dart';
import 'package:podds/home_screen/home.dart';
import 'package:podds/all_songs/libary.dart';
import 'package:podds/miniplayer.dart';
import 'package:podds/playlist/playlist.dart';

RxInt baseIndex = 0.obs;

class BaseScreen extends StatelessWidget {
  BaseScreen({Key? key}) : super(key: key);

  // BottomController _bottomController = Get.put(BottomController());
  final FavDbFunctions _dbFunctions = Get.put(FavDbFunctions());
  final screens = const [
    HomeScreen(),
    LibaryScreen(),
    PlaylistScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color2,
      body: Obx(() => screens[baseIndex.value]),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: _dbFunctions.favorites,
        builder: (BuildContext context, List<dynamic> songs, Widget? child) {
          return Column(
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
                child: Obx(
                  () => NavigationBar(
                    labelBehavior:
                        NavigationDestinationLabelBehavior.onlyShowSelected,
                    animationDuration: const Duration(seconds: 1),
                    height: 60,
                    selectedIndex: baseIndex.value,
                    onDestinationSelected: (index) {
                      if (index == 3) {
                        showModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (ctx) {
                              return Settings(context: context);
                            });
                      } else {
                        baseIndex.value = index;
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
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
