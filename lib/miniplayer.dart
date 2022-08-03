// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:marquee_text/marquee_text.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/all_songs/all_songs.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/get_all_songs.dart';
import 'package:podds/player_screen.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({Key? key}) : super(key: key);
  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      duration: const Duration(seconds: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            height: 1,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackShape: SpotifyMiniPlayerTrackShape(),
                trackHeight: 1,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 2,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Slider(
                  value: 30,
                  max: 100,
                  onChanged: null,
                ),
              ),
            ),
          ),
          ListTile(
            onTap: () => Get.to(
                PlayerScreen(
                    songModal: AllSongs.songs,
                    index: GetAllSongs.getCurrentIndex,
                    id: GetAllSongs
                        .playingSongs[GetAllSongs.audioPlayer.currentIndex!]
                        .id),
                duration: const Duration(seconds: 2),
                transition: Transition.downToUp),
            leading: QueryArtworkWidget(
                artworkBorder: BorderRadius.circular(5),
                nullArtworkWidget: const Icon(
                  Icons.music_note,
                  color: color2,
                ),
                id: GetAllSongs
                    .playingSongs[GetAllSongs.audioPlayer.currentIndex!].id,
                type: ArtworkType.AUDIO),
            title: MarqueeText(
              style: const TextStyle(color: color2),
              speed: 15,
              text: TextSpan(
                  text: GetAllSongs
                      .playingSongs[GetAllSongs.audioPlayer.currentIndex!]
                      .displayNameWOExt),
            ),
            trailing: IconButton(
              icon: StreamBuilder<bool>(
                stream: GetAllSongs.audioPlayer.playingStream,
                builder: ((context, snapshot) {
                  bool? _currentPlayingStage = snapshot.data;
                  if (_currentPlayingStage != null && _currentPlayingStage) {
                    return const Icon(Icons.pause_circle_outline, size: 35);
                  } else {
                    return const Icon(Icons.play_arrow, size: 35);
                  }
                }),
              ),
              onPressed: () async {
                if (GetAllSongs.audioPlayer.playing) {
                  await GetAllSongs.audioPlayer.pause();
                  setState(() {});
                } else {
                  await GetAllSongs.audioPlayer.play();
                  setState(() {});
                }
              },
            ),
          )
          // GestureDetector(
          //   onTap: () => Get.to(
          //     PlayerScreen(
          //         songModal: AllSongs.songs,
          //         index: GetAllSongs.getCurrentIndex,
          //         id: GetAllSongs
          //             .playingSongs[GetAllSongs.audioPlayer.currentIndex!].id),
          //   ),
          //   child: Row(
          //     children: [
          //       Flexible(
          //         flex: 8,
          //         child: GestureDetector(
          //           child: Row(
          //             children: [
          //               Flexible(
          //                 child: QueryArtworkWidget(
          //                     artworkBorder: BorderRadius.circular(5),
          //                     nullArtworkWidget: const Icon(
          //                       Icons.music_note,
          //                       color: color2,
          //                     ),
          //                     id: GetAllSongs
          //                         .playingSongs[
          //                             GetAllSongs.audioPlayer.currentIndex!]
          //                         .id,
          //                     type: ArtworkType.AUDIO),
          //               ),
          //               Flexible(
          //                 flex: 3,
          //                 child: Center(
          //                   child: MarqueeText(
          //                     style: const TextStyle(color: color2),
          //                     speed: 15,
          //                     text: TextSpan(
          //                         text: GetAllSongs
          //                             .playingSongs[
          //                                 GetAllSongs.audioPlayer.currentIndex!]
          //                             .displayNameWOExt),
          //                   ),
          //                 ),
          //               )
          //             ],
          //           ),
          //         ),
          //       ),
          //       Flexible(
          //         flex: 2,
          //         child: Padding(
          //           padding: const EdgeInsets.only(right: 15.0),
          //           child: Center(
          //             child: IconButton(
          //               icon: StreamBuilder<bool>(
          //                 stream: GetAllSongs.audioPlayer.playingStream,
          //                 builder: ((context, snapshot) {
          //                   bool? _currentPlayingStage = snapshot.data;
          //                   if (_currentPlayingStage != null &&
          //                       _currentPlayingStage) {
          //                     return const Icon(Icons.pause_circle_outline,
          //                         size: 35);
          //                   } else {
          //                     return const Icon(Icons.play_arrow, size: 35);
          //                   }
          //                 }),
          //               ),
          //               onPressed: () async {
          //                 if (GetAllSongs.audioPlayer.playing) {
          //                   await GetAllSongs.audioPlayer.pause();
          //                   setState(() {});
          //                 } else {
          //                   await GetAllSongs.audioPlayer.play();
          //                   setState(() {});
          //                 }
          //               },
          //             ),
          //           ),
          //         ),
          //       )
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

class SpotifyMiniPlayerTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    @required RenderBox? parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData? sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme?.trackHeight as double;

    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox!.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
