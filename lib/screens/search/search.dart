import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podds/screens/all_songs/all_songs.dart';
import 'package:podds/functions/constants/styles.dart';
import 'package:podds/screens/search/controller/search_controller.dart';
import '../../functions/get_all_songs/get_all_songs.dart';
import '../now_playing/player_screen.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({Key? key}) : super(key: key);
  final Searchcontroller _searchcontroller = Get.find();
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
                  _searchcontroller.runFilter(value);
                  // temp = value
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
                    icon: const Icon(Icons.close),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: _searchcontroller.foundSongs.isNotEmpty
                    ? GetBuilder<Searchcontroller>(
                        builder: (controller) => ListView.builder(
                          itemCount: _searchcontroller.foundSongs.length,
                          itemBuilder: (context, index) => Card(
                            key: ValueKey(
                                _searchcontroller.foundSongs[index].id),
                            color: color1,
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              leading: const Icon(Icons.search),
                              title: Text(
                                  _searchcontroller.foundSongs[index].title),
                              onTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                GetAllSongs.audioPlayer.play();
                                GetAllSongs.audioPlayer.setAudioSource(
                                    GetAllSongs.createSongList(
                                        _searchcontroller.foundSongs),
                                    initialIndex: index);
                                Get.to(PlayerScreen(
                                  id: AllSongs.songs[index].id,
                                  songModal: _searchcontroller.foundSongs,
                                ));
                              },
                            ),
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
