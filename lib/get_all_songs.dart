import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';

class GetAllSongs {
  static AudioPlayer audioPlayer = AudioPlayer();
  static int getCurrentIndex = 0;
  static List<SongModel> songscopy = [];
  static List<SongModel> playingSongs = [];
  static ConcatenatingAudioSource createSongList(List<SongModel> songs) {
    List<AudioSource> sources = [];
    playingSongs = songs;
    for (var song in songs) {
      sources.add(
        AudioSource.uri(Uri.parse(song.uri!),
            tag: MediaItem(
              // Specify a unique ID for each media item:
              id: '${song.id}',
              // Metadata to display in the notification:
              album: "${song.album}",
              title: song.displayNameWOExt,
              artUri: Uri.parse('assets/1-removebg-preview.png'),
            )),
      );
    }
    return ConcatenatingAudioSource(children: sources);
  }
}
