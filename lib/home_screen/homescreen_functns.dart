import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/all_songs/all_songs.dart';
import 'package:podds/db_functions/favorite_db.dart';
import 'package:podds/db_functions/playlist_db_functions.dart';
import 'package:podds/db_functions/recent_songs.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/paly_list_model/play_list_model.dart';
import 'package:podds/playlist/playlist_view.dart';
import '../player_screen.dart';

///////////////////////////////////////
//////////////////////////////////////////
class HomeAllSongs extends StatelessWidget {
  HomeAllSongs({Key? key}) : super(key: key);
  final audioQuery = OnAudioQuery();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: FutureBuilder<List<SongModel>>(
        future: audioQuery.querySongs(
            orderType: OrderType.ASC_OR_SMALLER,
            sortType: SongSortType.TITLE,
            uriType: UriType.EXTERNAL,
            ignoreCase: true),
        builder: (context, item) {
          if (item.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (item.data!.isEmpty) {
            return const Center(child: Text('No Songs Found'));
          } else {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: item.data!.length > 7 ? 7 : item.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    RecentSongs.addRecentlyPlayed(item.data![index].id);
                    Get.to(
                        () => PlayerScreen(
                              songName: item.data!,
                              index: index,
                              audioPlayer: AllSongs.audioPlayer,
                              id: AllSongs.songs[index].id,
                            ),
                        transition: Transition.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 500));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, top: 10),
                    child: Column(
                      children: [
                        Material(
                          elevation: 10,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: stylesClass.background(),
                            height: 150,
                            width: 150,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: QueryArtworkWidget(
                                artworkBorder: BorderRadius.circular(0),
                                artworkFit: BoxFit.fill,
                                id: item.data![index].id,
                                type: ArtworkType.AUDIO,
                                nullArtworkWidget: Image.asset(
                                  'assets/podds.png',
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: SizedBox(
                            width: 130,
                            child: Center(
                              child: Text(
                                item.data![index].displayNameWOExt,
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

//////////////////////////////////////////////////////////
////
/////////////////////////////////////////////////////////
class HomeFavorites extends StatelessWidget {
  const HomeFavorites({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ValueListenableBuilder(
        valueListenable: FavoriteDB.favorites,
        builder: (BuildContext context, List<dynamic> value, Widget? child) {
          // tempFav.addAll(FavoriteDB.favloop);
          if (value.isEmpty) {
            return const Center(child: Text('No Favorites Added'));
          } else {
            return ListView.builder(
              itemCount: value.length > 5 ? 5 : value.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    RecentSongs.addRecentlyPlayed(
                        AllSongs.songs[value[index]].id);
                    Get.to(
                      () => PlayerScreen(
                        audioPlayer: AllSongs.audioPlayer,
                        index: index,
                        songName: FavoriteDB.favloop,
                        id: AllSongs.songs[value[index]].id,
                      ),
                      transition: Transition.rightToLeftWithFade,
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
                          child: Container(
                            decoration: stylesClass.background(),
                            height: 150,
                            width: 150,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: QueryArtworkWidget(
                                artworkBorder: BorderRadius.circular(0),
                                artworkFit: BoxFit.fill,
                                id: AllSongs.songs[value[index]].id,
                                type: ArtworkType.AUDIO,
                                nullArtworkWidget: Image.asset(
                                  'assets/podds.png',
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: SizedBox(
                            width: 130,
                            child: Center(
                              child: Text(
                                AllSongs.songs[value[index]].title,
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

///////////////////////////////////////////
///////////////////////////////////////////////
class HomePlaylist extends StatelessWidget {
  const HomePlaylist({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ValueListenableBuilder(
        valueListenable: playListNotifier,
        builder: (BuildContext context, List<PlayListModel> savedPlaylistvalue,
            Widget? child) {
          if (savedPlaylistvalue.isEmpty) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          } else {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: savedPlaylistvalue.length,
              itemBuilder: (BuildContext context, int index) {
                final playlistDataTemp = savedPlaylistvalue[index];

                return GestureDetector(
                  onTap: () {
                    Get.to(
                      () => PlaylistView(
                        folderIndex: index,
                        playlistName: playlistDataTemp.playListName,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, top: 10),
                    child: Column(
                      children: [
                        Material(
                          elevation: 10,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: stylesClass.background(),
                            height: 150,
                            width: 150,
                            child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Image.asset(
                                  'assets/podds.png',
                                  fit: BoxFit.fill,
                                )),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: SizedBox(
                            width: 130,
                            child: Center(
                              child: Text(
                                playlistDataTemp.playListName,
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

/////////////////////////////////////////////
////////////////////////////////////////////
class HomeRecentsSongs extends StatelessWidget {
  const HomeRecentsSongs({Key? key}) : super(key: key);
  static List removedup = [];
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ValueListenableBuilder(
        valueListenable: RecentSongs.recentsNotifier,
        builder:
            (BuildContext context, List<dynamic> recentValue, Widget? child) {
          if (recentValue.isEmpty) {
            return const Center(
              child: Text('No Songs Played'),
            );
          } else {
            final temp = recentValue.reversed.toList();
            removedup = temp.toSet().toList();

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: removedup.length > 10 ? 10 : removedup.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 10, top: 5),
                  child: GestureDetector(
                    onTap: () {
                      RecentSongs.addRecentlyPlayed(
                          AllSongs.songs[removedup[index]].id);
                      Get.to(
                        () => PlayerScreen(
                          audioPlayer: AllSongs.audioPlayer,
                          index: removedup[index],
                          songName: AllSongs.songs,
                          id: AllSongs.songs[removedup[index]].id,
                        ),
                        transition: Transition.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 500),
                      );
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: color2,
                          radius: 40,
                          child: QueryArtworkWidget(
                              artworkBorder: BorderRadius.circular(100),
                              artworkHeight: 75,
                              artworkWidth: 75,
                              artworkFit: BoxFit.fill,
                              id: AllSongs.songs[removedup[index]].id,
                              type: ArtworkType.AUDIO,
                              nullArtworkWidget: const Icon(
                                Icons.music_note,
                                color: color1,
                                size: 35,
                              )),
                        ),
                        SizedBox(
                          width: 70,
                          child: Center(
                            child: Text(
                              AllSongs.songs[removedup[index]].title,
                              overflow: TextOverflow.fade,
                              softWrap: false,
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
