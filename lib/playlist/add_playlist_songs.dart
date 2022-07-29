// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/all_songs/all_songs.dart';
import 'package:podds/functions/styles.dart';

import 'package:podds/playlist/playlist_button.dart';

class AddToPlaylist extends StatefulWidget {
  AddToPlaylist(
      {Key? key, required this.playlistName, required this.folderIndex})
      : super(key: key);
  String playlistName;
  static List<SongModel> addSong = AllSongs.songs;
  final int folderIndex;
  @override
  State<AddToPlaylist> createState() => _AddToPlaylistState();
}

class _AddToPlaylistState extends State<AddToPlaylist> {
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
        body: ListView.builder(
          primary: false,
          shrinkWrap: true,
          itemCount: AddToPlaylist.addSong.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Card(
                color: const Color.fromARGB(119, 21, 153, 140),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    child: QueryArtworkWidget(
                      artworkFit: BoxFit.fill,
                      id: AddToPlaylist.addSong[index].id,
                      type: ArtworkType.AUDIO,
                      nullArtworkWidget: const Icon(Icons.music_note),
                    ),
                  ),
                  trailing: PlayListAddButton(
                    id: AddToPlaylist.addSong[index].id,
                    index: index,
                    folderindex: widget.folderIndex,
                  ),
                  title: Text(
                    AddToPlaylist.addSong[index].displayNameWOExt,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                  subtitle: const Text('Tap to play'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
