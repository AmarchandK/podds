// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:flutter/material.dart';
import 'package:podds/db_functions/favorite_db.dart';
import 'package:podds/functions/styles.dart';

class FavBTN extends StatefulWidget {
  FavBTN({Key? key, this.id}) : super(key: key);
  dynamic id;

  @override
  State<FavBTN> createState() => _FavBTNState();
}

class _FavBTNState extends State<FavBTN> {
 

  @override
  Widget build(BuildContext context) {
    final lastIndex =
        FavoriteDB.favsong.indexWhere((element) => element == widget.id);
    final checkIndex = FavoriteDB.favsong.contains(widget.id);
    if (checkIndex == true) {
      return IconButton(
          onPressed: () async {
            await FavoriteDB.deleteFromFav(lastIndex);
            setState(() {});
            const snackbar = SnackBar(
              content: Text('remove from favourites'),
              duration: Duration(seconds: 1),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackbar);
          },
          icon: const Icon(
            Icons.favorite,
            color: color2,
          ));
    }
    return IconButton(
        onPressed: () async {
          await FavoriteDB.addSongtoFav(widget.id);
          setState(() {});
          const snackBar = SnackBar(
            content: Text('add to favorites '),
            duration: Duration(seconds: 1),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        icon: const Icon(Icons.favorite_border_outlined, color: color2));
  }
}
