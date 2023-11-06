// ignore_for_file: unused_field
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podds/global_constants/styles.dart';
import 'package:podds/screens/home_screen/view/home.dart';
import 'package:podds/screens/libary/controller/fav_db_controller.dart';
import 'package:podds/screens/libary/view/libary.dart';
import '../../playlists/view/playlist.dart';
import '../../settings/view/bottom_sheet.dart';
import '../../../global_constants/get_all_songs.dart';
import '../../miniplayer/view/miniplayer.dart';

class BaseScreen extends StatelessWidget {
  BaseScreen({Key? key}) : super(key: key);
  final FavDbController _dbFunctions = Get.put(FavDbController());
  final List<StatelessWidget> screens = [
    const HomeScreen(),
    const LibaryScreen(),
    PlaylistScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color2,
      body: Obx(() => screens[baseIndex.value]),
      bottomNavigationBar: StreamBuilder<int?>(
        stream: GetAllSongs.audioPlayer.currentIndexStream,
        builder: (context, index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              (GetAllSongs.audioPlayer.playing) ||
                      (GetAllSongs.audioPlayer.currentIndex != null)
                  ? MiniPlayer()
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
