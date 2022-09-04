// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podds/db_functions/fav_db_functions.dart';
import 'package:podds/functions/constants/styles.dart';
import 'package:podds/screens/home_screen/home.dart';
import 'package:podds/screens/all_songs/libary.dart';
import 'package:podds/screens/playlists/playlist.dart';
import '../settings/bottom_sheet.dart';
import '../../functions/get_all_songs/get_all_songs.dart';
import '../miniplayer/miniplayer.dart';

class BaseScreen extends StatelessWidget {
  BaseScreen({Key? key}) : super(key: key);
  final FavDbFunctions _dbFunctions = Get.find();
  final screens = [
    const HomeScreen(),
    const LibaryScreen(),
    PlaylistScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    // _dbFunctions.getAllFavSongs();
    return Scaffold(
      backgroundColor: color2,
      body: Obx(() => screens[baseIndex.value]),
      bottomNavigationBar: GetBuilder<FavDbFunctions>(
        builder: (controller) {
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
