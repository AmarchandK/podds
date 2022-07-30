import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/db_functions/recent_songs.dart';
import 'package:podds/favorites/fav_button.dart';
import 'package:podds/player_screen.dart';

class AllSongs extends StatelessWidget {
  AllSongs({Key? key}) : super(key: key);
 static List<SongModel> songs = [];
  final audioQuery = OnAudioQuery();

  @override
  Widget build(BuildContext context) {
    return  Builder(builder: (context) {
      return FutureBuilder<List<SongModel>>(
          future: audioQuery.querySongs(
              orderType: OrderType.ASC_OR_SMALLER,
              sortType: SongSortType.DURATION,
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
              songs = item.data!;
              return ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: item.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Card(
                        color: const Color.fromARGB(119, 21, 153, 140),
                        child: ListTile(
                          onTap: () {
                            Get.to(() =>
                                PlayerScreen(
                                  songName: item.data!,
                                 
                                  index: index,
                                  id: songs[index].id,
                                ),
                                transition: Transition.downToUp,
                                duration: const Duration(milliseconds: 500));

                            RecentSongs.addRecentlyPlayed(item.data!);
                          },
                          leading: CircleAvatar(
                            radius: 25,
                            child: QueryArtworkWidget(
                              artworkFit: BoxFit.fill,
                              id: item.data![index].id,
                              type: ArtworkType.AUDIO,
                              nullArtworkWidget: const Icon(Icons.music_note),
                            ),
                          ),
                          trailing: FavBTN(
                            id: songs[index].id,
                          ),
                          title: Text(
                            item.data![index].displayNameWOExt,
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
    });
  }
}