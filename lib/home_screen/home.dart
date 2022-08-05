import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:podds/all_songs/all_songs.dart';
import 'package:podds/db_functions/favorite_db.dart';
import 'package:podds/db_functions/playlist_db_functions.dart';
import 'package:podds/db_functions/recent_songs.dart';
import 'package:podds/home_screen/homescreen_functns.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/search.dart';
import 'package:podds/splash.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    homeInint();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 30,
        backgroundColor: color1,
        leading: const Padding(
          padding: EdgeInsets.all(3.0),
          child: Image(
            image: AssetImage('assets/1-removebg-preview.png'),
          ),
        ),
        title: Text('${greeting()} $name'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.to(
              () => const SearchScreen(),
            ),
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: Container(
          decoration: stylesClass.background(),
          child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: ListView(
              children: [
                stylesClass.textStyle(hometext: 'Recents'),
                const HomeRecentsSongs(),
                stylesClass.textStyle(hometext: 'All songs'),
                HomeAllSongs(),
                stylesClass.textStyle(hometext: 'Favorites'),
                const HomeFavorites(),
                stylesClass.textStyle(hometext: 'Playlists'),
                const HomePlaylist(),
              ],
            ),
          )),
    );
  }

  Future homeInint() async {
    await Permission.storage.request();
    await getAllPlaylist();
    await RecentSongs.displayRecents();
    await FavoriteDB.getAllSongs();
    AllSongs();
  }
}
