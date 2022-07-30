import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:podds/db_functions/favorite_db.dart';
import 'package:podds/db_functions/playlist_db_functions.dart';
import 'package:podds/db_functions/recent_songs.dart';
import 'package:podds/home_screen/homescreen_functns.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/search.dart';

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
        // leading: const Image(
        //   image: AssetImage('assets/whitePodds.png'),
        //   width: 50,
        //   fit: BoxFit.fitWidth,
        // ),
        leading: const Icon(
          BootstrapIcons.earbuds,
          color: color2,
          size: 30,
        ),
        title: const Text('Hey'),
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () => Get.to(() => const SearchScreen()),
              icon: const Icon(Icons.search))
        ],
      ),
      body: Container(
          decoration: stylesClass.background(),
          child: ListView(
            children: [
              stylesClass.textStyle(hometext: 'Recents'),
              const HomeRecentsSongs(),
              stylesClass.textStyle(hometext: 'Playlists'),
              const HomePlaylist(),
              stylesClass.textStyle(hometext: 'Favorites'),
              const HomeFavorites(),
              stylesClass.textStyle(hometext: 'All songs'),
              HomeAllSongs()
            ],
          )),
    );
  }

  Future homeInint() async {
    setState(() {
      Permission.storage.request();
      RecentSongs.displayRecents();
    });
    await getAllPlaylist();
    await FavoriteDB.getAllSongs();
  }
}
