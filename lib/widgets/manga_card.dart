import 'package:anihub/models/manga.dart';
import 'package:flutter/material.dart';
import 'package:anihub/screens/manga_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:anihub/providers/manga_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MangaCard extends StatelessWidget {
  final Manga manga;
  final VoidCallback onTap;

  const MangaCard({
    Key? key,
    required this.manga,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () async {
        try {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(color: Colors.red),
            ),
          );

          await context.read<MangaProvider>().searchMangaInfo(manga.title);
          
          if (!context.mounted) return;
          Navigator.pop(context);

          final mangaInfo = context.read<MangaProvider>().selectedMangaChapter;
          
          if (mangaInfo != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MangaDetailScreen(manga: manga),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not find manga chapters'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          if (context.mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        width: size.width * 0.32,
        height: size.height * 0.22,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: manga.imageUrl,
                fit: BoxFit.cover,
                httpHeaders: const {
                  'Referer': 'https://mangahere.com',
                },
                placeholder: (context, url) => Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
            Container(
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
                manga.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 