import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:get/state_manager.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/all_songs/all_songs.dart';
import 'package:podds/db_functions/fav_db_functions.dart';
import 'package:podds/db_functions/playlist_db_functions.dart';
import 'package:podds/db_functions/recent_songs.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/playlist/playlist_view.dart';
import '../screens/get_all_songs.dart';
import '../screens/player_screen.dart';

///////////////////////////////////////
//////////////////////////////////////////
class HomeAllSongs extends StatelessWidget {
  HomeAllSongs({Key? key}) : super(key: key);
  final audioQuery = OnAudioQuery();
  final RecentSongsController _controller = Get.find();

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
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset('assets/nullHome.png'),
            ));
          } else {
            AllSongs.songs = item.data!;
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: item.data!.length > 7 ? 7 : item.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    _controller.addRecentlyPlayed(item.data![index].id);
                    GetAllSongs.audioPlayer.setAudioSource(
                        GetAllSongs.createSongList(item.data!),
                        initialIndex: index);
                    GetAllSongs.audioPlayer.play();
                    Get.to(
                        () => PlayerScreen(
                              songModal: item.data!,
                              id: item.data![index].id,
                            ),
                        transition: Transition.downToUp,
                        duration: const Duration(milliseconds: 500));
                    GetAllSongs.audioPlayer.play();
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
                        id: AllSongs.songs[tempList[index]].id,
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
                          child: Container(
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

///////////////////////////////////////////
///////////////////////////////////////////////
class HomePlaylist extends StatelessWidget {
  HomePlaylist({Key? key}) : super(key: key);
  final PlayListcontroller _playlistcontroller = Get.find();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: GetBuilder<PlayListcontroller>(
        builder: (controler) {
          final playLists = _playlistcontroller.playListNotifier;
          if (playLists.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Image.asset('assets/nullHome.png'),
              ),
            );
          } else {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: playLists.length,
              itemBuilder: (BuildContext context, int index) {
                final playlistDataTemp = playLists[index];
                return GestureDetector(
                  onTap: () {
                    Get.to(
                        () => PlaylistView(
                              folderIndex: index,
                              playlistName: playlistDataTemp.playListName,
                            ),
                        transition: Transition.rightToLeftWithFade);
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
  HomeRecentsSongs({Key? key}) : super(key: key);
  static List<SongModel> removedup = [];
  final RecentSongsController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: GetBuilder<RecentSongsController>(
        builder: (controller) {
          final recentValue = _controller.recentsNotifier;
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
                      GetAllSongs.audioPlayer.stop();
                      GetAllSongs.audioPlayer.setAudioSource(
                          GetAllSongs.createSongList(removedup),
                          initialIndex: index);
                      GetAllSongs.audioPlayer.play();

                      Get.to(
                        () => PlayerScreen(
                            songModal: removedup, id: removedup[index].id),
                        transition: Transition.downToUp,
                        duration: const Duration(milliseconds: 500),
                      );
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: color2,
                          child: CircleAvatar(
                            backgroundColor: color1,
                            radius: 38,
                            child: QueryArtworkWidget(
                                artworkBorder: BorderRadius.circular(100),
                                artworkHeight: 75,
                                artworkWidth: 75,
                                artworkFit: BoxFit.fill,
                                id: removedup[index].id,
                                type: ArtworkType.AUDIO,
                                nullArtworkWidget: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset('assets/logo.png'),
                                )),
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: Center(
                            child: Text(
                              removedup[index].title,
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
