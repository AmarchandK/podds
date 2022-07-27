// import 'package:flutter/material.dart';
// import 'package:on_audio_query/on_audio_query.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:podds/db_functions/playlist_db_functions.dart';

// class SinglePlaylist extends StatefulWidget {
//   const SinglePlaylist({Key? key, required this.folderIndex, int? id})
//       : super(key: key);

//   final int folderIndex;

//   @override
//   State<SinglePlaylist> createState() => _SinglePlaylistState();
// }

// class _SinglePlaylistState extends State<SinglePlaylist> {
//   AudioPlayer audioPlayer = AudioPlayer();
//   int tempIndex = 0;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     getAllPlaylist();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Playlistsongcheck.showSelectSong(widget.folderIndex);
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(0, 209, 30, 30),
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.transparent,
//         title: Row(
//           children: [
//             const Text(
//               'Sarigama',
//               style: TextStyle(
//                   color: Color.fromARGB(209, 78, 11, 11), fontSize: 35.0),
//             ),
//             Padding(
//               padding: EdgeInsets.only(top: 13.0),
//               child: Text(
//                 playListNotifier.value[widget.folderIndex].name
//                     .toString()
//                     .toUpperCase(),
//                 style: TextStyle(
//                     color: Color.fromARGB(255, 250, 250, 250), fontSize: 15.0),
//               ),
//             )
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(
//               Icons.playlist_add,
//               size: 35,
//             ),
//             tooltip: 'Add Song',
//             onPressed: () {
//               print(widget.folderIndex);
//               Navigator.of(context).push(MaterialPageRoute(
//                   builder: (context) => Addsongs(
//                         folderIndex: widget.folderIndex,
//                       )));
//             },
//           ),
//         ],
//       ),
//       body: ValueListenableBuilder(
//           valueListenable: playListNotifier,
//           builder:
//               (BuildContext ctx, List<dynamic> selectedsongs, Widget? child) {
//             return GridView.builder(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   childAspectRatio: 1,
//                   mainAxisSpacing: 40,
//                   crossAxisSpacing: 10,
//                 ),
//                 padding: const EdgeInsets.all(10),
//                 itemCount: playListNotifier
//                     .value[widget.folderIndex].songListdb.length,
//                 itemBuilder: (context, index) {
//                   return GridTile(
//                     child: GestureDetector(
//                       onTap: () {
//                         List<SongModel> newlist = [];
//                         newlist.addAll(playloop);
//                         allsong = newlist;
//                         if (!MyHomeScreen.audioPlayer.playing ||
//                             tempIndex != index) {
//                           MyHomeScreen.audioPlayer.setAudioSource(
//                               createSongList(playloop),
//                               initialIndex: index);
//                           tempIndex = index;
//                           MyHomeScreen.audioPlayer.play();
//                           Navigator.of(context).push(MaterialPageRoute(
//                             builder: (context) => MyMusic(),
//                           ));
//                         } else {
//                           MyHomeScreen.audioPlayer.pause();
//                         }
//                       },
//                       child: QueryArtworkWidget(
//                         id: MyHomeScreen
//                             .playlist[
//                                 Playlistsongcheck.selectPlaySong.value[index]]
//                             .id,
//                         type: ArtworkType.AUDIO,
//                         artworkWidth: double.infinity,
//                         artworkHeight: double.infinity,
//                         nullArtworkWidget: Image.asset(
//                             'assets/images/image-removebg-preview.png'),
//                         artworkBorder: BorderRadius.circular(30),
//                       ),
//                     ),
//                     footer: Container(
//                       height: 40.0,
//                       decoration: const BoxDecoration(
//                         borderRadius: BorderRadius.only(
//                             bottomLeft: Radius.circular(30.0),
//                             bottomRight: Radius.circular(30.0)),
//                         color: Color.fromARGB(65, 10, 5, 5),
//                       ),
//                       child: Padding(
//                           padding: EdgeInsets.all(8.0),
//                           child: Text(
//                             MyHomeScreen
//                                 .playlist[Playlistsongcheck
//                                     .selectPlaySong.value[index]]
//                                 .title,
//                             style: TextStyle(color: Colors.white),
//                             overflow: TextOverflow.ellipsis,
//                           )),
//                     ),
//                   );
//                 });
//           }),
//     );
//   }
// }
