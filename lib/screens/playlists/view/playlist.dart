// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_cards/flutter_custom_cards.dart';
import 'package:get/get.dart';
import 'package:podds/screens/playlists/controller/playlist_db_controller.dart';
import 'package:podds/global_constants/styles.dart';
import '../model/play_list_model.dart';
import 'playlist_view.dart';

class PlaylistScreen extends StatelessWidget {
  PlaylistScreen({Key? key}) : super(key: key);
  final PlayListcontroller _listcontroller = Get.put(PlayListcontroller());
  final TextEditingController _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            leading: const Padding(
              padding: EdgeInsets.all(3.0),
              child: Image(
                image: AssetImage('assets/logo.png'),
              ),
            ),
            title: stylesClass.textStyle(hometext: 'Playlists'),
            centerTitle: true,
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: color1,
          )
        ],
        body: Container(
          decoration: stylesClass.background(),
          child: GetBuilder<PlayListcontroller>(builder: (controler) {
            final _list = _listcontroller.playListNotifier;
            if (_list.isEmpty) {
              return Center(
                child: EmptyWidget(
                  hideBackgroundAnimation: true,
                  image: 'assets/nullphone.png',
                  title: 'No Playlsit Created',
                  titleTextStyle: const TextStyle(color: color2, fontSize: 21),
                  subTitle: '',
                ),
              );
            } else {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemCount: _list.length,
                itemBuilder: (BuildContext context, int index) {
                  final playlistDataTemp = _list[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: CustomCard(
                      borderRadius: 5,
                      color: color1,
                      onTap: () {
                        _listcontroller.showSelectSong(index);
                        Get.to(
                          () => PlaylistView(
                            folderIndex: index,
                            playlistName: playlistDataTemp.playListName,
                          ),
                        );
                      },
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
                            height: 18,
                            child: Center(
                              child: Text(
                                playlistDataTemp.playListName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }
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
                  _listcontroller.playlistAdd(_newlist);
                  _textEditingController.clear();
                  Navigator.of(context).pop(MaterialPageRoute(
                    builder: (context) => PlaylistScreen(),
                  ));
                }
              },
              child: const Text('Create')),
        ],
      ),
    );
  }
}
