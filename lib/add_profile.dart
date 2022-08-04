// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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
          height: double.infinity,
          decoration: stylesClass.background(),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Stack(
                  children: [
                    Positioned(
                      top: 100,
                      left: MediaQuery.of(context).size.width / 3.5,
                      child: SizedBox(
                          height: 150,
                          width: 150,
                          child: Image.asset('assets/1-removebg-preview.png')),
                    ),
                    Lottie.asset('assets/lf20_8uoqnlsb.json'),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    controller: _nameControler,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Your Name';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      errorStyle: const TextStyle(color: color2),
                      hintText: 'Enter Your Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: color1),
                  onPressed: () {
                    if (_formkey.currentState!.validate()) {
                      onTap(context);
                    } else {
                      print('Data Is Empty');
                    }
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.green),
                  ),
                )
              ],
            ),
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
          backgroundColor: color1),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const BaseScreen(),
      ),
    );
  }
}
