import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/favorites/fav_button.dart';
import 'package:podds/player_screen.dart';

const color1 = Color.fromARGB(255, 25, 124, 124);
const color2 = Color.fromARGB(255, 0, 204, 204);
final stylesClass = StylesPage();

class StylesPage extends StatefulWidget {
  StylesPage({Key? key}) : super(key: key);
  static List<SongModel> songs = [];
  final audioQuery = OnAudioQuery();
  static AudioPlayer audioPlayer = AudioPlayer();
  @override
  State<StylesPage> createState() => _StylesPageState();

  Widget allsongList() {
    return Builder(builder: (context) {
      return FutureBuilder<List<SongModel>>(
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
              songs = item.data!;
              return ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: item.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      color: const Color.fromARGB(119, 21, 153, 140),
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 5, left: 5, right: 5),
                        child: ListTile(
                          onTap: () => Get.to(
                              PlayerScreen(
                                songName: item.data!,
                                audioPlayer: audioPlayer,
                                index: index,
                                id: songs[index].id,
                              ),
                              transition: Transition.downToUp,
                              duration: const Duration(milliseconds: 500)),
                          leading: CircleAvatar(
                            radius: 25,
                            child: QueryArtworkWidget(
                              artworkFit: BoxFit.fill,
                              id: item.data![index].id,
                              type: ArtworkType.AUDIO,
                              nullArtworkWidget: const Icon(Icons.music_note),
                            ),
                          ),
                          trailing: FavBTN(
                            id: songs[index].id,
                          ),
                          title: Text(
                            item.data![index].displayNameWOExt,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ),
                          subtitle: const Text('Tap to play'),
                        ),
                      ),
                    );
                  });
            }
          });
    });
  }

  Widget addToPlayList() {
    return Builder(builder: (context) {
      return FutureBuilder<List<SongModel>>(
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
              songs = item.data!;
              return ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: item.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      color: const Color.fromARGB(119, 21, 153, 140),
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 5, left: 5, right: 5),
                        child: ListTile(
                          onTap: () {
                            Get.to(
                              // RecentSongs.addRecentlyPlayed(item.data!),
                                PlayerScreen(
                                  songName: item.data!,
                                  audioPlayer: audioPlayer,
                                  index: index,
                                  id: songs[index].id,
                                ),
                                transition: Transition.downToUp,
                                duration: const Duration(milliseconds: 500));
                          },
                          leading: CircleAvatar(
                            radius: 25,
                            child: QueryArtworkWidget(
                              artworkFit: BoxFit.fill,
                              id: item.data![index].id,
                              type: ArtworkType.AUDIO,
                              nullArtworkWidget: const Icon(Icons.music_note),
                            ),
                          ),
                          trailing: FavBTN(
                            id: songs[index].id,
                          ),
                          title: Text(
                            item.data![index].displayNameWOExt,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ),
                        ),
                      ),
                    );
                  });
            }
          });
    });
  }
//////////////////////////////////////////////////
/////////////////////////////////////////////////

  // playSong(String? uri) {}

  BoxDecoration background() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment(0, 0),
        end: Alignment.bottomCenter,
        colors: [color1, color2],
      ),
    );
  }

  Widget textStyle({required String hometext}) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Text(
        hometext,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}

class _StylesPageState extends State<StylesPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
