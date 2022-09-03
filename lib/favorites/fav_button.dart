// // ignore_for_file: use_build_context_synchronously, must_be_immutable

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/instance_manager.dart';
// import 'package:podds/db_functions/fav_db_functions.dart';
// import 'package:podds/functions/styles.dart';

// class FavBTN extends StatelessWidget {
//   FavBTN({Key? key, this.id}) : super(key: key);
//   dynamic id;
//   final FavDbFunctions _dbController = Get.find();

//   @override
//   Widget build(BuildContext context) {
//     final lastIndex =
//         _dbController.favsong.indexWhere((element) => element == id);
//     final checkIndex = _dbController.favsong.contains(id);
//     if (checkIndex == true) {
//       return IconButton(
//           onPressed: () async {
//             await _dbController.deleteFromFav(lastIndex);

//               Get.snackbar(
//               "Delete From Favorites",
//               "",
//               snackPosition: SnackPosition.BOTTOM,
//               backgroundColor: color1,
//               margin: const EdgeInsets.all(10),
//               duration: const Duration(seconds: 1),
//             );
//           },
//           icon: const Icon(
//             Icons.favorite,
//             color: color2,
//           ));
//     }
//     return IconButton(
//       onPressed: () async {
//         await _dbController.addSongtoFav(id);

//     Get.snackbar(
//           "Added to Favorites",
//           "",
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: color1,
//           margin: const EdgeInsets.all(10),
//           duration: const Duration(seconds: 1),
//         );
//       },
//       icon: const Icon(Icons.favorite_border_outlined, color: color2),
//     );
//   }
// }
