import 'package:anihub/config/enum.dart';
import 'package:anihub/models/anime.dart';
import 'package:anihub/widgets/detail_bottom_sheet.dart';
import 'package:flutter/material.dart';

class AnimeWidget extends StatelessWidget {
  final Anime anime;
  final ResultType resulType;
  const AnimeWidget({Key? key, required this.anime, required this.resulType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => showBottomSheet(
          context: context,
          builder: (context) =>
              DetailBottomSheet(anime: anime, resulttype: resulType)),
      child: Container(
        margin: const EdgeInsets.all(8),
        width: size.width * 0.32,
        height: size.height * 0.22,
        decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
                image: NetworkImage(anime.imageUrl), fit: BoxFit.cover),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          padding: const EdgeInsets.all(8),
          alignment: Alignment.bottomLeft,
          child: Text(
            anime.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
