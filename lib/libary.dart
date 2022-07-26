import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:podds/favorites/fav_fuction.dart';
import 'functions/styles.dart';

class LibaryScreen extends StatefulWidget {
  const LibaryScreen({Key? key}) : super(key: key);

  @override
  State<LibaryScreen> createState() => _LibaryScreenState();
}

class _LibaryScreenState extends State<LibaryScreen> {
  @override
  void initState() {
    super.initState();
    Permission.storage.request(); /*allow permission to storage */

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: color1,
          leading: const Icon(
            BootstrapIcons.earbuds,
            color: color2,
            size: 30,
          ),
          title: const Text('Hey Buddy'),
          elevation: 0,
          actions: [
            PopupMenuButton<int>(
                color: color2,
                elevation: 0,
                icon: const Icon(Icons.sort),
                itemBuilder: (context) => [
                      const PopupMenuItem(child: Text('Sort By')),
                      const PopupMenuDivider(
                        height: 5,
                      ),
                      const PopupMenuItem(child: Text('By Date')),
                      const PopupMenuItem(child: Text('By Name')),
                      const PopupMenuItem(child: Text('By Size')),
                    ])
          ],
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
            stylesClass.allsongList(),
            const FavoriteFunction(),
          ]),
        ),
      ),
    );
  }
}
