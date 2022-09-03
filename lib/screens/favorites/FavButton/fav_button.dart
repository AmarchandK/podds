import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podds/db_functions/fav_db_functions.dart';
import '../../../functions/constants/styles.dart';

class FavButton extends StatelessWidget {
  FavButton({super.key, required this.id});
  final int id;
  final FavDbFunctions favController = Get.find();
  @override
  Widget build(BuildContext context) {
    final bool isfav = favController.isInFav(id);
    return IconButton(
      onPressed: () {
        if (!isfav) {
          favController.addSongtoFav(id);
          Get.snackbar(
            "Added to Favorites",
            "",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: color1,
            margin: const EdgeInsets.all(10),
            duration: const Duration(seconds: 1),
          );
        } else {
          favController.deleteFromFavorites(id);
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
          : const Icon(Icons.favorite_border_outlined, color: color2),
    );
  }
}
