// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/state_manager.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/all_songs/all_songs.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/get_all_songs.dart';
import 'package:podds/player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<SongModel> _allSongs = AllSongs.songs;
  // This list holds the data for the list view
  List<SongModel> _foundSongs = [];
  String temp = '';
  @override
  initState() {
    // at the beginning, all users are shown
    _foundSongs = _allSongs;
    super.initState();
  }

  // This function i s called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<SongModel> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _allSongs;
    } else {
      results = _allSongs
          .where((name) =>
              name.title.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _foundSongs = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              TextFormField(
                autofocus: true,
                onChanged: (value) {
                  _runFilter(value);
                  // temp = value;
                },
                decoration: InputDecoration(
                    labelText: 'Search',
                    suffixIcon: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // if (temp.isEmpty) {

                          // } else {
                          //   // temp.//???????????????
                          // }
                        },
                        icon: const Icon(Icons.close))),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: _foundSongs.isNotEmpty
                    ? ListView.builder(
                        itemCount: _foundSongs.length,
                        itemBuilder: (context, index) => Card(
                          key: ValueKey(_foundSongs[index].id),
                          color: color1,
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            leading: const Icon(Icons.search),
                            title: Text(_foundSongs[index].title),
                            onTap: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              GetAllSongs.audioPlayer.play();
                              GetAllSongs.audioPlayer.setAudioSource(
                                  GetAllSongs.createSongList(_foundSongs),
                                  initialIndex: index);
                              Get.to(PlayerScreen(
                                  id: AllSongs.songs[index].id,
                                  songModal: _foundSongs,
                                  index: index));
                            },
                          ),
                        ),
                      )
                    : const Text(
                        'No Songs found',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}






           ///////      Deligate     //////
// class SearchScreen extends StatelessWidget {
//   const SearchScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         title: const Text('Search Screen'),
//         backgroundColor: color1,
//         actions: [
//           IconButton(
//             onPressed: () {
//               showSearch(
//                 context: context,
//                 delegate: MySearchDeligate(),
//               );
//             },
//             icon: const Icon(Icons.search),
//           )
//         ],
//       ),
//       body: Container(
//         decoration: stylesClass.background(),
//       ),
//     );
//   }
// }

// class MySearchDeligate extends SearchDelegate {
//   List<String> suggestions = ['Song 1', 'Song 2'];
//   @override
//   List<Widget>? buildActions(BuildContext context) {
//     IconButton(
//         onPressed: () {
//           if (query.isEmpty) {
//             close(context, null);
//           } else {
//             query = '';
//           }
//         },
//         icon: const Icon(Icons.close));
//     return null;
//   }

//   @override
//   Widget? buildLeading(BuildContext context) {
//     IconButton(
//       onPressed: () {
//         close(context, null);
//       },
//       icon: const Icon(Icons.arrow_back),
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     return Center(
//       child: Text(query),
//     );
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     return ListView.builder(
//       itemCount: suggestions.length,
//       itemBuilder: (BuildContext context, int index) {
//         final suggestion = suggestions[index];
//         return ListTile(
//           title: Text(suggestion),
//           onTap: () {
//             query = suggestion;
//             showResults(context);
//           },
//         );
//       },
//     );
//   }
// }
