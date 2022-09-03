import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';
import 'package:podds/screens/all_songs/all_songs.dart';
import 'package:podds/db_functions/playlist_db_functions.dart';
import 'package:podds/functions/constants/styles.dart';
import 'package:podds/paly_list_model/play_list_model.dart';

class PlayListAddButton extends GetView {
  PlayListAddButton(
      {Key? key,
      required this.index,
      required this.folderindex,
      required this.id})
      : super(key: key);
  final int? index;
  final int? folderindex;
  final int? id;
  final List<dynamic> songlist = [];
  static List<dynamic> updatelist = [];
  static List<dynamic> dltlist = [];

  final PlayListcontroller _listcontroller = Get.find();
  @override
  Widget build(BuildContext context) {
    final checkIndex = _listcontroller
        .playListNotifier[folderindex!].playlistSongs
        .contains(id);
    final indexCheck = _listcontroller
        .playListNotifier[folderindex!].playlistSongs
        .indexWhere((element) => element == id);
    if (checkIndex != true) {
      return IconButton(
          icon: const Icon(
            Icons.playlist_add_circle_outlined,
            color: color2,
            size: 30,
          ),
          onPressed: () async {
            songlist.add(id);
            List<dynamic> newlist = songlist;
            PlayListAddButton.updatelist = [
              newlist,
              _listcontroller.playListNotifier[folderindex!].playlistSongs
            ].expand((element) => element).toList();
            final model = PlayListModel(
              playListName:
                  _listcontroller.playListNotifier[folderindex!].playListName,
              playlistSongs: PlayListAddButton.updatelist,
            );
            _listcontroller.updateList(folderindex, model);
            _listcontroller.getAllPlaylist();
            _listcontroller.showSelectSong(folderindex);
            // setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 2),
              content: Text(
                'Added ${AllSongs.songs[indexCheck].title} to ${_listcontroller.playListNotifier[folderindex!].playListName},',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color.fromARGB(255, 62, 62, 62),
              behavior: SnackBarBehavior.floating,
            ));
          });
    } else {
      return IconButton(
        onPressed: () {
          _listcontroller.playListNotifier[folderindex!].playlistSongs
              .removeAt(indexCheck);
          PlayListAddButton.dltlist = [
            songlist,
            _listcontroller.playListNotifier[folderindex!].playlistSongs
          ].expand((element) => element).toList();
          final model = PlayListModel(
              playListName:
                  _listcontroller.playListNotifier[folderindex!].playListName,
              playlistSongs: PlayListAddButton.dltlist);
          _listcontroller.updateList(folderindex, model);
          _listcontroller.showSelectSong(folderindex);
          // setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ' Song Removed From ${_listcontroller.playListNotifier[folderindex!].playListName}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color.fromARGB(255, 68, 68, 68),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        icon: const Icon(
          Icons.playlist_add_check_circle,
          color: color2,
          size: 30,
        ),
      );
    }
  }
}
