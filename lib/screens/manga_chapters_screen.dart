import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anihub/providers/manga_provider.dart';
import 'package:anihub/screens/manga_reader_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MangaChaptersScreen extends StatelessWidget {
  final String title;
  final List<dynamic> chapters;
  final String coverImage;

  const MangaChaptersScreen({
    Key? key,
    required this.title,
    required this.chapters,
    required this.coverImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          return FutureBuilder<void>(
            future: context.read<MangaProvider>().fetchChapterFirstPage(chapter['id']),
            builder: (context, snapshot) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MangaReaderScreen(
                        chapterId: chapter['id'],
                        title: chapter['title'] ?? 'Chapter ${index + 1}',
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          child: Consumer<MangaProvider>(
                            builder: (context, provider, child) {
                              final firstPage = provider.getChapterFirstPage(chapter['id']);
                              return CachedNetworkImage(
                                imageUrl: firstPage ?? coverImage,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                httpHeaders: const {
                                  'Referer': 'https://readdetectiveconan.com/',
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
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chapter['title'] ?? 'Chapter ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (chapter['releaseDate'] != null)
                              Text(
                                chapter['releaseDate'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 