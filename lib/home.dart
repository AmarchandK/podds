import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:podds/db_functions/favorite_db.dart';
import 'package:podds/db_functions/playlist_db_functions.dart';
import 'package:podds/db_functions/recent_songs.dart';
import 'package:podds/functions/homescreen_functns.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/sample.dart';
import 'package:podds/search.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    RecentSongs.getRecentSongs();
    getAllPlaylist();
    FavoriteDB.displaySongs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 30,
        backgroundColor: color1,
        leading: const Icon(
          BootstrapIcons.earbuds,
          color: color2,
          size: 30,
        ),
        title: const Text('Hey'),
        elevation: 0,
        actions: [
          IconButton(
              // onPressed: () => Get.to(
              //     showSearch(context: context, delegate: MySearchDeligate()),
              //     transition: Transition.cupertino,
              //     duration: const Duration(milliseconds: 500)),
              onPressed: () => Get.to(SearchScreen()),
              icon: const Icon(Icons.search))
        ],
      ),
      body: Container(
          decoration: stylesClass.background(),
          child: ListView(
            children: [
              stylesClass.textStyle(hometext: 'Recents'),
              recentHome(),
              stylesClass.textStyle(hometext: 'Playlists'),
              playListHome(),
              stylesClass.textStyle(hometext: 'Favorites'),
              favSongHome(),
              stylesClass.textStyle(hometext: 'All songs'),
              allSongHome()
            ],
          )),
    );
  }
}
