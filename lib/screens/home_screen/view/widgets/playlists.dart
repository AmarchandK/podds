import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../playlists/controller/playlist_db_controller.dart';
import '../../../../global_constants/styles.dart';
import '../../../playlists/view/playlist_view.dart';

class HomePlaylist extends StatelessWidget {
  HomePlaylist({Key? key}) : super(key: key);
  final PlayListcontroller _playlistcontroller = Get.put(PlayListcontroller());

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: GetBuilder<PlayListcontroller>(
        builder: (controler) {
          final playLists = _playlistcontroller.playListNotifier;
          if (playLists.isEmpty) {
            return EmptyWidget(
              image: 'assets/nullHome.png',
            );
          } else {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: playLists.length,
              itemBuilder: (BuildContext context, int index) {
                final playlistDataTemp = playLists[index];
                return GestureDetector(
                  onTap: () {
                    _playlistcontroller.showSelectSong(index);
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
                            height: 140,
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
