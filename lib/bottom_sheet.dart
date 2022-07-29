import 'dart:io';
import 'dart:typed_data';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_cards/flutter_custom_cards.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:podds/add_profile.dart';
import 'package:podds/db_functions/playlist_db_functions.dart';
import 'package:podds/functions/styles.dart';
import 'package:share_plus/share_plus.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key, required context}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}
class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      child: CustomCard(
        color: color2,
        borderRadius: 20,
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: ListView(
            children: [
              const Icon(
                BootstrapIcons.earbuds,
                size: 80,
                color: color1,
              ),
              const SizedBox(
                height: 40,
              ),
              _bottomSheetDatas(
                  title: 'Reset App',
                  ontap: (_) {
                    resetApp();
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => AddScreen()),
                        (route) => false);
                  },
                  iconData: Icons.restart_alt),
              _bottomSheetDatas(
                  title: 'Share',
                  iconData: Icons.share,
                  ontap: (_) async {
                    await Share.share(
                        'check out my website https://example.com',
                        subject: 'Look what I made!');
                  }),
              _bottomSheetDatas(
                  title: 'About',
                  iconData: Icons.info_outline_rounded,
                  ontap: null),
              _bottomSheetDatas(
                  title: 'Feedback',
                  iconData: Icons.feedback,
                  ontap: (_) {
                    setState(() {
                      _betterFeedback(context);
                    });
                  }),
              SizedBox(
                height: MediaQuery.of(context).size.height / 9,
              ),
              const Center(
                child: Text(
                  'Version\n  1.021',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

///////////////////////////////////////////////////////
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
  Future<String> writeImageToStorage(Uint8List feedbackScreenshot) async {
    final Directory output = await getTemporaryDirectory();
    final String screenshotFilePath = '${output.path}/feedback.png';
    final File screenShotFile = File(screenshotFilePath);
    await screenShotFile.writeAsBytes(feedbackScreenshot);
    return screenshotFilePath;
  }
}
