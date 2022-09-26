import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/state_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/screens/libary/controller/fav_db_controller.dart';
import 'package:podds/screens/libary/view/widgets/fav_button.dart';
import 'package:podds/screens/home_screen/controller/recent_controller.dart';
import 'package:podds/global_constants/styles.dart';
import '../../../../global_constants/get_all_songs.dart';
import '../../../now_playing/view/player_screen.dart';

class FavoriteFunction extends StatelessWidget {
  FavoriteFunction({Key? key}) : super(key: key);
  static List<SongModel> tempFav = [];
  final FavDbController _dbFunctions = Get.put(FavDbController());
  final RecentSongsController _controller = Get.put(RecentSongsController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<FavDbController>(builder: (controller) {
      final tempList = _dbFunctions.favloop;
      if (_dbFunctions.favloop.isEmpty) {
        return Center(
          child: Lottie.asset('assets/lf20_oq4hyt7j.json'),
        );
      } else {
        return ListView.builder(
            primary: false,
            shrinkWrap: true,
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
                      _controller.addRecentlyPlayed(tempList[index].id);
                      GetAllSongs.audioPlayer.setAudioSource(
                          GetAllSongs.createSongList(_dbFunctions.favloop),
                          initialIndex: index);
                      GetAllSongs.audioPlayer.play();
                      Get.to(
                        () => PlayerScreen(
                          songModal: _dbFunctions.favloop,
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
                        id: tempList[index].id,
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
                    trailing: GetBuilder<FavDbController>(
                        builder: (controller) =>
                            FavButton(id: tempList[index].id)),
                    title: Text(
                      tempList[index].title,
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
