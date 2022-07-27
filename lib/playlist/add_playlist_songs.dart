// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/player_screen.dart';
import 'package:podds/playlist/playlist_button.dart';

class AddToPlaylistScreen extends StatefulWidget {
  AddToPlaylistScreen(
      {Key? key, required this.playlistName, required this.folderIndex})
      : super(key: key);
  String playlistName;
  static List<SongModel> songs = [];
  final int folderIndex;
  @override
  State<AddToPlaylistScreen> createState() => _AddToPlaylistScreenState();
}

class _AddToPlaylistScreenState extends State<AddToPlaylistScreen> {
  @override
  final audioQuery = OnAudioQuery();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: stylesClass.background(),
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: color1,
            elevation: 0,
            title: Text('Add to ${widget.playlistName} '),
            centerTitle: true,
          ),
          backgroundColor: Colors.transparent,
          body: FutureBuilder<List<SongModel>>(
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
                  AddToPlaylistScreen.songs = item.data!;
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
                              onTap: () => Get.to(
                                  PlayerScreen(
                                    songName: item.data!,
                                    audioPlayer: StylesPage.audioPlayer,
                                    index: index,
                                    id: AddToPlaylistScreen.songs[index].id,
                                  ),
                                  transition: Transition.downToUp,
                                  duration: const Duration(milliseconds: 500)),
                              leading: CircleAvatar(
                                radius: 25,
                                child: QueryArtworkWidget(
                                  artworkFit: BoxFit.fill,
                                  id: item.data![index].id,
                                  type: ArtworkType.AUDIO,
                                  nullArtworkWidget:
                                      const Icon(Icons.music_note),
                                ),
                              ),
                              trailing: PlayListAddButton(
                                id: AddToPlaylistScreen.songs[index].id,
                                index: index,
                                folderindex: widget.folderIndex,
                              ),
                              // trailing: Icon(Icons.abc),
                              title: Text(
                                AddToPlaylistScreen
                                    .songs[index].displayNameWOExt,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                              ),
                              subtitle: const Text('Tap to play'),
                            ),
                          ),
                        );
                      });
                }
              })),
    );
  }
}
