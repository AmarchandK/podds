import 'dart:async';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:podds/global_constants/styles.dart';
import 'screens/playlists/model/play_list_model.dart';
import 'screens/splash/view/splash.dart';
import 'global_constants/init_controllers.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(PlayListModelAdapter().typeId)) {
    Hive.registerAdapter(PlayListModelAdapter());
  }
  runApp(const BetterFeedback(child: MyApp()));
  await di.init();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'RaleWay',
        backgroundColor: color2,
        primarySwatch: Colors.blueGrey,
        brightness: Brightness.dark,
      ),
      home: SplashScreen(),
    );
  }
}
