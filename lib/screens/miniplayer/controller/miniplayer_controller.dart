import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

import '../../../functions/get_all_songs/get_all_songs.dart';

class MiniPlayerController extends GetxController {
  @override
  void onInit() {
    GetAllSongs.audioPlayer.currentIndexStream.listen((index) {
      if (index != null) {
        update();
      }
    });
    super.onInit();
    update();
  }

  pause() {
    GetAllSongs.audioPlayer.pause();
    update();
  }

  play() {
    GetAllSongs.audioPlayer.play();
    update();
  }

  playChecking() {
    if (GetAllSongs.audioPlayer.playing) {
      return IconButton(
        icon: const Icon(Icons.pause_circle_outline, size: 35),
        onPressed: () async {
          await GetAllSongs.audioPlayer.pause();
        },
      );
    } else {
      IconButton(
        onPressed: () async {
          await GetAllSongs.audioPlayer.play();
        },
        icon: const Icon(Icons.play_circle_outline, size: 35),
      );
    }
    update();
  }
}
