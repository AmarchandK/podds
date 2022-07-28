// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:podds/all_songs/all_songs.dart';

class RecentSongs {
  static ValueNotifier<List<dynamic>> recentsNotifier = ValueNotifier([]);
  static List<dynamic> recentPlayed = [];
  static addRecentlyPlayed(item) async {
    final dbBox = await Hive.openBox('recentsNotifier');
    await dbBox.add(item);
    getRecentSongs();
  }

  static getRecentSongs() async {
    final dbBox = await Hive.openBox('recentsNotifier');
    recentPlayed = dbBox.values.toList();

    displayRecents();
    recentsNotifier.notifyListeners();
  }

  static displayRecents() async {
    final dbBox = await Hive.openBox('recentsNotifier');
    final recentsItems = dbBox.values.toList();
    recentsNotifier.value.clear();

    recentPlayed.clear();
    for (int i = 0; i < recentsItems.length; i++) {
      for (int j = 0; j < AllSongs.songs.length; j++) {
        if (recentsItems[i] == AllSongs.songs[j].id) {
          recentsNotifier.value.add(j);
          recentPlayed.add(AllSongs.songs[j]);

        }
      }
    }
    
    recentsNotifier.notifyListeners();
  }
}
