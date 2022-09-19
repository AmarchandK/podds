import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/screens/all_songs/all_songs.dart';
import 'package:podds/db_functions/playlist_db_functions.dart';
import 'package:podds/functions/constants/styles.dart';
import 'package:podds/screens/playlists/widgets/playlist_button.dart';
import '../../functions/get_all_songs/get_all_songs.dart';

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
          leading: IconButton(
              onPressed: () {
                Get.back();
                GetAllSongs.audioPlayer.stop();
              },
              icon: const Icon(Icons.arrow_back)),
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
                  onTap: () {
                    GetAllSongs.audioPlayer.setAudioSource(
                        GetAllSongs.createSongList(addSong),
                        initialIndex: index);
                    GetAllSongs.audioPlayer.play();
                  },
                  leading: CircleAvatar(
                    radius: 25,
                    child: QueryArtworkWidget(
                      artworkFit: BoxFit.fill,
                      id: AddToPlaylist.addSong[index].id,
                      type: ArtworkType.AUDIO,
                      nullArtworkWidget: const Icon(Icons.music_note),
                    ),
                  ),
                  trailing: GetBuilder<PlayListcontroller>(
                    builder: (controller) => PlayListAddButton(
                      id: AddToPlaylist.addSong[index].id,
                      folderindex: folderIndex,
                    ),
                  ),
                  subtitle: const Text(
                    'Tap to play',
                    style: TextStyle(color: Colors.grey),
                  ),
                  title: Text(
                    AddToPlaylist.addSong[index].displayNameWOExt,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: const TextStyle(color: color2),
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
