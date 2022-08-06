import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:lottie/lottie.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/all_songs/all_songs.dart';
import 'package:podds/db_functions/favorite_db.dart';
import 'package:podds/db_functions/recent_songs.dart';
import 'package:podds/favorites/fav_button.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/get_all_songs.dart';
import 'package:podds/player_screen.dart';

class FavoriteFunction extends StatefulWidget {
  const FavoriteFunction({Key? key}) : super(key: key);
  static List<SongModel> tempFav = [];

  @override
  State<FavoriteFunction> createState() => _FavoriteFunctionState();
}

class _FavoriteFunctionState extends State<FavoriteFunction> {
  final controller = ScrollController();

  // var tempIndex = 0;
  @override
  void initState() {
    FavoriteDB.getAllSongs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: FavoriteDB.favorites,
        builder: (BuildContext context, List<dynamic> value, Widget? child) {
          // print(value);
          if (FavoriteDB.favloop.isEmpty) {
            return Center(
              child: Lottie.asset('assets/lf20_oq4hyt7j.json'),
            );
          } else {
            return ListView.builder(
                primary: false,
                shrinkWrap: true,
                // controller: controller,
                itemCount: value.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Card(
                      color: const Color.fromARGB(119, 21, 153, 140),
                      child: ListTile(
                        onTap: () {
                          FavoriteFunction.tempFav.clear();
                          FavoriteFunction.tempFav.addAll(FavoriteDB.favloop);
                          RecentSongs.addRecentlyPlayed(
                              AllSongs.songs[value[index]].id);
                          GetAllSongs.audioPlayer.setAudioSource(
                              GetAllSongs.createSongList(FavoriteDB.favloop),
                              initialIndex: index);
                          GetAllSongs.audioPlayer.play();
                          Get.to(
                            () => PlayerScreen(
                              songModal: FavoriteDB.favloop,
                              id: AllSongs.songs[value[index]].id,
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
                            id: AllSongs.songs[value[index]].id,
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
                        trailing: FavBTN(
                          id: AllSongs.songs[value[index]].id,
                        ),
                        title: Text(
                          AllSongs.songs[value[index]].title,
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
