import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podds/screens/home_screen/view/widgets/all_songs.dart';
import 'package:podds/global_constants/styles.dart';
import '../../search/view/search.dart';
import 'widgets/favorites.dart';
import 'widgets/playlists.dart';
import 'widgets/recent.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 30,
        backgroundColor: color1,
        leading: const Padding(
          padding: EdgeInsets.all(3.0),
          child: Image(
            image: AssetImage('assets/logo.png'),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(greeting()),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.to(
              () => SearchScreen(),
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
                HomeRecentsSongs(),
                stylesClass.textStyle(hometext: 'All songs'),
                HomeAllSongs(),
                stylesClass.textStyle(hometext: 'Favorites'),
                HomeFavorites(),
                stylesClass.textStyle(hometext: 'Playlists'),
                HomePlaylist(),
              ],
            ),
          )),
    );
  }
}
