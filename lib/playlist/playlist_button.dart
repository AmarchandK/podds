import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:podds/all_songs/all_songs.dart';
import 'package:podds/db_functions/playlist_db_functions.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/paly_list_model/play_list_model.dart';

class PlayListAddButton extends StatefulWidget {
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

  @override
  State<PlayListAddButton> createState() => _PlayListAddButtonState();
}

class _PlayListAddButtonState extends State<PlayListAddButton> {
  final PlayListcontroller _listcontroller = Get.put(PlayListcontroller());
  @override
  Widget build(BuildContext context) {
    final checkIndex =_listcontroller. playListNotifier.value[widget.folderindex!].playlistSongs
        .contains(widget.id);
    final indexCheck =_listcontroller. playListNotifier.value[widget.folderindex!].playlistSongs
        .indexWhere((element) => element == widget.id);
    if (checkIndex != true) {
      return IconButton(
          icon: const Icon(
            Icons.playlist_add_circle_outlined,
            color: color2,
            size: 30,
          ),
          onPressed: () async {
            widget.songlist.add(widget.id);
            List<dynamic> newlist = widget.songlist;
            PlayListAddButton.updatelist = [
              newlist,
           _listcontroller.   playListNotifier.value[widget.folderindex!].playlistSongs
            ].expand((element) => element).toList();
            final model = PlayListModel(
              playListName:
          _listcontroller.        playListNotifier.value[widget.folderindex!].playListName,
              playlistSongs: PlayListAddButton.updatelist,
            );
       _listcontroller.     updateList(widget.folderindex, model);
         _listcontroller.   getAllPlaylist();
          _listcontroller.showSelectSong(widget.folderindex);
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 2),
              content: Text(
                'Added ${AllSongs.songs[indexCheck].title} to ${_listcontroller.playListNotifier.value[widget.folderindex!].playListName},',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color.fromARGB(255, 62, 62, 62),
              behavior: SnackBarBehavior.floating,
            ));
          });
    } else {
      return IconButton(
          onPressed: () {
     _listcontroller.       playListNotifier.value[widget.folderindex!].playlistSongs
                .removeAt(indexCheck);
            PlayListAddButton.dltlist = [
              widget.songlist,
         _listcontroller.     playListNotifier.value[widget.folderindex!].playlistSongs
            ].expand((element) => element).toList();
            final model = PlayListModel(
                playListName:
             _listcontroller.       playListNotifier.value[widget.folderindex!].playListName,
                playlistSongs: PlayListAddButton.dltlist);
          _listcontroller.  updateList(widget.folderindex, model);
          _listcontroller.showSelectSong(widget.folderindex);
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  ' Song Removed From ${_listcontroller.playListNotifier.value[widget.folderindex!].playListName}',
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
          ));
    }
  }
}
