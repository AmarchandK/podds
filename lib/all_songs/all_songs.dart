import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/db_functions/recent_songs.dart';
import 'package:podds/favorites/fav_button.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/player_screen.dart';

class AllSongs extends StatelessWidget {
  AllSongs({Key? key}) : super(key: key);
  static List<SongModel> songs = [];
  final audioQuery = OnAudioQuery();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: songs.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Card(
            color: const Color.fromARGB(119, 21, 153, 140),
            child: ListTile(
              // onTap: () => NowPlay(playerSong: so),
              onTap: () {
                RecentSongs.addRecentlyPlayed(songs[index].id);
                Get.to(
                  () => PlayerScreen(
                    songModal: songs,
                    index: index,
                    id: songs[index].id,
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
                  id: songs[index].id,
                  type: ArtworkType.AUDIO,
                  nullArtworkWidget: Center(
                      child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Image.asset(
                      'assets/1-removebg-preview.png',
                    ),
                  )),
                ),
              ),
              trailing: FavBTN(
                id: songs[index].id,
              ),
              title: Text(
                songs[index].displayNameWOExt,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
              subtitle: const Text('Tap to play'),
            ),
          ),
        );
      },
    );
  }
}
