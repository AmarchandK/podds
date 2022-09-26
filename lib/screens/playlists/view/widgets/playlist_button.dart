import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podds/screens/playlists/controller/playlist_db_controller.dart';
import 'package:podds/global_constants/styles.dart';
import '../../model/play_list_model.dart';

class PlayListAddButton extends GetView {
  PlayListAddButton({Key? key, required this.folderindex, required this.id})
      : super(key: key);
  final int? folderindex;
  final int? id;
  final List<dynamic> songlist = [];
  static List<dynamic> updatelist = [];
  static List<dynamic> dltlist = [];

  final PlayListcontroller _listcontroller = Get.put(PlayListcontroller());
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
            // _listcontroller.getAllPlaylist();
            _listcontroller.showSelectSong(folderindex);
            Get.snackbar(
                "Song added  to ${_listcontroller.playListNotifier[folderindex!].playListName},",
                "",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: color1,
                margin: const EdgeInsets.all(10),
                duration: const Duration(seconds: 1),
                barBlur: 10);
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

          Get.snackbar(
            "Song removed From ${_listcontroller.playListNotifier[folderindex!].playListName}",
            "",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: color1,
            margin: const EdgeInsets.all(10),
            duration: const Duration(seconds: 1),
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
