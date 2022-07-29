// ignore_for_file: must_be_immutable
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/all_songs/all_songs.dart';
import 'package:podds/base_screen.dart';
import 'package:podds/db_functions/playlist_db_functions.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/player_screen.dart';
import 'package:podds/playlist/add_playlist_songs.dart';
import 'package:podds/playlist/playlist_button.dart';

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
  @override
  void initState() {
    getAllPlaylist();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PlaysongCheck.showSelectSong(widget.folderIndex);
    return Container(
      decoration: stylesClass.background(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                title: stylesClass.textStyle(hometext: widget.playlistName),
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
                          PopupMenuItem(
                              child: TextButton.icon(
                                  label: const Text("Rename"),
                                  onPressed: null,
                                  icon: const Icon(Icons
                                      .drive_file_rename_outline_outlined))),
                          const PopupMenuDivider(
                            height: 5,
                          ),
                          PopupMenuItem(
                            child: TextButton.icon(
                              label: const Text("Delete Playlist"),
                              onPressed: () {
                                deletePlayList(widget.folderIndex);
                                setState(() {
                                  baseIndex = 2;
                                });
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BaseScreen()),
                                    (route) => false);
                              },
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ),
                        ])
              ],
            ),
            SliverToBoxAdapter(
              child: ValueListenableBuilder(
                valueListenable: playListNotifier,
                builder: (BuildContext context,
                    List<dynamic> savedPlaylistSongsValue, Widget? child) {
                  return ListView.builder(
                    itemCount: playListNotifier
                        .value[widget.folderIndex].playlistSongs.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (savedPlaylistSongsValue.isEmpty) {
                        return const Text('No Songs Added');
                      } else {
                        return ListTile(
                          onTap: () => Get.to(PlayerScreen(
                              id: AllSongs.songs[index].id,
                              songName: AddToPlaylistScreen.songs,
                              audioPlayer: AllSongs.audioPlayer,
                              index: index)),
                          leading: QueryArtworkWidget(
                            artworkFit: BoxFit.fill,
                            id: AddToPlaylistScreen
                                .songs[
                                    PlaysongCheck.selectPlaySong.value[index]]
                                .id,
                            type: ArtworkType.AUDIO,
                            nullArtworkWidget: const Icon(Icons.music_note),
                          ),
                          title: Text(AddToPlaylistScreen
                              .songs[PlaysongCheck.selectPlaySong.value[index]]
                              .title),
                          trailing: PlayListAddButton(
                              index: index,
                              folderindex: widget.folderIndex,
                              id: AddToPlaylistScreen
                                  .songs[
                                      PlaysongCheck.selectPlaySong.value[index]]
                                  .id),
                        );
                      }
                    },
                    primary: false,
                    shrinkWrap: true,
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
