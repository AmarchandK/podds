import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:get/state_manager.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/screens/all_songs/all_songs.dart';
import 'package:podds/db_functions/fav_db_functions.dart';
import 'package:podds/db_functions/playlist_db_functions.dart';
import 'package:podds/db_functions/recent_songs.dart';
import 'package:podds/functions/constants/styles.dart';
import 'package:podds/screens/playlists/playlist_view.dart';
import '../../../functions/get_all_songs/get_all_songs.dart';
import '../../now_playing/player_screen.dart';

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


///////////////////////////////////////////
///////////////////////////////////////////////


/////////////////////////////////////////////
////////////////////////////////////////////
