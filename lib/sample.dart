
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:on_audio_query/on_audio_query.dart';
// import 'package:podds/db_functions/favorite_db.dart';


// class NowPlayScreen extends StatefulWidget {
//   final List<SongModel> playerSong;
//   const NowPlayScreen({Key? key, required this.playerSong}) : super(key: key);

//   @override
//   State<NowPlayScreen> createState() => _NowPlayScreenState();
// }

// class _NowPlayScreenState extends State<NowPlayScreen> {
//   int currentIndex = 0;
//   @override
//   void initState() {
//     GetSongs.player.currentIndexStream.listen((index) {
//       if (index != null && mounted) {
//         setState(() {
//           currentIndex = index;
//         });
//         GetSongs.currentIndes = index;
//       }
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBody: true,
//       backgroundColor: transparent,
//       // appBar: AppBar(
//       //   backgroundColor: transparent,
//       //   elevation: 0,
//       // ),
//       body: Stack(
//         children: [
//           SizedBox(
//             width: double.infinity,
//             height: double.infinity,
//             child: QueryArtworkWidget(
//               keepOldArtwork: true,
//               id: widget.playerSong[currentIndex].id,
//               quality: 100,
//               type: ArtworkType.AUDIO,
//               artworkFit: BoxFit.fill,
//               artworkBorder: BorderRadius.circular(0),
//               nullArtworkWidget: const Icon(
//                 Icons.music_note,
//                 size: 100,
//                 color: Colors.white,
//               ),
//             ),
//           ),

//           Container(
//             height: double.infinity,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.5),
//                   spreadRadius: 30,
//                   blurRadius: 10,
//                   offset: const Offset(8, 15), // changes position of shadow
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             children: [
//               BlurryContainer(
//                 borderRadius: BorderRadius.circular(0),
//                 color: Colors.white.withOpacity(0.10),
//                 blur: 8,
//                 elevation: 10,
//                 height: MediaQuery.of(context).size.height * 0.3,
//                 child: Padding(
//                   padding: EdgeInsets.only(
//                       right: MediaQuery.of(context).size.width * 10,
//                       bottom: MediaQuery.of(context).size.height / 6),
//                   child: const SizedBox(
//                     width: double.infinity,
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 width: double.infinity,
//                 height: MediaQuery.of(context).size.height / 2.6,
//                 child: QueryArtworkWidget(
//                   keepOldArtwork: true,
//                   id: widget.playerSong[currentIndex].id,
//                   quality: 100,
//                   type: ArtworkType.AUDIO,
//                   artworkFit: BoxFit.fill,
//                   artworkBorder: BorderRadius.circular(0),
//                   nullArtworkWidget: const Icon(
//                     Icons.music_note,
//                     size: 100,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               BlurryContainer(
//                 borderRadius: BorderRadius.circular(0),
//                 color: Colors.white.withOpacity(0.10),
//                 blur: 8,
//                 elevation: 5,
//                 height: MediaQuery.of(context).size.height * 0.31,
//                 child: const SizedBox(
//                   width: double.infinity,
//                 ),
//               ),
//             ],
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 30),
//             child: IconButton(
//               onPressed: () {
//                 setState(() {});
//                 Navigator.pop(context);
//                 FavoriteDB.favoriteSongs.notifyListeners();
//               },
//               icon: const Icon(
//                 Icons.arrow_back,
//                 color: Colors.white,
//               ),
//             ),
//           ),

//           Padding(
//             padding: EdgeInsets.only(
//                 top: MediaQuery.of(context).size.height / 1.5,
//                 right: 10,
//                 left: 10),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 AnimatedText(
//                   text: widget.playerSong[currentIndex].displayNameWOExt,
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 30,
//                       color: Colors.white),
//                 ),
//                 Text(
//                   widget.playerSong[currentIndex].artist.toString() ==
//                           "<unknown>"
//                       ? "Unknown Artist"
//                       : widget.playerSong[currentIndex].artist.toString(),
//                   style: const TextStyle(
//                       overflow: TextOverflow.ellipsis,
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold),
//                 ),
//                 Row(
//                   children: [
//                     IconButton(
//                       onPressed: () {
//                         showSliderDialog(
//                             context: context,
//                             title: 'Adjust Volume',
//                             divisions: 10,
//                             min: 0.0,
//                             max: 1.0,
//                             value: GetSongs.player.volume,
//                             stream: GetSongs.player.volumeStream,
//                             onChanged: GetSongs.player.setVolume);
//                       },
//                       icon: GetSongs.player.volume == 0.0
//                           ? const Icon(
//                               Icons.volume_off,
//                               color: white,
//                             )
//                           : const Icon(
//                               Icons.volume_up,
//                               color: white,
//                             ),
//                     ),
//                     StreamBuilder(
//                         stream: GetSongs.player.speedStream,
//                         builder: (context, snapshot) {
//                           return IconButton(
//                             onPressed: () {
//                               showSliderDialog(
//                                   context: context,
//                                   title: 'Adjust Speed',
//                                   divisions: 10,
//                                   min: 0.5,
//                                   max: 1.5,
//                                   value: GetSongs.player.speed,
//                                   stream: GetSongs.player.speedStream,
//                                   onChanged: GetSongs.player.setSpeed);
//                             },
//                             icon: snapshot.data == 1.0
//                                 ? Text(
//                                     '${snapshot.data ?? 1.0}x',
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         color: white),
//                                   )
//                                 : Text(
//                                     '${snapshot.data ?? 1.0}x',
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.amber),
//                                   ),
//                           );
//                         }),
//                     const Spacer(),
//                     FavoriteBut(song: widget.playerSong[currentIndex])
//                   ],
//                 ),
//                 StreamBuilder<DurationState>(
//                     stream: _durationStateStream,
//                     builder: (context, snapshot) {
//                       final durationState = snapshot.data;
//                       final progress = durationState?.position ?? Duration.zero;
//                       final total = durationState?.total ?? Duration.zero;
//                       return ProgressBar(
//                           timeLabelTextStyle: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 15),
//                           progress: progress,
//                           total: total,
//                           barHeight: 3.0,
//                           thumbRadius: 5,
//                           progressBarColor: Colors.amberAccent,
//                           thumbColor: Colors.white,
//                           baseBarColor: Colors.grey,
//                           bufferedBarColor: Colors.grey,
//                           buffered: const Duration(milliseconds: 2000),
//                           onSeek: (duration) {
//                             GetSongs.player.seek(duration);
//                           });
//                     }),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     StreamBuilder<bool>(
//                       stream: GetSongs.player.shuffleModeEnabledStream,
//                       builder: (context, snapshot) {
//                         final shuffleModeEnabled = snapshot.data ?? false;
//                         return IconButton(
//                           icon: shuffleModeEnabled
//                               ? const Icon(Icons.shuffle,
//                                   size: 35, color: Colors.amberAccent)
//                               : const Icon(
//                                   Icons.shuffle,
//                                   color: white,
//                                   size: 35,
//                                 ),
//                           onPressed: () {
//                             GetSongs.player
//                                 .setShuffleModeEnabled(!shuffleModeEnabled);
//                           },
//                         );
//                       },
//                     ),
//                     IconButton(
//                         onPressed: () async {
//                           if (GetSongs.player.hasPrevious) {
//                             await GetSongs.player.seekToPrevious();
//                             await GetSongs.player.play();
//                           } else {
//                             await GetSongs.player.play();
//                           }
//                         },
//                         icon: const Icon(
//                           Icons.skip_previous,
//                           color: Colors.white,
//                           size: 40,
//                         )),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                           shape: const CircleBorder(),
//                           primary: transparent,
//                           onPrimary: white),
//                       onPressed: () async {
//                         if (GetSongs.player.playing) {
//                           await GetSongs.player.pause();
//                           setState(() {});
//                         } else {
//                           await GetSongs.player.play();
//                           setState(() {});
//                         }
//                       },
//                       child: StreamBuilder<bool>(
//                         stream: GetSongs.player.playingStream,
//                         builder: (context, snapshot) {
//                           bool? playingStage = snapshot.data;
//                           if (playingStage != null && playingStage) {
//                             return const Icon(
//                               Icons.pause_circle_outline,
//                               size: 70,
//                             );
//                           } else {
//                             return const Icon(
//                               Icons.play_circle_outline,
//                               size: 70,
//                             );
//                           }
//                         },
//                       ),
//                     ),
//                     IconButton(
//                         highlightColor: Colors.amberAccent,
//                         onPressed: (() async {
//                           if (GetSongs.player.hasNext) {
//                             await GetSongs.player.seekToNext();
//                             await GetSongs.player.play();
//                           } else {
//                             await GetSongs.player.play();
//                           }
//                         }),
//                         icon: const Icon(
//                           Icons.skip_next,
//                           color: Colors.white,
//                           size: 40,
//                         )),
//                     StreamBuilder<LoopMode>(
//                       stream: GetSongs.player.loopModeStream,
//                       builder: (context, snapshot) {
//                         final loopMode = snapshot.data ?? LoopMode.off;
//                         const icons = [
//                           Icon(Icons.repeat, color: white, size: 40),
//                           Icon(Icons.repeat, color: Colors.amber, size: 40),
//                           Icon(Icons.repeat_one, color: Colors.amber, size: 40),
//                         ];
//                         const cycleModes = [
//                           LoopMode.off,
//                           LoopMode.all,
//                           LoopMode.one,
//                         ];
//                         final index = cycleModes.indexOf(loopMode);
//                         return IconButton(
//                           icon: icons[index],
//                           onPressed: () {
//                             GetSongs.player.setLoopMode(cycleModes[
//                                 (cycleModes.indexOf(loopMode) + 1) %
//                                     cycleModes.length]);
//                           },
//                         );
//                       },
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//           // Padding(
//           //   padding:
//           //       EdgeInsets.only(top: MediaQuery.of(context).padding.top * 20),
//           //   child: Column(
//           //       mainAxisAlignment: MainAxisAlignment.start,
//           //       crossAxisAlignment: CrossAxisAlignment.start,
//           //       children: [
//           //         Container(
//           //           alignment: Alignment.centerLeft,
//           //           child: AnimatedText(
//           //             text: widget.playerSong[currentIndex].displayNameWOExt,
//           //             style: const TextStyle(
//           //                 fontWeight: FontWeight.bold,
//           //                 fontSize: 30,
//           //                 color: Colors.white),
//           //           ),
//           //         ),
//           //         const SizedBox(
//           //           height: 10,
//           //         ),
//           //         Row(
//           //           children: [
//           //             Expanded(
//           //               flex: 3,
//           //               child: Container(
//           //                 alignment: Alignment.centerLeft,
//           //                 child: AnimatedText(
//           //                     text: widget.playerSong[currentIndex].artist
//           //                                 .toString() ==
//           //                             "<unknown>"
//           //                         ? "Unknown Artist"
//           //                         : widget.playerSong[currentIndex].artist
//           //                             .toString(),
//           //                     pauseAfterRound: const Duration(seconds: 3),
//           //                     showFadingOnlyWhenScrolling: false,
//           //                     fadingEdgeEndFraction: 0.1,
//           //                     fadingEdgeStartFraction: 0.1,
//           //                     style: const TextStyle(
//           //                       fontSize: 16.0,
//           //                       fontWeight: FontWeight.bold,
//           //                       color: white,
//           //                     )),
//           //               ),
//           //             )
//           //           ],
//           //         )
//           //       ]),
//           // ),
//         ],
//       ),
//     );
//   }

//   void showSliderDialog({
//     required BuildContext context,
//     required String title,
//     required int divisions,
//     required double min,
//     required double max,
//     String valueSuffix = '',
//     // TODO: Replace these two by ValueStream.
//     required double value,
//     required Stream<double> stream,
//     required ValueChanged<double> onChanged,
//   }) {
//     showDialog<void>(
//       context: context,
//       builder: (context) => AlertDialog(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         title: Text(
//           title,
//           textAlign: TextAlign.center,
//           style: const TextStyle(color: Colors.white),
//         ),
//         content: StreamBuilder<double>(
//           stream: stream,
//           builder: (context, snapshot) => SizedBox(
//             height: 100.0,
//             child: Column(
//               children: [
//                 Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontFamily: 'Fixed',
//                         fontWeight: FontWeight.bold,
//                         fontSize: 24.0)),
//                 Slider(
//                   activeColor: Colors.amberAccent,
//                   inactiveColor: Colors.grey,
//                   divisions: divisions,
//                   min: min,
//                   max: max,
//                   value: snapshot.data ?? value,
//                   onChanged: onChanged,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Stream<DurationState> get _durationStateStream =>
//       Rx.combineLatest2<Duration, Duration?, DurationState>(
//           GetSongs.player.positionStream,
//           GetSongs.player.durationStream,
//           (position, duration) => DurationState(
//               position: position, total: duration ?? Duration.zero));
// }

// class DurationState {
//   DurationState({this.position = Duration.zero, this.total = Duration.zero});
//   Duration position, total;
// }