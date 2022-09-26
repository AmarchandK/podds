import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee_text/marquee_text.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/global_constants/styles.dart';
import 'package:podds/screens/miniplayer/controller/miniplayer_controller.dart';
import '../../../global_constants/get_all_songs.dart';
import '../../now_playing/view/player_screen.dart';

class MiniPlayer extends StatelessWidget {
  MiniPlayer({Key? key}) : super(key: key);
  final MiniPlayerController _controllerMini = Get.put(MiniPlayerController());
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      duration: const Duration(seconds: 2),
      child: ListTile(
          onTap: () => Get.to(
              () => PlayerScreen(
                    songModal: GetAllSongs.playingSongs,
                  ),
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
          trailing: GetBuilder<MiniPlayerController>(
            builder: (controller) => IconButton(
              icon: StreamBuilder<bool>(
                stream: GetAllSongs.audioPlayer.playingStream,
                builder: ((context, snapshot) {
                  bool? currentPlayingStage = snapshot.data;
                  if (currentPlayingStage != null && currentPlayingStage) {
                    return const Icon(Icons.pause_circle_outline, size: 35);
                  } else {
                    return const Icon(Icons.play_circle_outline_outlined,
                        size: 35);
                  }
                }),
              ),
              onPressed: () {
                if (GetAllSongs.audioPlayer.playing) {
                  _controllerMini.pause();
                } else {
                  _controllerMini.play();
                }
              },
            ),
          )),
    );
  }
}
