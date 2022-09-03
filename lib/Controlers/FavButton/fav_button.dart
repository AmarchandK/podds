import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podds/db_functions/fav_db_functions.dart';

import '../../functions/styles.dart';

class FavButton extends StatelessWidget {
  FavButton({super.key, required this.isfav});
  final bool isfav;
  FavDbFunctions _dbFunctions = Get.find();
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          if (!isfav) {
            _dbFunctions.addSongtoFav(item);
            Get.snackbar(
              "Added to Favorites",
              "",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: color1,
              margin: const EdgeInsets.all(10),
              duration: const Duration(seconds: 1),
            );
          } else {
            _dbFunctions.deleteFromFavorites(id);
            Get.snackbar(
              "Delete From Favorites",
              "",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: color1,
              margin: const EdgeInsets.all(10),
              duration: const Duration(seconds: 1),
            );
          }
        },
        icon: isfav
            ? const Icon(
                Icons.favorite,
                color: color2,
              )
            : const Icon(Icons.favorite_border_outlined, color: color2));
  }
}
