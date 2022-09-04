import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:podds/screens/all_songs/all_songs.dart';
import 'package:podds/screens/favorites/fav_fuction.dart';
import '../../functions/constants/styles.dart';
import '../search/search.dart';

class LibaryScreen extends StatelessWidget {
  const LibaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: color1,
          leading: const Padding(
            padding: EdgeInsets.all(3.0),
            child: Image(
              image: AssetImage('assets/logo.png'),
            ),
          ),
          centerTitle: true,
          title: const Text("Let's Explore"),
          elevation: 0,
          actions: [
            IconButton(
                onPressed: () => Get.to( SearchScreen()),
                icon: const Icon(Icons.search_sharp))
          ],
          // actions: [
          //   PopupMenuButton<int>(
          //       color: color2,
          //       elevation: 0,
          //       icon: const Icon(Icons.sort),
          //       itemBuilder: (context) => [
          //             const PopupMenuItem(child: Text('Sort By')),
          //             const PopupMenuDivider(
          //               height: 5,
          //             ),
          //             const PopupMenuItem(child: Text('By Date')),
          //             const PopupMenuItem(child: Text('By Name')),
          //             const PopupMenuItem(child: Text('By Size')),
          //           ])
          // ],
          bottom: const TabBar(tabs: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('All Songs'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Favorites'),
            ),
          ]),
        ),
        body: Container(
          decoration: stylesClass.background(),
          child: TabBarView(
            children: [
              AllSongs(),
              FavoriteFunction(),
            ],
          ),
        ),
      ),
    );
  }
}
