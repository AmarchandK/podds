// ignore_for_file: must_be_immutable

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/favorites/fav_button.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/home_screen/home.dart';

class PlayerScreen extends StatefulWidget {
  PlayerScreen(
      {Key? key,
      required this.songName,
      required this.audioPlayer,
      required this.index,
      this.id})
      : super(key: key);
  final List<dynamic> songName;
  final AudioPlayer audioPlayer;
  int index;
  dynamic id;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _isPlaying = false;
  Duration _position = const Duration();
  Duration _duration = const Duration();

  @override
  void initState() {
    playSong();
    super.initState();
  }

  void playSong() {
    try {
      widget.audioPlayer.setAudioSource(AudioSource.uri(
        Uri.parse(widget.songName[widget.index].uri!),
        tag: MediaItem(
          // Specify a unique ID for each media item:
          id: '${widget.songName[widget.index].id}',
          // Metadata to display in the notification:
          album: "${widget.songName[widget.index].album}",
          title: widget.songName[widget.index].displayNameWOExt,
          artUri: Uri.parse('https://example.com/albumart.jpg'),
        ),
      ));
      widget.audioPlayer.play();
      _isPlaying = true;
    } on Exception {
      log("Cannot Parse Song");
    }
    widget.audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d!;
      });
    });
    widget.audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier(HomeScreen);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: color1,
          title: const Text('Now Playing'),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.playlist_add),
            ),
          ],
        ),
        body: DecoratedBox(
          decoration: stylesClass.background(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                    border: Border.all(width: 5, color: color2),
                    color: color1,
                    borderRadius: const BorderRadius.all(Radius.circular(100))),
                child: GestureDetector(
                  child: QueryArtworkWidget(
                    artworkFit: BoxFit.fill,
                    artworkBorder: BorderRadius.circular(100),
                    id: widget.songName[widget.index].id,
                    type: ArtworkType.AUDIO,
                    keepOldArtwork: true,
                    nullArtworkWidget: const Icon(Icons.music_note),
                  ),
                ),
              ),
              stylesClass.textStyle(
                hometext: widget.songName[widget.index].displayNameWOExt,
              ),
              Text(
                  widget.songName[widget.index].artist.toString() == '<unknown>'
                      ? 'Unknown Artist'
                      : widget.songName[widget.index].artist.toString()),
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
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.shuffle_rounded)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.repeat)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      if (widget.index > 0) {
                        widget.index--;
                      } else {
                        widget.index = widget.songName.length - 1;
                      }
                      playSong();
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
                            widget.audioPlayer.pause();
                          } else {
                            widget.audioPlayer.play();
                          }
                          _isPlaying = !_isPlaying;
                        });
                      },
                      elevation: 15,
                      fillColor: color1,
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow_outlined,
                        size: 35.0,
                      )),
                  IconButton(
                    onPressed: () {
                      if (widget.index < widget.songName.length - 1) {
                        widget.index++;
                      } else {
                        widget.index = 0;
                      }
                      playSong();
                    },
                    icon: const Icon(Icons.skip_next_outlined),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }

  void changeToSeconds(int seconds) {
    Duration duration = Duration(seconds: seconds);
    widget.audioPlayer.seek(duration);
  }
}
