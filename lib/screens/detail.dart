import 'package:anihub/common/constants.dart';
import 'package:anihub/common/progress_indicator.dart';
import 'package:anihub/config/enum.dart';
import 'package:anihub/models/anime.dart';
import 'package:anihub/models/episode.dart';
import 'package:anihub/models/jikan_models.dart';
import 'package:anihub/screens/all_episodes_page.dart';
import 'package:anihub/services/jikan_service.dart';
import 'package:anihub/widgets/episode_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:anihub/screens/all_anime_screen.dart';
import 'package:anihub/providers/episodeprovider.dart';
import 'package:anihub/screens/video_player_screen.dart';
import 'package:anihub/services/consumet_service.dart';

class DetailScreen extends StatefulWidget {
  final int id;
  final ResultType type;

  const DetailScreen({Key? key, required this.id, required this.type})
      : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> with RouteAware {
  static const int _seekDuration = 10; 

  YoutubePlayerController? controller;
  late Anime anime;
  bool loading = true;
  bool showEpisodes = true;
  final ScrollController _scrollController = ScrollController();
  bool isTrailerPlaying = false;
  
  final JikanService _jikanService = JikanService();

  @override
  void initState() {
    super.initState();
    _fetchAnimeDetails().then((_) {
      if (mounted) {
        _initializeEpisodes();
      }
    });
  }

  Future<void> _fetchAnimeDetails() async {
    try {
      final response = await _jikanService.getAnimeDetails(widget.id);
      
      if (response.statusCode == 200) {
        final detailJson = json.decode(response.body);
        final loadedAnime = Anime.fromJson(detailJson['data']);
        
        // Modified trailer initialization
        if (loadedAnime.trailer.isNotEmpty) {
          final videoId = YoutubePlayer.convertUrlToId(loadedAnime.trailer);
          if (videoId != null) {
            controller = YoutubePlayerController(
              initialVideoId: videoId,
              flags: const YoutubePlayerFlags(
                autoPlay: false,
                mute: false,
                isLive: false,
                controlsVisibleAtStart: true,
                loop: false,
                forceHD: true,
              ),
            );
            controller?.addListener(_controllerListener);
          }
        }

        setState(() {
          anime = loadedAnime;
          loading = false;
        });
      }
    } catch (error) {
      print('Error loading anime details: $error');
      setState(() {
        loading = false;
      });
    }
  }

  void _controllerListener() {
    if (mounted) {
      setState(() {
        isTrailerPlaying = controller?.value.isPlaying ?? false;
      });
    }
  }

  void _toggleTrailer() {
    if (controller?.value.isPlaying ?? false) {
      controller?.pause();
    } else {
      controller?.play();
    }
  }

  void _seekForward() {
    if (controller != null) {
      final newPosition = controller!.value.position + const Duration(seconds: _seekDuration);
      controller!.seekTo(newPosition);
    }
  }

  void _seekBackward() {
    if (controller != null) {
      final newPosition = controller!.value.position - const Duration(seconds: _seekDuration);
      controller!.seekTo(newPosition);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPopNext() {
    _resetStatusbar();
    if (controller?.value.isReady ?? false) {
      controller?.play();
    }
    super.didPopNext();
  }

  @override
  void didPushNext() {
    _hideStatusBar();
    if (controller?.value.isReady ?? false) {
      controller?.pause();
    }
    super.didPushNext();
  }

  void _hideStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  void _resetStatusbar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    _scrollController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: CustomProgressIndicator());
    }

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                anime.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainInfo(),
                  const SizedBox(height: 24),
                  _buildQuickStats(),
                  const SizedBox(height: 24),
                  _buildSynopsis(),
                  const SizedBox(height: 24),
                  _buildInformation(),
                  const SizedBox(height: 24),
                  if (anime.theme!.openings.isNotEmpty || anime.theme!.endings.isNotEmpty)
                    _buildThemeSongs(),
                  const SizedBox(height: 24),
                  _buildStreamingPlatforms(),
                  const SizedBox(height: 24),
                  _buildStaffAndStudios(),
                  const SizedBox(height: 24),
                  _buildRelatedAnime(),
                  const SizedBox(height: 24),
                  _buildRecommendedAnime(),
                  const SizedBox(height: 24),
                  _buildEpisodesSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      title: null,
      actions: [
        if (controller != null) ...[
          IconButton(
            icon: const Icon(Icons.replay_10),
            onPressed: _seekBackward,
          ),
          IconButton(
            icon: Icon(isTrailerPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleTrailer,
          ),
          IconButton(
            icon: const Icon(Icons.forward_10),
            onPressed: _seekForward,
          ),
        ],
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (controller != null)
              Container(
                color: Colors.black,
                child: YoutubePlayer(
                  controller: controller!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.red,
                  progressColors: const ProgressBarColors(
                    playedColor: Colors.red,
                    handleColor: Colors.redAccent,
                  ),
                  onReady: () {
                    setState(() {
                      isTrailerPlaying = false;
                    });
                  },
                ),
              )
            else
              CachedNetworkImage(
                imageUrl: anime.getImage(size: 'large'),
                fit: BoxFit.cover,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 100,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            anime.getImage(size: 'medium'),
            height: 200,
            width: 140,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                anime.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (anime.titleEnglish.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  anime.titleEnglish,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    anime.score.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${anime.scoredBy} votes',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard('Rank', '#${anime.rank}'),
        _buildStatCard('Popularity', '#${anime.popularity}'),
        _buildStatCard('Members', NumberFormat.compact().format(anime.members)),
        _buildStatCard('Favorites', NumberFormat.compact().format(anime.favorites)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoRow('Type', anime.type),
        _buildInfoRow('Episodes', anime.episodes.toString()),
        _buildInfoRow('Status', anime.status),
        _buildInfoRow('Aired', anime.aired.string ?? ''),
        _buildInfoRow('Broadcast', anime.broadcast.day ?? ''),
        _buildInfoRow('Source', anime.source),
        _buildInfoRow('Duration', anime.duration),
        _buildInfoRow('Rating', anime.rating),
        if (anime.season.isNotEmpty)
          _buildInfoRow('Season', '${anime.season} ${anime.year}'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSongs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Theme Songs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (anime.theme!.openings.isNotEmpty) ...[
          const Text(
            'Openings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          ...anime.theme!.openings.map((opening) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(opening),
          )),
        ],
        if (anime.theme!.endings.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Endings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          ...anime.theme!.endings.map((ending) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(ending),
          )),
        ],
      ],
    );
  }

  Widget _buildStreamingPlatforms() {
    if (anime.streaming.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Watch On',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: anime.streaming.map((platform) => OutlinedButton(
            onPressed: () => _launchURL(platform.url),
            child: Text(platform.name),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildStaffAndStudios() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Production',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (anime.studios.isNotEmpty) ...[
          const Text(
            'Studios',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: anime.studios.map((studio) => Chip(
              label: Text(studio.name),
            )).toList(),
          ),
        ],
        if (anime.producers.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Producers',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: anime.producers.map((producer) => Chip(
              label: Text(producer.name),
            )).toList(),
          ),
        ],
        if (anime.licensors.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Licensors',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: anime.licensors.map((licensor) => Chip(
              label: Text(licensor.name),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      },
      child: const Icon(Icons.arrow_upward),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Widget _buildSynopsis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Synopsis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(anime.synopsis),
      ],
    );
  }

  Widget _buildRelatedAnime() {
    return FutureBuilder(
      future: _fetchRelations(),
      builder: (context, AsyncSnapshot<List<Relation>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        // Filter out adaptations
        final filteredRelations = snapshot.data!.where((relation) => 
          relation.relation.toLowerCase() != 'adaptation'
        ).toList();

        if (filteredRelations.isEmpty) {
          return const SizedBox.shrink();
        }

        // Take only first 7 items
        final limitedRelations = filteredRelations.take(7).toList();
        final hasMore = filteredRelations.length > 7;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Related Anime',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (hasMore)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllAnimeScreen(
                            type: 'Related Anime',
                            items: filteredRelations,
                            id: widget.id,
                          ),
                        ),
                      );
                    },
                    child: const Text('See All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRelationsList(limitedRelations),
          ],
        );
      },
    );
  }

  Future<List<Relation>> _fetchRelations() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.jikan.moe/v4/anime/${widget.id}/relations')
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> relationsList = jsonResponse['data'];
        
        return relationsList.map((data) => Relation.fromJson(data)).toList();
      }
      return [];
    } catch (error) {
      print('Error fetching relations: $error');
      return [];
    }
  }

  Widget _buildRelationsList(List<Relation> relations) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: relations.length,
        itemBuilder: (context, index) {
          final relation = relations[index];
          final entry = relation.entry[0];
          
          
          String? imageUrl;
          try {
            imageUrl = entry.url.replaceAll('myanimelist.net', 'cdn.myanimelist.net');
            if (!imageUrl.contains('/images/')) {
              imageUrl = null;
            }
          } catch (e) {
            imageUrl = null;
          }

          return GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/detailscreen',
              arguments: json.encode({'id': entry.malId, 'type': widget.type.index}),
            ),
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageUrl != null ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 140,
                      width: 140,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: Center(
                          child: Icon(
                            Icons.movie,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ) : Container(
                      height: 140,
                      width: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.movie,
                          size: 40,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 32, // Fixed height for text container
                    child: Text(
                      entry.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Text(
                    relation.relation,
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
          );
        },
      ),
    );
  }

  Widget _buildRecommendedAnime() {
    return FutureBuilder(
      future: _fetchRecommendations(),
      builder: (context, AsyncSnapshot<List<Recommendation>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        
        final limitedRecommendations = snapshot.data!.take(7).toList();
        final hasMore = snapshot.data!.length > 7;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recommendations',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (hasMore)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllAnimeScreen(
                            type: 'Recommendations',
                            items: snapshot.data!,
                            id: widget.id,
                          ),
                        ),
                      );
                    },
                    child: const Text('See All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRecommendationsList(limitedRecommendations),
          ],
        );
      },
    );
  }

  Future<List<Recommendation>> _fetchRecommendations() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.jikan.moe/v4/anime/${widget.id}/recommendations')
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> recommendationsList = jsonResponse['data'];
        
        return recommendationsList.map((data) => Recommendation.fromJson(data)).toList();
      }
      return [];
    } catch (error) {
      print('Error fetching recommendations: $error');
      return [];
    }
  }

  Widget _buildRecommendationsList(List<Recommendation> recommendations) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final recommendation = recommendations[index];
          final imageUrl = recommendation.entry['images']['jpg']['image_url'] as String?;
          final title = recommendation.entry['title'] as String? ?? 'Unknown';
          final malId = recommendation.entry['mal_id'] as int? ?? 0;

          return GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/detailscreen',
              arguments: json.encode({'id': malId, 'type': ResultType.recommendation.index}),
            ),
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageUrl != null ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 140,
                      width: 140,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.error),
                      ),
                    ) : Container(
                      height: 140,
                      width: 140,
                      color: Colors.grey[800],
                      child: const Icon(Icons.error),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 32, // Fixed height for text container
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                  ),
                  if (recommendation.votes > 0)
                    Text(
                      '${recommendation.votes} votes',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEpisodesSection() {

    print(anime.title);
    print("here");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Episodes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllEpisodesPage(
                      id: widget.id,
                      title: anime.title,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.playlist_play),
              label: const Text('See All Episodes'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildLatestEpisodes(),
      ],
    );
  }

  Widget _buildLatestEpisodes() {
    return Consumer<EpisodeProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.red),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Text(provider.error!),
          );
        }

        final latestEpisodes = provider.episodes.take(3).toList();
        if (latestEpisodes.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: latestEpisodes.length,
              itemBuilder: (context, index) {
                final episode = latestEpisodes[index];
                return EpisodeTile(
                  episode: episode,
                  onTap: () => _playEpisode(episode),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _playEpisode(Episode episode) async {
    try {
      final consumetService = ConsumetService();
      
      // Step 1: Search for anime by title
      final searchResults = await consumetService.searchAnime(anime.title);
      if (searchResults.isEmpty) {
        throw Exception('Anime not found');
      }

      // Step 2: Get anime info with episodes
      final animeId = searchResults[0]['id'];
      final animeInfo = await consumetService.getAnimeInfo(animeId);
      final episodes = animeInfo['episodes'] as List;
      
      // Step 3: Find matching episode
      final consumetEpisode = episodes.firstWhere(
        (e) => e['number'].toString() == episode.number.toString(),
        orElse: () => throw Exception('Episode not found'),
      );

      // Step 4: Get streaming links
      final streamingData = await consumetService.getStreamingLinks(consumetEpisode['id']);
      final sources = streamingData['sources'] as List;
      if (sources.isEmpty) {
        throw Exception('No streaming sources found');
      }

      // Step 5: Navigate to video player with streaming URL
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            episodeId: consumetEpisode['id'],
            title: '${anime.title} - Episode ${episode.number}',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _initializeEpisodes() async {
    print("here _initializeEpisodes ");

    // ignore: unnecessary_null_comparison
    if (anime == null) {
      print('Anime is not initialized yet');
      return;
    }

    try {
      final consumetService = ConsumetService();
      
      // Step 1: Search for anime
      final searchResults = await consumetService.searchAnime(anime!.title);
    
    print("Here is the search results");
    print(searchResults);
      if (searchResults.isEmpty) {
        throw Exception('Anime not found');
      }

     
      final animeId = searchResults[0]['id'];
      final animeInfo = await consumetService.getAnimeInfo(animeId);
      final episodes = animeInfo['episodes'] as List;

      
      final episodeProvider = Provider.of<EpisodeProvider>(context, listen: false);
      episodeProvider.setEpisodes(
        episodes.map((e) => Episode.fromJson(e)).toList()
      );
    } catch (e) {
      print('Error initializing episodes: $e');
    }
  }
}
