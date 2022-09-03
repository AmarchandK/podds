import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/state_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/all_songs/all_songs.dart';
import 'package:podds/db_functions/fav_db_functions.dart';
import 'package:podds/db_functions/recent_songs.dart';
import 'package:podds/favorites/fav_button.dart';
import 'package:podds/functions/styles.dart';
import '../screens/get_all_songs.dart';
import '../screens/player_screen.dart';

class FavoriteFunction extends StatelessWidget {
  FavoriteFunction({Key? key}) : super(key: key);
  static List<SongModel> tempFav = [];
  final FavDbFunctions _dbFunctions = Get.find();
  // final controller = ScrollController();
  final RecentSongsController _controller = Get.find();

  // var tempIndex = 0;
  // @override
  // void initState() {
  //   FavoriteDB.getAllSongs();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FavDbFunctions>(builder: (controller) {
      final tempList = _dbFunctions.favorites;
      // print(value);
      if (_dbFunctions.favloop.isEmpty) {
        return Center(
          child: Lottie.asset('assets/lf20_oq4hyt7j.json'),
        );
      } else {
        return ListView.builder(
            primary: false,
            shrinkWrap: true,
            // controller: controller,
            itemCount: tempList.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Card(
                  color: const Color.fromARGB(119, 21, 153, 140),
                  child: ListTile(
                    onTap: () {
                      FavoriteFunction.tempFav.clear();
                      FavoriteFunction.tempFav.addAll(_dbFunctions.favloop);
                      _controller.addRecentlyPlayed(
                          AllSongs.songs[tempList[index]].id);
                      GetAllSongs.audioPlayer.setAudioSource(
                          GetAllSongs.createSongList(_dbFunctions.favloop),
                          initialIndex: index);
                      GetAllSongs.audioPlayer.play();
                      Get.to(
                        () => PlayerScreen(
                          songModal: _dbFunctions.favloop,
                          id: AllSongs.songs[tempList[index]].id,
                        ),
                        transition: Transition.downToUp,
                        duration: const Duration(milliseconds: 500),
                      );
                    },
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: color1,
                      child: QueryArtworkWidget(
                        artworkFit: BoxFit.fill,
                        id: AllSongs.songs[tempList[index]].id,
                        type: ArtworkType.AUDIO,
                        nullArtworkWidget: Center(
                            child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Image.asset(
                            'assets/logo.png',
                          ),
                        )),
                      ),
                    ),
                    trailing: GetBuilder<FavDbFunctions>(
                      builder: (controller) => FavBTN(
                        id: AllSongs.songs[tempList[index]].id,
                      ),
                    ),
                    title: Text(
                      AllSongs.songs[tempList[index]].title,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                    subtitle: const Text('Tap to play'),
                  ),
                ),
              );
            });
      }
    });
  }
}
