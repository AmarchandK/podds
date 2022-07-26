import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../controller/recent_controller.dart';
import '../../../../global_constants/styles.dart';
import '../../../../global_constants/get_all_songs.dart';
import '../../../now_playing/view/player_screen.dart';

class HomeRecentsSongs extends StatelessWidget {
  HomeRecentsSongs({Key? key}) : super(key: key);
  static List<SongModel> removedup = [];
  final RecentSongsController _controller = Get.put(RecentSongsController());
  

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: GetBuilder<RecentSongsController>(
        builder: (controller) {
          final recentValue = _controller.recentsNotifier;
          if (recentValue.isEmpty) {
            return Center(
              child: EmptyWidget(
                title: 'No Songs \n Plalyed',
                titleTextStyle: const TextStyle(fontSize: 15, color: color2),
              ),
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
                          songModal: removedup,
                        ),
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
