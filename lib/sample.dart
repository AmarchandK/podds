// import 'package:flutter/material.dart';

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               AppBar(title: Text('Miniplayer Demo')),
//               Expanded(
//                 child: AudioUi(
//                   onTap: (audioObject) => currentlyPlaying.value = audioObject,
//                 ),
//               ),
//             ],
//           ),
//           ValueListenableBuilder(
//             valueListenable: currentlyPlaying,
//             builder: (BuildContext context, AudioObject? audioObject,
//                     Widget? child) =>
//                 audioObject != null
//                     ? DetailedPlayer(audioObject: audioObject)
//                     : Container(),
//           ),
//         ],
//       ),
//       bottomNavigationBar: ValueListenableBuilder(
//         valueListenable: playerExpandProgress,
//         builder: (BuildContext context, double height, Widget? child) {
//           final value = percentageFromValueInRange(
//               min: playerMinHeight, max: playerMaxHeight, value: height);

//           var opacity = 1 - value;
//           if (opacity < 0) opacity = 0;
//           if (opacity > 1) opacity = 1;

//           return SizedBox(
//             height:
//                 kBottomNavigationBarHeight - kBottomNavigationBarHeight * value,
//             child: Transform.translate(
//               offset: Offset(0.0, kBottomNavigationBarHeight * value * 0.5),
//               child: Opacity(
//                 opacity: opacity,
//                 child: OverflowBox(
//                   maxHeight: kBottomNavigationBarHeight,
//                   child: child,
//                 ),
//               ),
//             ),
//           );
//         },
//         child: BottomNavigationBar(
//           currentIndex: 0,
//           selectedItemColor: Colors.blue,
//           items: const <BottomNavigationBarItem>[
//             BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
//             BottomNavigationBarItem(
//                 icon: Icon(Icons.library_books), label: 'Library'),
//           ],
//         ),
//       ),
//     );
//   }
// }