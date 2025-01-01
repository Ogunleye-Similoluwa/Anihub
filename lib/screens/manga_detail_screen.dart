import 'package:flutter/material.dart';
import 'package:anihub/models/manga.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:anihub/providers/manga_provider.dart';
import 'package:anihub/screens/manga_reader_screen.dart';
import 'package:anihub/screens/manga_chapters_screen.dart';

class MangaDetailScreen extends StatefulWidget {
  final Manga manga;

  const MangaDetailScreen({Key? key, required this.manga}) : super(key: key);

  @override
  State<MangaDetailScreen> createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends State<MangaDetailScreen> {
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MangaProvider>().searchMangaInfo(widget.manga.title);
    });
  }

  @override
  void dispose() {
    context.read<MangaProvider>().clearMangaInfo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(),
                const SizedBox(height: 16),
                _buildInfoRow(),
                const SizedBox(height: 16),
                _buildStatusSection(),
                const SizedBox(height: 16),
                _buildGenres(),
                if (widget.manga.themes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildThemes(),
                ],
                if (widget.manga.demographics.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDemographics(),
                ],
                const SizedBox(height: 16),
                _buildSynopsis(),
                const SizedBox(height: 16),
                _buildBackground(),
                const SizedBox(height: 16),
                _buildAuthors(),
                if (widget.manga.serializations.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSerializations(),
                ],
                if (widget.manga.relations.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildRelations(),
                ],
                const SizedBox(height: 80), // Space for FAB
                _buildChaptersList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildActionButton(context),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.manga.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Colors.black,
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: widget.manga.largeImageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[800],
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.red),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.manga.titleEnglish != null && widget.manga.titleEnglish!.isNotEmpty)
            Text(
              widget.manga.titleEnglish!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (widget.manga.titleJapanese != null && widget.manga.titleJapanese!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.manga.titleJapanese!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
          ],
          if (widget.manga.titleSynonyms.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Also known as: ${widget.manga.titleSynonyms.join(", ")}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatusItem(
              label: 'Status',
              value: widget.manga.status,
              icon: Icons.info_outline,
            ),
            _buildStatusItem(
              label: 'Publishing',
              value: widget.manga.publishing ? 'Yes' : 'No',
              icon: Icons.public,
            ),
            _buildStatusItem(
              label: 'Type',
              value: widget.manga.type,
              icon: Icons.category,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.red),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSerializations() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Serializations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.manga.serializations.map((serialization) {
              return Chip(
                label: Text(
                  serialization.name,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Colors.blue.withOpacity(0.1),
                side: const BorderSide(color: Colors.blue),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildThemes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Themes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.manga.themes.map((theme) {
              return Chip(
                label: Text(
                  theme.name,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Colors.purple.withOpacity(0.1),
                side: const BorderSide(color: Colors.purple),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDemographics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Demographics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.manga.demographics.map((demographic) {
              return Chip(
                label: Text(
                  demographic.name,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Colors.orange.withOpacity(0.1),
                side: const BorderSide(color: Colors.orange),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    if (widget.manga.background == null || widget.manga.background!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Background',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.manga.background!,
            style: TextStyle(
              color: Colors.grey[300],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelations() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Related Titles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...widget.manga.relations.map((relation) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  relation.relation,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ...relation.entry.map((entry) => Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                  child: Text(
                    '${entry.name} (${entry.type})',
                    style: const TextStyle(color: Colors.blue),
                  ),
                )),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildInfoItem(
          icon: Icons.star,
          label: 'Score',
          value: widget.manga.score.toStringAsFixed(1),
          color: Colors.amber,
        ),
        _buildInfoItem(
          icon: Icons.book,
          label: 'Chapters',
          value: widget.manga.chapters?.toString() ?? '?',
          color: Colors.blue,
        ),
        _buildInfoItem(
          icon: Icons.library_books,
          label: 'Volumes',
          value: widget.manga.volumes?.toString() ?? '?',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildGenres() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const Text(
          'Genres',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.manga.genres.map((genre) {
            return Chip(
              label: Text(
                genre.name,
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.red.withOpacity(0.1),
              side: const BorderSide(color: Colors.red),
            );
          }).toList(),
        ),
      ],
    ));
  }

  Widget _buildSynopsis() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const Text(
          'Synopsis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.manga.synopsis,
          style: TextStyle(
            color: Colors.grey[300],
            height: 1.5,
          ),
        ),
      ],
    ));
  }

  Widget _buildAuthors() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const Text(
          'Authors',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...widget.manga.authors.map((author) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            author.name,
            style: TextStyle(color: Colors.grey[300]),
          ),
        )),
      ],
    ));
  }

  Widget _buildActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        context.read<MangaProvider>().addToReading(widget.manga);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to reading list'),
            backgroundColor: Colors.green,
          ),
        );
      },
      icon: const Icon(Icons.add),
      label: const Text('Add to Reading'),
      backgroundColor: Colors.red,
    );
  }

  Widget _buildChaptersList() {
    return Consumer<MangaProvider>(
      builder: (context, provider, child) {
        final mangaInfo = provider.selectedMangaChapter;
        print('MangaInfo in UI: $mangaInfo');
        
        if (mangaInfo == null) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.red),
          );
        }

        final chapters = mangaInfo;
        if ( chapters.isEmpty) {
          return const Center(
            child: Text('No chapters available'),
          );
        }

        // Show last 3 chapters in reverse order
        final previewChapters = chapters.reversed.take(3).toList();


        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Latest Chapters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MangaChaptersScreen(
                            title: widget.manga.title,
                            chapters: chapters,
                            coverImage: widget.manga.largeImageUrl,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'See All',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: previewChapters.length,
                itemBuilder: (context, index) {
                  final chapter = previewChapters[index];
                  return GestureDetector(
                    onTap: () {

                      print('Chapter ID: ${chapter['id']}');
                      print('Chapter Title: ${chapter['title']}');
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
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              child: Image.network(
                               widget.manga.largeImageUrl,
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                headers: null,
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
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
} 