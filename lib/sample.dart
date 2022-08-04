import 'package:flutter/material.dart';

class Sample extends StatefulWidget {
  const Sample({Key? key}) : super(key: key);

  @override
  State<Sample> createState() => _SampleState();
}

class _SampleState extends State<Sample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
          height: 900,
          width: 430,
          child: Container(
            color: Colors.amber,
          )),
    );
  }
}
