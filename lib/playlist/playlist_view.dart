// ignore_for_file: must_be_immutable
import 'dart:developer';

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/all_songs/all_songs.dart';
import 'package:podds/base_screen.dart';
import 'package:podds/db_functions/playlist_db_functions.dart';
import 'package:podds/db_functions/recent_songs.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/player_screen.dart';
import 'package:podds/playlist/add_playlist_songs.dart';
import 'package:podds/playlist/playlist.dart';
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

  List<dynamic> tempPlaySongs = [];
  final TextEditingController _textEditingController = TextEditingController();
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
              AddToPlaylist(
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
                                  onPressed: () =>
                                      renamePlaylsit(widget.folderIndex),
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
                                        builder: (context) =>
                                            const BaseScreen()),
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
                valueListenable: PlaysongCheck.selectPlaySong,
                builder: (BuildContext context, List<SongModel> songs,
                    Widget? child) {
                  if (songs.isEmpty) {
                    return Align(
                      child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Image.asset('assets/nullHome.png'),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: playListNotifier
                          .value[widget.folderIndex].playlistSongs.length,
                      itemBuilder: (BuildContext context, int playIndex) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Card(
                            color: const Color.fromARGB(119, 21, 153, 140),
                            child: ListTile(
                              onTap: () {
                                RecentSongs.addRecentlyPlayed(
                                    songs[playIndex].id);
                                Get.to(PlayerScreen(
                                  id: songs[playIndex].id,
                                  songModal: songs,
                                  index: playIndex,
                                ));
                              },
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor: color1,
                                child: QueryArtworkWidget(
                                  artworkFit: BoxFit.fill,
                                  id: songs[playIndex].id,
                                  type: ArtworkType.AUDIO,
                                  nullArtworkWidget: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Image.asset(
                                      'assets/1-removebg-preview.png',
                                    ),
                                  ),
                                ),
                              ),
                              subtitle: const Text('Tap to play'),
                              title: Text(
                                songs[playIndex].title,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                              ),
                              trailing: PlayListAddButton(
                                  index: playIndex,
                                  folderindex: widget.folderIndex,
                                  id: songs[playIndex].id),
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

  renamePlaylsit(index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Playlist'),
        content: TextField(
          controller: _textEditingController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Playlist name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              final playReName = _textEditingController.text.trim();
              if (playReName.isNotEmpty) {
                // final _newlist =
                //     PlayListModel(playListName: _playName, playlistSongs: []);
                // updateList(index, playReName);
                _textEditingController.clear();
                Navigator.of(context).pop(MaterialPageRoute(
                  builder: (context) => const PlaylistScreen(),
                ));
              }
            },
            child: const Text('Rename'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          )
        ],
      ),
    );
  }
}
