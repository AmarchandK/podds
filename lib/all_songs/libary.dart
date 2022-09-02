import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:podds/all_songs/all_songs.dart';
import 'package:podds/favorites/fav_fuction.dart';
import 'package:podds/search.dart';
import '../functions/styles.dart';

class LibaryScreen extends StatefulWidget {
  const LibaryScreen({Key? key}) : super(key: key);

  @override
  State<LibaryScreen> createState() => _LibaryScreenState();
}

class _LibaryScreenState extends State<LibaryScreen> {
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
                onPressed: () => Get.to(const SearchScreen()),
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
          child: TabBarView(children: [
            AllSongs(),
             FavoriteFunction(),
          ]),
        ),
      ),
    );
  }
}
