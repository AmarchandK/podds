// ignore_for_file: must_be_immutable, depend_on_referenced_packages, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:get/get.dart';
import 'package:podds/screens/libary/controller/fav_db_controller.dart';
import 'package:podds/screens/now_playing/controller/nowplaying_controller.dart';
import 'package:rxdart/rxdart.dart' as rxmport;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee_text/marquee_text.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/global_constants/styles.dart';
import 'package:podds/screens/home_screen/view/home.dart';
import '../../libary/view/widgets/fav_button.dart';
import '../../../global_constants/get_all_songs.dart';

class PlayerScreen extends StatelessWidget {
  PlayerScreen({
    Key? key,
    required this.songModal,
  }) : super(key: key);
  final List<dynamic> songModal;
  final NowPlayingController _controller = Get.put(NowPlayingController());
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    ValueNotifier(HomeScreen);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Get.back();
              // _controller.update();
            },
            icon: const Icon(Icons.keyboard_arrow_down_outlined)),
        backgroundColor: color1,
        title: const Text('Now Playing'),
        actions: [
          IconButton(
            onPressed: () {
              showSliderDialog(value: GetAllSongs.audioPlayer.volume);
            },
            icon: GetAllSongs.audioPlayer.volume == 0
                ? const Icon(Icons.volume_off)
                : const Icon(Icons.volume_up),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        decoration: stylesClass.background(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
                height: height / 3,
                width: height / 3,
                decoration: BoxDecoration(
                  border: Border.all(width: 5, color: color2),
                  color: color1,
                  borderRadius: BorderRadius.all(
                    Radius.circular(height / 6),
                  ),
                ),
                child: Obx(
                  () => QueryArtworkWidget(
                    artworkFit: BoxFit.fill,
                    artworkBorder: BorderRadius.circular(height / 6),
                    id: songModal[_controller.currentIndex1.value].id,
                    type: ArtworkType.AUDIO,
                    artworkQuality: FilterQuality.high,
                    keepOldArtwork: true,
                    nullArtworkWidget: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Center(
                        child: Image.asset(
                          'assets/logo.png',
                        ),
                      ),
                    ),
                  ),
                )),
            Obx(
              () => MarqueeText(
                speed: 10,
                text: TextSpan(
                  // text: widget.songName[widget.index].displayNameWOExt,
                  text: songModal[_controller.currentIndex1.value]
                      .title
                      .toString(),
                  style: TextStyle(
                    fontSize: height / 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Obx(
              () => Text(
                songModal[_controller.currentIndex1.value].artist.toString() ==
                        '<unknown>'
                    ? 'Unknown Artist'
                    : songModal[_controller.currentIndex1.value]
                        .artist
                        .toString(),
              ),
            ),
            Align(
              child: GetBuilder<FavDbController>(
                  builder: (controller) => Obx(
                        () => FavButton(
                            id: songModal[_controller.currentIndex1.value].id),
                      )),
            ),
            StreamBuilder<DurationState>(
                stream: _durationStateStream,
                builder: (context, snapshot) {
                  final durationState = snapshot.data;
                  final progress = durationState?.position ?? Duration.zero;
                  final total = durationState?.total ?? Duration.zero;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ProgressBar(
                      progress: progress,
                      total: total,
                      timeLabelType: TimeLabelType.remainingTime,
                      timeLabelLocation: TimeLabelLocation.sides,
                      timeLabelPadding: 20,
                      thumbRadius: 8,
                      thumbColor: color1,
                      progressBarColor: color2,
                      baseBarColor: Colors.white,
                      onSeek: (duration) {
                        GetAllSongs.audioPlayer.seek(duration);
                      },
                    ),
                  );
                }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StreamBuilder<bool>(
                  stream: GetAllSongs.audioPlayer.shuffleModeEnabledStream,
                  builder: (context, snapshot) {
                    final shuffleModeEnabled = snapshot.data ?? false;
                    return IconButton(
                      onPressed: () {
                        GetAllSongs.audioPlayer
                            .setShuffleModeEnabled(!shuffleModeEnabled);
                      },
                      icon: shuffleModeEnabled
                          ? const Icon(Icons.shuffle_rounded)
                          : const Icon(
                              Icons.shuffle_rounded,
                              color: color1,
                            ),
                    );
                  },
                ),
                IconButton(
                  onPressed: () {
                    GetAllSongs.audioPlayer.loopMode == LoopMode.one
                        ? GetAllSongs.audioPlayer.setLoopMode(LoopMode.all)
                        : GetAllSongs.audioPlayer.setLoopMode(LoopMode.one);
                  },
                  icon: StreamBuilder<LoopMode>(
                    stream: GetAllSongs.audioPlayer.loopModeStream,
                    builder: ((context, snapshot) {
                      final loopMode = snapshot.data;
                      if (LoopMode.one == loopMode) {
                        return const Icon(Icons.repeat);
                      } else {
                        return const Icon(
                          Icons.repeat,
                          color: color1,
                        );
                      }
                    }),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () async {
                    if (GetAllSongs.audioPlayer.hasPrevious) {
                      await GetAllSongs.audioPlayer.seekToPrevious();
                      await GetAllSongs.audioPlayer.play();
                    } else {
                      await GetAllSongs.audioPlayer.play();
                    }
                  },
                  icon: const Icon(Icons.skip_previous_outlined),
                ),
                RawMaterialButton(
                  elevation: 20,
                  fillColor: color1,
                  hoverColor: color2,
                  padding: const EdgeInsets.all(15.0),
                  shape: const CircleBorder(),
                  onPressed: () async {
                    if (GetAllSongs.audioPlayer.playing) {
                      await GetAllSongs.audioPlayer.pause();
                    } else {
                      await GetAllSongs.audioPlayer.play();
                    }
                  },
                  child: StreamBuilder<bool>(
                    stream: GetAllSongs.audioPlayer.playingStream,
                    builder: (context, snapshot) {
                      bool? playingStatus = snapshot.data;
                      if (playingStatus != null && playingStatus) {
                        return const Icon(
                          Icons.pause,
                          size: 40,
                        );
                      } else {
                        return const Icon(
                          Icons.play_arrow,
                          size: 40,
                        );
                      }
                    },
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (GetAllSongs.audioPlayer.hasNext) {
                      await GetAllSongs.audioPlayer.seekToNext();
                      await GetAllSongs.audioPlayer.play();
                    } else {
                      await GetAllSongs.audioPlayer.play();
                    }
                  },
                  icon: const Icon(Icons.skip_next_outlined),
                ),
              ],
            ),
            SizedBox(
              height: height / 45,
            )
          ],
        ),
      ),
    );
  }

/////// VOLUME ////////////
  showSliderDialog({
    String valueSuffix = '',
    required double value,
  }) {
    return Get.defaultDialog(
      title: 'Adjust Volume',
      titleStyle: const TextStyle(color: color1),
      backgroundColor: color2,
      content: StreamBuilder<double>(
        stream: GetAllSongs.audioPlayer.volumeStream,
        builder: (context, snapshot) => SizedBox(
          height: 100.0,
          child: Column(
            children: [
              Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                  style: const TextStyle(
                      color: color1,
                      fontFamily: 'Fixed',
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0)),
              Slider(
                activeColor: color1,
                inactiveColor: color2,
                divisions: 10,
                min: 0,
                max: 5,
                value: snapshot.data ?? value,
                onChanged: GetAllSongs.audioPlayer.setVolume,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DurationState {
  DurationState({this.position = Duration.zero, this.total = Duration.zero});
  Duration position, total;
}

Stream<DurationState> get _durationStateStream =>
    rxmport.Rx.combineLatest2<Duration, Duration?, DurationState>(
        GetAllSongs.audioPlayer.positionStream,
        GetAllSongs.audioPlayer.durationStream,
        (position, duration) => DurationState(
            position: position, total: duration ?? Duration.zero));
