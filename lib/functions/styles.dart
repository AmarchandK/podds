import 'package:flutter/material.dart';

const color1 = Color.fromARGB(255, 25, 124, 124);
const color2 = Color.fromARGB(255, 0, 204, 204);
final stylesClass = StylesPage();

class StylesPage {
  Widget build(BuildContext context) {
    return Container();
  }
  BoxDecoration background() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment(0, 0),
        end: Alignment.bottomCenter,
        colors: [color1, color2],
      ),
    );
  }

  Widget textStyle({required String hometext}) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Text(
        hometext,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}

String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Good Morning';
  }
  if (hour < 17) {
    return 'Good Afternoon';
  }
  return 'Good Evening';
}
class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
