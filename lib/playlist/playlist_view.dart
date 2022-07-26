// ignore_for_file: must_be_immutable
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/base_screen.dart';
import 'package:podds/db_functions/playlist_db_functions.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/paly_list_model/play_list_model.dart';
import 'package:podds/playlist/add_playlist_songs.dart';

class PlaylistView extends StatefulWidget {
  PlaylistView(
      {Key? key, required this.folderIndex, required this.playlistName})
      : super(key: key);
  final int folderIndex;
  String playlistName;
  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  void initState() {
    super.initState();
    getAllPlaylist();
  }

  @override
  Widget build(BuildContext context) {
    PlaysongCheck.showSelectSong(widget.folderIndex);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: color1,
        child: const Icon(
          Icons.add,
          color: color2,
        ),
        onPressed: () => Get.to(
            AddToPlaylistScreen(
              playlistName: widget.playlistName,
              folderIndex: widget.folderIndex,
            ),
            transition: Transition.downToUp),
      ),
      body: Container(
        decoration: stylesClass.background(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(),
          body: ValueListenableBuilder(
            valueListenable: playListNotifier,
            builder: (BuildContext ctx, List<dynamic> savedPlaylistSongsValue,
                Widget? child) {
              return ListView.builder(
                // itemCount: 1,
                itemCount: playListNotifier
                    .value[widget.folderIndex].playlistSongs.length,
                itemBuilder: (BuildContext context, int index) {
                  if (playListNotifier
                      .value[widget.folderIndex].playlistSongs.isEmpty) {
                    return const Text('No Songs Added');
                  } else {
                    return ListTile(
                      leading: QueryArtworkWidget(
                        artworkFit: BoxFit.fill,

                        // id: AddToPlaylistScreen.songs[index].id,
                        id: StylesPage
                            .songs[PlaysongCheck.selectPlaySong.value[index]]
                            .id,
                        type: ArtworkType.AUDIO,
                        nullArtworkWidget: const Icon(Icons.music_note),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
      // child: CustomScrollView(
      //   slivers: [
      //     SliverAppBar(
      //       leading: Padding(
      //         padding: const EdgeInsets.only(left: .0),
      //         child: IconButton(
      //             onPressed: () => Navigator.pop(context),
      //             icon: const Icon(
      //               Icons.arrow_back_ios,
      //               color: Colors.white,
      //             )),
      //       ),
      //       floating: true,
      //       flexibleSpace: FlexibleSpaceBar(
      //         expandedTitleScale: 2,
      //         // collapseMode: CollapseMode.pin,
      //         title: stylesClass.textStyle(hometext: widget.playlistName),
      //         centerTitle: true,
      //         background: Image.asset(
      //           'assets/podds.png',
      //           fit: BoxFit.cover,
      //         ),
      //       ),
      //       backgroundColor: color2,
      //       expandedHeight: MediaQuery.of(context).size.height / 3,
      //       actions: [
      //         PopupMenuButton<int>(
      //             color: color2,
      //             elevation: 0,
      //             icon: const Icon(Icons.more_vert),
      //             itemBuilder: (context) => [
      //                   PopupMenuItem(
      //                       child: TextButton.icon(
      //                           label: const Text("Rename"),
      //                           onPressed: null,
      //                           icon: const Icon(Icons
      //                               .drive_file_rename_outline_outlined))),
      //                   const PopupMenuDivider(
      //                     height: 5,
      //                   ),
      //                   PopupMenuItem(
      //                     child: TextButton.icon(
      //                       label: const Text("Delete Playlist"),
      //                       onPressed: () {
      //                         deletePlayList(widget.folderIndex);
      //                         setState(() {
      //                           baseIndex = 2;
      //                         });
      //                         Navigator.pushAndRemoveUntil(
      //                             context,
      //                             MaterialPageRoute(
      //                                 builder: (context) => BaseScreen()),
      //                             (route) => false);
      //                       },
      //                       icon: const Icon(Icons.delete_outline),
      //                     ),
      //                   ),
      //                 ])
      //       ],
      //     ),
      //     // SliverToBoxAdapter(child: stylesClass.allsongList()),
      //     SliverToBoxAdapter(
      //       child: ValueListenableBuilder(
      //         valueListenable: playListNotifier,
      //         builder: (BuildContext context,
      //             List<PlayListModel> savedPlaylistSongsValue,
      //             Widget? child) {
      //           return ListView.builder(
      //             itemCount: playListNotifier
      //                 .value[widget.folderIndex].playlistSongs.length,
      //             itemBuilder: (BuildContext context, int index) {
      //               if (savedPlaylistSongsValue.isEmpty) {
      //                 return const Text('No Songs Added');
      //               } else {
      //                 return ListTile(
      //                   leading: QueryArtworkWidget(
      //                     artworkFit: BoxFit.fill,
      //                     id: playListNotifier.value[widget.folderIndex]
      //                         .playlistSongs[index].id,
      //                     type: ArtworkType.AUDIO,
      //                     nullArtworkWidget: const Icon(Icons.music_note),
      //                   ),
      //                 );
      //               }
      //             },
      //           );
      //         },
      //       ),
      //     )
      //   ],
      // ),
    );
  }
}
