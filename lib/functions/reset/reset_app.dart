import 'package:hive/hive.dart';
import 'package:podds/paly_list_model/play_list_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../get_all_songs/get_all_songs.dart';

void resetApp() async {
  final playListDB = await Hive.openBox<PlayListModel>('playlist_db');
  final favBoxdb = await Hive.openBox('favorites');
  final recentbocdb = await Hive.openBox('recentsNotifier');
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.clear();
  await playListDB.clear();
  await favBoxdb.clear();
  await recentbocdb.clear();
  GetAllSongs.audioPlayer.pause();
}
