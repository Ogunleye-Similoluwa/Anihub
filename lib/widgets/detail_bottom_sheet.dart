import 'dart:convert';

import 'package:anihub/common/message.dart';
import 'package:anihub/config/enum.dart';
import 'package:anihub/config/styles.dart';
import 'package:anihub/models/anime.dart';
import 'package:anihub/providers/wishlistprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailBottomSheet extends StatelessWidget {
  final Anime anime;
  final ResultType resulttype;
  const DetailBottomSheet(
      {Key? key, required this.anime, required this.resulttype})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final wishlistProvider = Provider.of<WishListProvider>(context);
    return BottomSheet(
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16))),
      onClosing: () {},
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      constraints: BoxConstraints(
                          maxWidth: size.width * 0.35, maxHeight: 180),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                              image: NetworkImage(anime.imageUrl),
                              fit: BoxFit.cover)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ConstrainedBox(
                            constraints:
                                BoxConstraints(maxWidth: size.width * 0.4),
                            child: Text(
                              anime.title,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyles.primaryTitle,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            anime.year.toString(),
                            style: TextStyles.secondaryTitle,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Score : ${anime.score}",
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 25,
                        )),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.red, backgroundColor: Colors.transparent, padding: const EdgeInsets.all(10),
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                  side: BorderSide(
                                    color: Colors.red,
                                  ))),
                          onPressed: () async {
                            try {
                              if (wishlistProvider.isInWishlist(anime.malId)) {
                                await wishlistProvider.removeFromWishlist(anime.malId);
                                if (context.mounted) {
                                  showCustomSnackBar(context, "Removed from wishlist!");
                                }
                              } else {
                                await wishlistProvider.addToWishlist(anime);
                                if (context.mounted) {
                                  showCustomSnackBar(context, "Added to wishlist!");
                                }
                              }
                            } catch (error) {
                              if (context.mounted) {
                                showCustomSnackBar(context, error.toString());
                              }
                            }
                          },
                          icon: Icon(
                            wishlistProvider.isInWishlist(anime.malId)
                                ? Icons.remove_circle_outline
                                : Icons.add,
                            size: 30,
                          ),
                          label: Text(
                            wishlistProvider.isInWishlist(anime.malId)
                                ? "Remove"
                                : "Add to Wishlist",
                          )),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.red, padding: const EdgeInsets.all(10),
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                  side: BorderSide(
                                    color: Colors.red,
                                  ))),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/detailscreen',
                                arguments: json.encode({
                                  'id': anime.malId,
                                  'type': resulttype.index,
                                }));
                          },
                          icon: const Icon(Icons.play_arrow, size: 30),
                          label: const Text("Watch Now")),
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

class SavedBottomSheet extends StatelessWidget {
  final int id;
  final String title;
  final String image;
  const SavedBottomSheet(
      {Key? key, required this.id, required this.title, required this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final wishlistProvider = Provider.of<WishListProvider>(context);
    return BottomSheet(
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16))),
      onClosing: () {},
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      size: 30,
                    )),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    width: 150,
                    height: 180,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                            image: NetworkImage(image), fit: BoxFit.cover)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: size.width * 0.5),
                      child: Text(
                        title,
                        style: TextStyles.primaryTitle,
                      ),
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.red, backgroundColor: Colors.transparent, padding: const EdgeInsets.all(8),
                          shape: const RoundedRectangleBorder(
                              side: BorderSide(color: Colors.red))),
                      onPressed: () async {
                        try {
                          await wishlistProvider.removeFromWishlist(id);
                          if (context.mounted) {
                            showCustomSnackBar(context, "Removed from wishlist!");
                            Navigator.pop(context);
                          }
                        } catch (error) {
                          if (context.mounted) {
                            showCustomSnackBar(context, error.toString());
                          }
                        }
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                      label: const Text("Remove"),
                    ),
                  )),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.red, padding: const EdgeInsets.all(8),
                              shape: const RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.red))),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/detailscreen',
                                arguments: json.encode({
                                  'id': id,
                                  'type': ResultType.saved.index,
                                }));
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text("Watch Now")),
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
