import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/all_songs/all_songs.dart';
import 'package:podds/db_functions/favorite_db.dart';
import 'package:podds/db_functions/recent_songs.dart';
import 'package:podds/favorites/fav_button.dart';
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
              child: Image.asset('assets/iphone-5459688-removebg-preview.png'),
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
                          Get.to(
                              PlayerScreen(
                                audioPlayer: AllSongs.audioPlayer,
                                index: index,
                                songName: FavoriteFunction.tempFav,
                                id: AllSongs.songs[value[index]].id,
                              ),
                              transition: Transition.downToUp,
                              duration: const Duration(milliseconds: 500));
                        },
                        leading: CircleAvatar(
                          radius: 25,
                          child: QueryArtworkWidget(
                            artworkFit: BoxFit.fill,
                            id: AllSongs.songs[value[index]].id,
                            type: ArtworkType.AUDIO,
                            nullArtworkWidget: const Icon(Icons.music_note),
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
