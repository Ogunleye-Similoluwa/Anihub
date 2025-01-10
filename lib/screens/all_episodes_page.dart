import 'package:anihub/common/message.dart';
import 'package:anihub/providers/episodeprovider.dart';
import 'package:anihub/screens/video_player_screen.dart';
import 'package:anihub/widgets/episode_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anihub/services/consumet_service.dart';
import 'package:anihub/models/episode.dart';

class AllEpisodesPage extends StatefulWidget {
  final String title;
  final int id;
  const AllEpisodesPage({Key? key, required this.id, required this.title})
      : super(key: key);

  @override
  _AllEpisodesPageState createState() => _AllEpisodesPageState();
}

class _AllEpisodesPageState extends State<AllEpisodesPage> {
  late EpisodeProvider episodesProvider;
  final ScrollController listScrollController = ScrollController();
  final ConsumetService _consumetService = ConsumetService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    episodesProvider = Provider.of<EpisodeProvider>(context, listen: false);
    _initializeEpisodes();
  }

  Future<void> _initializeEpisodes() async {
    try {
      setState(() => _isLoading = true);
      
      // Step 1: Search for anime by title
      final searchResults = await _consumetService.searchAnime(widget.title);
      if (searchResults.isEmpty) {
        throw Exception('Anime not found');
      }

      // Step 2: Get anime info with episodes
      final animeId = searchResults[0]['id'];
      final animeInfo = await _consumetService.getAnimeInfo(animeId);
      final episodes = animeInfo['episodes'] as List;
      
      // Update episode provider
      episodesProvider.setEpisodes(
        episodes.map((e) => Episode.fromJson(e)).toList()
      );
    } catch (e) {
      showCustomSnackBar(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _playEpisode(Episode episode) async {
    try {
      // Step 1: Search for anime
      final searchResults = await _consumetService.searchAnime(widget.title);
      if (searchResults.isEmpty) {
        throw Exception('Anime not found');
      }

      // Step 2: Get anime info
      final animeId = searchResults[0]['id'];
      final animeInfo = await _consumetService.getAnimeInfo(animeId);
      final episodes = animeInfo['episodes'] as List;
      
      // Step 3: Find matching episode
      final consumetEpisode = episodes.firstWhere(
        (e) => e['number'].toString() == episode.number.toString(),
        orElse: () => throw Exception('Episode not found'),
      );

      // Step 4: Navigate to video player
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            episodeId: consumetEpisode['id'],
            title: '${widget.title} - Episode ${episode.number}',
          ),
        ),
      );
    } catch (e) {
      showCustomSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.red),
            )
          : Consumer<EpisodeProvider>(
              builder: (context, provider, child) {
                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(provider.error!),
                        ElevatedButton(
                          onPressed: _initializeEpisodes,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.episodes.isEmpty) {
                  return const Center(
                    child: Text('No episodes available'),
                  );
                }

                return ListView.builder(
                  controller: listScrollController,
                  itemCount: provider.episodes.length,
                  itemBuilder: (context, index) {
                    final episode = provider.episodes[index];
                    return EpisodeTile(
                      episode: episode,
                      onTap: () => _playEpisode(episode),
                    );
                  },
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    listScrollController.dispose();
    super.dispose();
  }
}
