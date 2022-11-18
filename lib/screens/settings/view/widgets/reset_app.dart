import 'package:hive/hive.dart';
import '../../../playlists/model/play_list_model.dart';
import '../../../../global_constants/get_all_songs.dart';

Future<void> resetApp() async {
  final playListDB = await Hive.openBox<PlayListModel>('playlist_db');
  final favBoxdb = await Hive.openBox<int>('favorites');
  final recentbocdb = await Hive.openBox<int>('recentsNotifier');
  await playListDB.clear();
  await favBoxdb.clear();
  await recentbocdb.clear();
  GetAllSongs.audioPlayer.pause();
}
