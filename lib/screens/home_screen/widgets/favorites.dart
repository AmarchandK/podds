import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/screens/favorites/FavButton/fav_button.dart';
import '../../all_songs/all_songs.dart';
import '../../../db_functions/fav_db_functions.dart';
import '../../../db_functions/recent_songs.dart';
import '../../../functions/constants/styles.dart';
import '../../../functions/get_all_songs/get_all_songs.dart';
import '../../now_playing/player_screen.dart';

class HomeFavorites extends StatelessWidget {
  HomeFavorites({Key? key}) : super(key: key);
  final FavDbFunctions _dbController = Get.find();
  final RecentSongsController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: GetBuilder<FavDbFunctions>(
        builder: (controller) {
          final tempList = _dbController.favorites;
          if (tempList.isEmpty) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Image.asset('assets/nullHome.png'),
            ));
          } else {
            return ListView.builder(
              itemCount: tempList.length > 5 ? 5 : tempList.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    _controller
                        .addRecentlyPlayed(AllSongs.songs[tempList[index]].id);
                    GetAllSongs.audioPlayer.setAudioSource(
                        GetAllSongs.createSongList(_dbController.favloop),
                        initialIndex: index);
                    GetAllSongs.audioPlayer.play();
                    Get.to(
                      () => PlayerScreen(
                        songModal: _dbController.favloop,
      
                      ),
                      transition: Transition.downToUp,
                      duration: const Duration(milliseconds: 500),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, top: 10),
                    child: Column(
                      children: [
                        Material(
                          elevation: 10,
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              Container(
                                decoration: stylesClass.background(),
                                height: 150,
                                width: 150,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: QueryArtworkWidget(
                                    artworkBorder: BorderRadius.circular(0),
                                    artworkFit: BoxFit.fill,
                                    id: AllSongs.songs[tempList[index]].id,
                                    type: ArtworkType.AUDIO,
                                    nullArtworkWidget: Image.asset(
                                      'assets/podds.png',
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                              FavButton(id: AllSongs.songs[tempList[index]].id)
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: SizedBox(
                            width: 130,
                            child: Center(
                              child: Text(
                                AllSongs.songs[tempList[index]].title,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
