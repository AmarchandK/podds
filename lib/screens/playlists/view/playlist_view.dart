// ignore_for_file: must_be_immutable, no_leading_underscores_for_local_identifiers

import 'package:empty_widget/empty_widget.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:get/state_manager.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/screens/playlists/controller/playlist_db_controller.dart';
import 'package:podds/screens/home_screen/controller/recent_controller.dart';
import 'package:podds/global_constants/styles.dart';
import 'package:podds/screens/playlists/view/widgets/playlist_button.dart';
import '../../../global_constants/get_all_songs.dart';
import '../../bottombar/view/base_screen.dart';
import '../../now_playing/view/player_screen.dart';
import 'add_playlist_songs.dart';

class PlaylistView extends StatelessWidget {
  PlaylistView(
      {Key? key, required this.folderIndex, required this.playlistName})
      : super(key: key);
  final int folderIndex;
  final String playlistName;
  final PlayListcontroller _listcontroller = Get.put(PlayListcontroller());
  final RecentSongsController _controller = Get.put(RecentSongsController());

  @override
  Widget build(BuildContext context) {
    // _listcontroller.showSelectSong(folderIndex);
    return Container(
      decoration: stylesClass.background(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: color1,
          label: const Text(
            'Add Songs',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () => Get.to(
              () => AddToPlaylist(
                    playlistName: playlistName,
                    folderIndex: folderIndex,
                  ),
              transition: Transition.downToUp),
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: Padding(
                padding: const EdgeInsets.only(left: .0),
                child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    )),
              ),
              floating: true,
              flexibleSpace: FlexibleSpaceBar(
                expandedTitleScale: 2,
                // collapseMode: CollapseMode.pin,
                title: stylesClass.textStyle(hometext: playlistName),
                centerTitle: true,
                background: Image.asset(
                  'assets/podds.png',
                  fit: BoxFit.cover,
                ),
              ),
              backgroundColor: color2,
              expandedHeight: MediaQuery.of(context).size.height / 3,
              actions: [
                PopupMenuButton<int>(
                  color: color2,
                  elevation: 0,
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    // PopupMenuItem(
                    //     child: TextButton.icon(
                    //         label: const Text("Rename"),
                    //         onPressed: () =>
                    //             renamePlaylsit(widget.folderIndex),
                    //         icon: const Icon(Icons
                    //             .drive_file_rename_outline_outlined))),
                    // const PopupMenuDivider(
                    //   height: 5,
                    // ),
                    PopupMenuItem(
                      child: TextButton.icon(
                        label: Text(
                          "Delete $playlistName",
                          style: const TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Get.defaultDialog(
                            title: "Delete $playlistName",
                            middleText: "Are you sure!",
                            backgroundColor: color1,
                            textConfirm: 'Yes',
                            onConfirm: () {
                              _listcontroller.deletePlayList(folderIndex);
                              baseIndex.value = 2;
                              Get.off(() => BaseScreen());
                            },
                          );
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  ],
                )
              ],
            ),
            SliverToBoxAdapter(
              child: GetBuilder<PlayListcontroller>(
                builder: (controller) {
                  final _playListSongs = _listcontroller.selectPlaySong;
                  if (_playListSongs.isEmpty) {
                    return EmptyWidget(
                      image: 'assets/nullHome.png',
                    );
                  } else {
                    return ListView.builder(
                      itemCount: _listcontroller
                          .playListNotifier[folderIndex].playlistSongs.length,
                      itemBuilder: (BuildContext context, int playIndex) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Card(
                            color: const Color.fromARGB(119, 21, 153, 140),
                            child: ListTile(
                              onTap: () {
                                _controller.addRecentlyPlayed(
                                    _playListSongs[playIndex].id);
                                GetAllSongs.audioPlayer.setAudioSource(
                                    GetAllSongs.createSongList(_playListSongs),
                                    initialIndex: playIndex);
                                GetAllSongs.audioPlayer.play();
                                Get.to(() => PlayerScreen(
                                      songModal: _playListSongs,
                                    ));
                              },
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor: color1,
                                child: QueryArtworkWidget(
                                  artworkFit: BoxFit.fill,
                                  id: _playListSongs[playIndex].id,
                                  type: ArtworkType.AUDIO,
                                  nullArtworkWidget: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Image.asset(
                                      'assets/logo.png',
                                    ),
                                  ),
                                ),
                              ),
                              subtitle: const Text('Tap to play'),
                              title: Text(
                                _playListSongs[playIndex].title,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                              ),
                              trailing: PlayListAddButton(
                                  folderindex: folderIndex,
                                  id: _playListSongs[playIndex].id),
                            ),
                          ),
                        );
                      },
                      primary: false,
                      shrinkWrap: true,
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
  // final TextEditingController _textEditingController = TextEditingController();

  // renamePlaylsit(index) async {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Rename Playlist'),
  //       content: TextField(
  //         controller: _textEditingController,
  //         autofocus: true,
  //         decoration: const InputDecoration(
  //           hintText: 'Playlist name',
  //           border: OutlineInputBorder(),
  //         ),
  //       ),
  //       actions: [
  //         OutlinedButton(
  //           onPressed: () {
  //             final playReName = _textEditingController.text.trim();
  //             if (playReName.isNotEmpty) {
  //               // final _newlist =
  //               //     PlayListModel(playListName: _playName, playlistSongs: []);
  //               // updateList(index, playReName);
  //               _textEditingController.clear();
  //               Navigator.of(context).pop(MaterialPageRoute(
  //                 builder: (context) => const PlaylistScreen(),
  //               ));
  //             }
  //           },
  //           child: const Text('Rename'),
  //         ),
  //         OutlinedButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         )
  //       ],
  //     ),
  //   );
  // }
}
