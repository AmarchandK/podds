// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:podds/base_screen.dart';
import 'package:podds/functions/styles.dart';
import 'package:podds/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddScreen extends StatelessWidget {
  AddScreen({Key? key}) : super(key: key);
  final _nameControler = TextEditingController();
  static final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formkey,
        child: Container(
          decoration: stylesClass.background(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Icon(Icons.abc),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _nameControler,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Your Name';
                    } else {
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                    errorStyle: TextStyle(color: color2),
                    hintText: 'Enter Your Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formkey.currentState!.validate()) {
                    onTap(context);
                  } else {
                    print('Data Is Empty');
                  }
                },
                child: const Icon(Icons.login),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onTap(context) async {
    final sharedpref = await SharedPreferences.getInstance();

    sharedpref.setString('name', _nameControler.text);
    name = _nameControler.text;
    sharedpref.setBool('loged', true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Saved'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const BaseScreen(),
      ),
    );
  }
}
