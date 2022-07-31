import 'dart:async';

import 'package:flutter/material.dart';

const color1 = Color.fromARGB(255, 25, 124, 124);
const color2 = Color.fromARGB(255, 0, 204, 204);
final stylesClass = StylesPage();

class StylesPage {
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

class Debouncer {
  Debouncer({required this.milliseconds});
  final int milliseconds;
  Timer? _timer;
  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
