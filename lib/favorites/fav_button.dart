// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:podds/db_functions/fav_db_functions.dart';
import 'package:podds/functions/styles.dart';

class FavBTN extends StatelessWidget {
  FavBTN({Key? key, this.id}) : super(key: key);
  dynamic id;
  final FavDbFunctions _dbController = Get.put(FavDbFunctions());

  @override
  Widget build(BuildContext context) {
    final lastIndex =
        _dbController.favsong.indexWhere((element) => element == id);
    final checkIndex = _dbController.favsong.contains(id);
    if (checkIndex == true) {
      return IconButton(
          onPressed: () async {
            await _dbController.deleteFromFav(lastIndex);

            const snackbar = SnackBar(
                content: Text('remove from favourites'),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                backgroundColor: color1);
            ScaffoldMessenger.of(context).showSnackBar(snackbar);
          },
          icon: const Icon(
            Icons.favorite,
            color: color2,
          ));
    }
    return IconButton(
      onPressed: () async {
        await _dbController.addSongtoFav(id);

        const snackBar = SnackBar(
            content: Text('Add to favorites '),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: color1);

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      icon: const Icon(Icons.favorite_border_outlined, color: color2),
    );
  }
}
