// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee_text/marquee_text.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/favorites/fav_button.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/get_all_songs.dart';
import 'package:podds/home_screen/home.dart';

class PlayerScreen extends StatefulWidget {
  PlayerScreen(
      {Key? key,
      required this.songModal,
      required this.index,
      required this.id})
      : super(key: key);
  final List<dynamic> songModal;

  int index;
  dynamic id;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  int currentIndex1 = 0;

  bool _isPlaying = false;
  Duration _position = const Duration();
  Duration _duration = const Duration();

  @override
  void initState() {
    GetAllSongs.audioPlayer.currentIndexStream.listen((index) {
      if (index != null && mounted) {
        setState(() {
          currentIndex1 = index;
        });
        GetAllSongs.getCurrentIndex = index;
      }
    });
    playSong();
    super.initState();
  }

  void playSong() {
    try {
      GetAllSongs.audioPlayer.setAudioSource(
          GetAllSongs.createSongList(widget.songModal as List<SongModel>),
          initialIndex: widget.index);
      GetAllSongs.audioPlayer.play();
      _isPlaying = true;
    } on Exception {
      log("Cannot Parse Song");
    }
    GetAllSongs.audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d!;
      });
    });
    GetAllSongs.audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    ValueNotifier(HomeScreen);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: color1,
        title: const Text('Now Playing'),
        actions: [
          IconButton(
            onPressed: () {
              showSliderDialog(value: GetAllSongs.audioPlayer.volume);

              setState(() {});
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
              child: QueryArtworkWidget(
                artworkFit: BoxFit.fill,
                artworkBorder: BorderRadius.circular(height / 6),
                id: widget.songModal[currentIndex1].id,
                type: ArtworkType.AUDIO,
                keepOldArtwork: true,
                nullArtworkWidget: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Center(
                    child: Image.asset(
                      'assets/1-removebg-preview.png',
                    ),
                  ),
                ),
              ),
            ),
            MarqueeText(
              speed: 10,
              text: TextSpan(
                // text: widget.songName[widget.index].displayNameWOExt,
                text: widget.songModal[currentIndex1].title.toString(),
                style: TextStyle(
                  fontSize: height / 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
                widget.songModal[currentIndex1].artist.toString() == '<unknown>'
                    ? 'Unknown Artist'
                    : widget.songModal[currentIndex1].artist.toString()),
            Align(child: FavBTN(id: widget.id)),
            SliderTheme(
              data: const SliderThemeData(
                  activeTrackColor: color2,
                  thumbColor: color2,
                  inactiveTrackColor: Colors.grey),
              child: Slider.adaptive(
                value: _position.inSeconds.toDouble(),
                onChanged: (value) {
                  setState(() {
                    changeToSeconds(value.toInt());
                    value = value;
                  });
                },
                min: const Duration(microseconds: 0).inSeconds.toDouble(),
                max: _duration.inSeconds.toDouble(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_position.toString().split('.')[0]),
                  Text(_duration.toString().split('.')[0])
                ],
              ),
            ),
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
                StreamBuilder<LoopMode>(
                    stream: GetAllSongs.audioPlayer.loopModeStream,
                    builder: (context, snapshot) {
                      final loopMode = snapshot.data ?? LoopMode.off;
                      const repeatIcons = [
                        Icon(
                          Icons.repeat,
                          color: color1,
                        ),
                        Icon(Icons.repeat),
                      ];
                      const cycleModes = [
                        LoopMode.off,
                        LoopMode.all,
                      ];
                      final index = cycleModes.indexOf(loopMode);
                      return IconButton(
                        onPressed: () {
                          GetAllSongs.audioPlayer.setLoopMode(cycleModes[
                              (cycleModes.indexOf(loopMode) + 1) %
                                  cycleModes.length]);
                        },
                        icon: repeatIcons[index],
                      );
                    }),
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
                    hoverColor: color2,
                    padding: const EdgeInsets.all(15.0),
                    shape: const CircleBorder(),
                    onPressed: () {
                      setState(() {
                        if (_isPlaying) {
                          GetAllSongs.audioPlayer.pause();
                        } else {
                          GetAllSongs.audioPlayer.play();
                        }
                        _isPlaying = !_isPlaying;
                      });
                    },
                    elevation: 20,
                    fillColor: color1,
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow_outlined,
                      size: 35.0,
                    )),
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

  void changeToSeconds(int seconds) {
    Duration duration = Duration(seconds: seconds);
    GetAllSongs.audioPlayer.seek(duration);
  }

/////// VOLUME ////////////
  showSliderDialog({
    String valueSuffix = '',
    required double value,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Adjust Your Volume',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        content: StreamBuilder<double>(
          stream: GetAllSongs.audioPlayer.volumeStream,
          builder: (context, snapshot) => SizedBox(
            height: 100.0,
            child: Column(
              children: [
                Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Fixed',
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0)),
                Slider(
                  activeColor: color2,
                  inactiveColor: Colors.grey,
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
      ),
    );
  }
}
