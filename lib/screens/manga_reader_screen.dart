import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anihub/providers/manga_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MangaReaderScreen extends StatefulWidget {
  final String chapterId;
  final String title;

  const MangaReaderScreen({
    Key? key,
    required this.chapterId,
    required this.title,
  }) : super(key: key);

  @override
  State<MangaReaderScreen> createState() => _MangaReaderScreenState();
}

class _MangaReaderScreenState extends State<MangaReaderScreen> {
  List<ChapterPage> chapterPages = [];
  bool isLoading = true;
  String? error;
  int currentPage = 0;
  bool showControls = true;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    context.read<MangaProvider>().setCurrentChapterIndex(widget.chapterId);
    fetchChapterPages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchChapterPages() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await Provider.of<MangaProvider>(context, listen: false)
          .getMangaChapters(widget.chapterId);

      setState(() {
        chapterPages = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void toggleControls() {
    setState(() {
      showControls = !showControls;
    });
  }

  void nextPage() {
    if (currentPage < chapterPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> navigateToChapter(String chapterId, String title) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MangaReaderScreen(
          chapterId: chapterId,
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error!),
            ElevatedButton(
              onPressed: fetchChapterPages,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (chapterPages.isEmpty) {
      return const Center(
        child: Text('No pages found'),
      );
    }

    return Consumer<MangaProvider>(
      builder: (context, provider, child) {
        final nextChapterId = provider.getNextChapterId();
        final previousChapterId = provider.getPreviousChapterId();
        final chapters = provider.selectedMangaChapter;
        final currentIndex = provider.currentChapterIndex;

        return Stack(
          children: [
            // Page View
            GestureDetector(
              onTap: toggleControls,
              child: PageView.builder(
                controller: _pageController,
                itemCount: chapterPages.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = chapterPages[index];
                  return InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 3.0,
                    child: CachedNetworkImage(
                      httpHeaders: {
                        'Referer': 'https://www.mangahere.cc/',
                        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
                      },
                      imageUrl: page.img,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.red),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  );
                },
              ),
            ),

            // Controls overlay
            if (showControls) ...[
              // Top bar with chapter navigation
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    bottom: 8,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            color: Colors.white,
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Text(
                              widget.title,
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (nextChapterId != null)
                            TextButton.icon(
                              icon: const Icon(Icons.skip_previous, color: Colors.white),
                              label: const Text('Previous Chapter', style: TextStyle(color: Colors.white)),
                              onPressed: () {
                                 if (chapters != null && currentIndex != null) {
                                  navigateToChapter(
                                    nextChapterId,
                                    chapters[currentIndex + 1]['title'] ?? 'Chapter ${currentIndex + 2}',
                                  );
                                }
                              },
                            ),
                          if (previousChapterId != null)
                            TextButton.icon(
                              icon: const Icon(Icons.skip_next, color: Colors.white),
                              label: const Text('Next Chapter', style: TextStyle(color: Colors.white)),
                              onPressed: () {

                                   if (chapters != null && currentIndex != null) {
                                  navigateToChapter(
                                    previousChapterId,
                                    chapters[currentIndex - 1]['title'] ?? 'Chapter ${currentIndex}',
                                  );
                                }




                              
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom page navigation
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        color: Colors.white,
                        onPressed: currentPage > 0 ? previousPage : null,
                      ),
                      Text(
                        '${currentPage + 1}/${chapterPages.length}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        color: Colors.white,
                        onPressed: currentPage < chapterPages.length - 1 ? nextPage : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class ChapterPage {
  final String img;
  final int page;

  ChapterPage({
    required this.img,
    required this.page,
  });

  factory ChapterPage.fromJson(Map<String, dynamic> json) {
    return ChapterPage(
      img: json['img'] as String,
      page: json['page'] as int,
    );
  }
}