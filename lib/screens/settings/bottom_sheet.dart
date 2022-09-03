// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:typed_data';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_cards/flutter_custom_cards.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:get/route_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:podds/functions/constants/styles.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../functions/reset/reset_app.dart';
import '../add_screen/add_profile.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key, required context}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      color: color1,
      borderRadius: 20,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ScrollConfiguration(
          behavior: MyBehavior(),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.asset('assets/logo.png'),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              _bottomSheetDatas(
                  title: 'Reset App',
                  ontap: (ctx) {
                    showResetWarning(context);
                  },
                  iconData: Icons.restart_alt),
              _bottomSheetDatas(
                  title: 'Share',
                  iconData: Icons.share,
                  ontap: (_) async {
                    await Share.share(
                        'check out my website https://play.google.com/store/apps/details?id=in.brototype.podds',
                        subject: 'Look what I made!');
                  }),
              _bottomSheetDatas(
                  title: 'Rate App',
                  iconData: Icons.star_border,
                  ontap: (ctx) => launch(
                      'https://play.google.com/store/apps/details?id=in.brototype.podds')),
              _bottomSheetDatas(
                  title: 'Feedback',
                  iconData: Icons.rate_review_outlined,
                  ontap: (_) {
                    // setState(() {
                    _betterFeedback(context);
                    // });
                  }),
              _bottomSheetDatas(
                  title: 'About',
                  iconData: Icons.info_outline_rounded,
                  ontap: (ctx) async =>
                      await launch('https://github.com/AmarchandK')),
              const SizedBox(
                height: 50,
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Version\n  1.0.0',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

///////////////////////////////////////////////////////
  ///
  ///
  _bottomSheetDatas({
    required String title,
    required IconData iconData,
    Function(String)? ontap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
            color: Colors.black, fontFamily: 'BalsamiqSans_Regular'),
      ),
      trailing: Icon(iconData, color: Colors.black),
      onTap: () => ontap?.call(title),
    );
  }

  _betterFeedback(context) {
    BetterFeedback.of(context).show((UserFeedback feedback) async {
      final screenShotFilePath = await writeImageToStorage(feedback.screenshot);
      final Email email = Email(
        body: feedback.text,
        subject: 'PODDS Feedback',
        recipients: ['amarchand00345@gmail.com'],
        attachmentPaths: [screenShotFilePath],
        isHTML: false,
      );
      await FlutterEmailSender.send(email);
    });
  }

  showResetWarning(ctx) {
    return showDialog(
      context: ctx,
      builder: (ctx) => AlertDialog(
        title: const Text("Warning"),
        content: const Text(
            "All this app's data will be deleted permanently,\nThis includes all Favorites & Playlists that you added !"),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              resetApp();
              Get.offAll(AddScreen());
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              child: const Text("Okay"),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> writeImageToStorage(Uint8List feedbackScreenshot) async {
    final Directory output = await getTemporaryDirectory();
    final String screenshotFilePath = '${output.path}/feedback.png';
    final File screenShotFile = File(screenshotFilePath);
    await screenShotFile.writeAsBytes(feedbackScreenshot);
    return screenshotFilePath;
  }
}
