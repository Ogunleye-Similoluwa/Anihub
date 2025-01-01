import 'package:anihub/models/jikan_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anihub/providers/manga_provider.dart';
import 'package:anihub/widgets/manga_card.dart';
import 'dart:async';
import 'package:anihub/screens/manga_detail_screen.dart';

class MangaScreen extends StatefulWidget {
  const MangaScreen({Key? key}) : super(key: key);

  @override
  _MangaScreenState createState() => _MangaScreenState();
}

class _MangaScreenState extends State<MangaScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MangaProvider>();
      provider.fetchGenres();
      provider.fetchPopularManga(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<MangaProvider>();
      if (_searchController.text.isEmpty) {
        provider.fetchPopularManga();
      } else {
        provider.searchManga(_searchController.text);
      }
    }
  }

  void _onSearchSubmitted(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        print('Searching for: $query');
        context.read<MangaProvider>().searchManga(query, refresh: true);
      } else {
        context.read<MangaProvider>().fetchPopularManga(refresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const TabBar(
            indicatorColor: Colors.red,
            labelColor: Colors.red,
            tabs: [
              Tab(text: 'Popular'),
              Tab(text: 'Reading'),
              Tab(text: 'Completed'),
            ],
          ),
         
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                cursorColor: Colors.red,
                controller: _searchController,
                onSubmitted: _onSearchSubmitted,
                decoration: InputDecoration(
                  hintText: 'Search manga...',
                 
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            context.read<MangaProvider>().resetSearch();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            _buildGenreFilter(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPopularMangaTab(),
                  _buildReadingMangaTab(),
                  _buildCompletedMangaTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularMangaTab() {
    return Consumer<MangaProvider>(
      builder: (context, provider, child) {
        // Get either search results or popular manga
        final mangaList = _searchController.text.isNotEmpty 
            ? provider.searchResults 
            : provider.getPopularManga();
        
        if (mangaList.isEmpty && provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Colors.red));
        }

        if (mangaList.isEmpty && provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(provider.error!),
                ElevatedButton(
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      provider.searchManga(_searchController.text, refresh: true);
                    } else {
                      provider.fetchPopularManga(refresh: true);
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (mangaList.isEmpty) {
          return const Center(
            child: Text('No manga found'),
          );
        }

        return Stack(
          children: [
            RefreshIndicator(
              color: Colors.red,
              onRefresh: () async {
                if (_searchController.text.isNotEmpty) {
                  await provider.searchManga(_searchController.text, refresh: true);
                } else {
                  await provider.fetchPopularManga(refresh: true);
                }
              },
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: mangaList.length + (provider.hasNextPage ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= mangaList.length) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    );
                  }

                  final manga = mangaList[index];
                  return MangaCard(
                    manga: manga,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MangaDetailScreen(manga: manga),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (provider.isLoading && mangaList.isNotEmpty)
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Colors.red),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildReadingMangaTab() {
    return Consumer<MangaProvider>(
      builder: (context, provider, child) {
        final readingList = provider.getReadingManga();

        if (readingList.isEmpty) {
          return const Center(
            child: Text('No manga in reading list'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.75,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: readingList.length,
          itemBuilder: (context, index) {
            final manga = readingList[index];
            return MangaCard(
              manga: manga,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MangaDetailScreen(manga: manga),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCompletedMangaTab() {
    return Consumer<MangaProvider>(
      builder: (context, provider, child) {
        final completedList = provider.getCompletedManga();

        if (completedList.isEmpty) {
          return const Center(
            child: Text('No completed manga'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.75,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: completedList.length,
          itemBuilder: (context, index) {
            final manga = completedList[index];
            return MangaCard(
              manga: manga,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MangaDetailScreen(manga: manga),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildGenreFilter() {
    return Consumer<MangaProvider>(
      builder: (context, provider, child) {
        if (provider.genres.isEmpty) {
          return const SizedBox.shrink();
        }

        // Remove duplicates and filter out adult genres
        final uniqueGenres = provider.genres.toSet().toList()
          ..sort((a, b) => a.name.compareTo(b.name));
        
        final allGenres = uniqueGenres
          .where((genre) => ![9, 49, 12].contains(genre.malId)).toList();

        // Group genres
        final demographics = allGenres.where((g) => 
          [27, 25, 41, 42, 15].contains(g.malId)).toList();
        final mainGenres = allGenres.where((g) => 
          [1, 2, 5, 46, 28, 4, 8, 10, 26, 47, 14, 7, 22, 24, 36, 30, 37, 45]
          .contains(g.malId)).toList();
        final themes = allGenres.where((g) => 
          g.malId >= 50 && ![49].contains(g.malId)).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Genre>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                  hint: const Text('Select Genre'),
                  value: provider.selectedGenre,
                  items: [
                    if (demographics.isNotEmpty) ...[
                      const DropdownMenuItem<Genre>(
                        enabled: false,
                        child: Text('Demographics', 
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      ...demographics.map((genre) => DropdownMenuItem(
                        value: genre,
                        child: Text('  ${genre.name} (${genre.count})'),
                      )),
                    ],
                    if (mainGenres.isNotEmpty) ...[
                      const DropdownMenuItem<Genre>(
                        enabled: false,
                        child: Text('Main Genres', 
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      ...mainGenres.map((genre) => DropdownMenuItem(
                        value: genre,
                        child: Text('  ${genre.name} (${genre.count})'),
                      )),
                    ],
                    if (themes.isNotEmpty) ...[
                      const DropdownMenuItem<Genre>(
                        enabled: false,
                        child: Text('Themes', 
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      ...themes.map((genre) => DropdownMenuItem(
                        value: genre,
                        child: Text('  ${genre.name} (${genre.count})'),
                      )),
                    ],
                  ],
                  onChanged: (Genre? newValue) {
                    if (newValue != null) {
                      provider.setGenre(newValue);
                    }
                  },
                ),
              ),
              if (provider.selectedGenre != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    provider.setGenre(null);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
} 