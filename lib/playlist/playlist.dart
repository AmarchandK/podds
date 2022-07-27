// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_cards/flutter_custom_cards.dart';
import 'package:podds/db_functions/playlist_db_functions.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/paly_list_model/play_list_model.dart';
import 'package:podds/playlist/playlist_view.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  @override
  void initState() {
    getAllPlaylist();
    super.initState();
  }

  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            leading: const Icon(BootstrapIcons.earbuds),
            title: stylesClass.textStyle(hometext: 'Playlists'),
            centerTitle: true,
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: color2,
          )
        ],
        body: ColoredBox(
          color: color2,
          child: ValueListenableBuilder(
              valueListenable: playListNotifier,
              builder: (BuildContext context,
                  List<PlayListModel> savedPlaylistvalue, Widget? child) {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: savedPlaylistvalue.length,
                  itemBuilder: (BuildContext context, int index) {
                    final playlistDataTemp = savedPlaylistvalue[index];
                    return CustomCard(
                        borderRadius: 5,
                        color: color1,
                        onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaylistView(
                                  folderIndex: index,
                                  playlistName: playlistDataTemp.playListName,
                                ),
                              ),
                            ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 130,
                              child: Image.asset(
                                'assets/podds.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                              child: Text(
                                playlistDataTemp.playListName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ));
                  },
                );
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addPlayLsit(context),
        backgroundColor: const Color.fromARGB(184, 10, 114, 128),
        child: const Icon(
          Icons.add,
          color: color2,
          size: 30,
        ),
      ),
    );
  }

  addPlayLsit(context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: color2,
        title: const Text('Create PlayList'),
        content: TextField(
          controller: _textEditingController,
          autofocus: true,
          decoration: const InputDecoration(
              hintText: 'Enter Name', border: OutlineInputBorder()),
        ),
        actions: [
          OutlinedButton(
              onPressed: () {
                _textEditingController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel')),
          OutlinedButton(
              onPressed: () {
                final _playName = _textEditingController.text.trim();
                if (_playName.isNotEmpty) {
                  final _newlist =
                      PlayListModel(playListName: _playName, playlistSongs: []);
                  playlistAdd(_newlist);
                  _textEditingController.clear();
                  Navigator.of(context).pop(MaterialPageRoute(
                    builder: (context) => const PlaylistScreen(),
                  ));
                  // Navigator.pop(context);
                }
              },
              child: const Text('Create')),
        ],
      ),
    );
  }
}
