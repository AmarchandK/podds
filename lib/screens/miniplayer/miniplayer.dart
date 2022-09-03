// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:marquee_text/marquee_text.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/functions/constants/styles.dart';

import '../../functions/get_all_songs/get_all_songs.dart';
import '../now_playing/player_screen.dart';


class MiniPlayer extends StatefulWidget {
  const MiniPlayer({Key? key}) : super(key: key);
  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  @override
  void initState() {
    GetAllSongs.audioPlayer.currentIndexStream.listen((index) {
      if (index != null && mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      duration: const Duration(seconds: 2),
      child: ListTile(
        onTap: () => Get.to(
            PlayerScreen(
                songModal: GetAllSongs.playingSongs,
            
                id: GetAllSongs
                    .playingSongs[GetAllSongs.audioPlayer.currentIndex!].id),
            duration: const Duration(seconds: 1),
            transition: Transition.downToUp),
        leading: QueryArtworkWidget(
            keepOldArtwork: true,
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
      ),
    );
  }
}
