import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/screens/libary/controller/fav_db_controller.dart';
import 'package:podds/screens/libary/view/widgets/fav_button.dart';
import 'package:podds/screens/home_screen/controller/recent_controller.dart';
import 'package:podds/global_constants/styles.dart';

import '../../../../global_constants/get_all_songs.dart';
import '../../../now_playing/view/player_screen.dart';

class AllSongs extends StatelessWidget {
  AllSongs({Key? key}) : super(key: key);
  static List<SongModel> songs = [];
  final audioQuery = OnAudioQuery();
  final RecentSongsController _controller = Get.put(RecentSongsController());

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
              onTap: () {
                GetAllSongs.audioPlayer.setAudioSource(
                    GetAllSongs.createSongList(songs),
                    initialIndex: index);
                GetAllSongs.audioPlayer.play();
                _controller.addRecentlyPlayed(songs[index].id);
                Get.to(
                  () => PlayerScreen(
                    songModal: songs,
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
                      'assets/logo.png',
                    ),
                  )),
                ),
              ),
              trailing: GetBuilder<FavDbController>(
                builder: (controller) => FavButton(id: songs[index].id),
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
