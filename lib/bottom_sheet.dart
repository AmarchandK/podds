import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_cards/flutter_custom_cards.dart';
import 'package:podds/add_profile.dart';
import 'package:podds/db_functions/playlist_db_functions.dart';
import 'package:podds/functions/styles.dart';

bool value1 = false;

class SwitchSF extends StatefulWidget {
  const SwitchSF({
    Key? key,
  }) : super(key: key);

  @override
  State<SwitchSF> createState() => _SwitchSFState();
}

class _SwitchSFState extends State<SwitchSF> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40),
      child: Switch.adaptive(
          value: value1,
          onChanged: (value) => setState(() {
                value1 = value;
              })),
    );
  }
}

///////////////////////////////////////////////////////
showOptions(BuildContext context) {
  showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (ctx) {
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
                  ListTile(
                    title: const Text('Reset App'),
                    trailing: IconButton(
                        onPressed: () {
                          resetApp();
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => AddScreen()),
                              (route) => false);
                        },
                        icon: const Icon(Icons.restart_alt)),
                  ),
                  const ListTile(
                    title: Text('Dark Mode'),
                    trailing: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: SwitchSF(),
                    ),
                  ),
                  bottomSheetDatas(
                      title: 'Share', iconData: Icons.share, ontap: null),
                  bottomSheetDatas(
                      title: 'About',
                      iconData: Icons.info_outline_rounded,
                      ontap: null),
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
      });
}

bottomSheetDatas({
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
