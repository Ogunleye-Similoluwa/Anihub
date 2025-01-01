import 'package:anihub/widgets/watching_anime_card.dart';
import 'package:flutter/material.dart';
import 'package:anihub/providers/watching_provider.dart';
import 'package:provider/provider.dart';

class WatchingScreen extends StatefulWidget {
  const WatchingScreen({Key? key}) : super(key: key);

  @override
  _WatchingScreenState createState() => _WatchingScreenState();
}

class _WatchingScreenState extends State<WatchingScreen> {
  String _searchQuery = '';
  String _sortBy = 'lastWatched'; // 'lastWatched', 'title', 'progress'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currently Watching'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'lastWatched',
                child: Text('Last Watched'),
              ),
              const PopupMenuItem(
                value: 'title',
                child: Text('Title'),
              ),
              const PopupMenuItem(
                value: 'progress',
                child: Text('Progress'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search watching list...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: Consumer<WatchingProvider>(
              builder: (context, provider, child) {
                if (provider.watchingList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.movie_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No anime in your watching list',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                var filteredList = provider.watchingList
                    .where((anime) => anime.title
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList();

                // Sort the list
                switch (_sortBy) {
                  case 'lastWatched':
                    filteredList.sort((a, b) =>
                        (b.lastWatched ?? DateTime(0))
                            .compareTo(a.lastWatched ?? DateTime(0)));
                    break;
                  case 'title':
                    filteredList.sort((a, b) => a.title.compareTo(b.title));
                    break;
                  case 'progress':
                    filteredList.sort((a, b) =>
                        (b.lastEpisode ?? 0).compareTo(a.lastEpisode ?? 0));
                    break;
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final anime = filteredList[index];
                    return WatchingAnimeCard(
                      anime: anime,
                      lastEpisode: provider.getLastWatchedEpisode(anime.id),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/detail',
                          arguments: {'id': anime.id},
                        );
                      },
                      onResume: () {
                        Navigator.pushNamed(
                          context,
                          '/episodes',
                          arguments: {
                            'id': anime.id,
                            'title': anime.title,
                            'lastEpisode': anime.lastEpisode,
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 