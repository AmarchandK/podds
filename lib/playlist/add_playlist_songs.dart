import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/all_songs/all_songs.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/playlist/playlist_button.dart';

import '../screens/get_all_songs.dart';

class AddToPlaylist extends StatelessWidget {
   AddToPlaylist(
      {Key? key, required this.playlistName, required this.folderIndex})
      : super(key: key);
  final String playlistName;
  static List<SongModel> addSong = AllSongs.songs;
  final int folderIndex;

  final audioQuery = OnAudioQuery();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: stylesClass.background(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: color1,
          elevation: 0,
          title: Text('Add to $playlistName '),
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
                  onTap: () => GetAllSongs.audioPlayer.play(),
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
                    folderindex: folderIndex,
                  ),
                  title: Text(
                    AddToPlaylist.addSong[index].displayNameWOExt,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
