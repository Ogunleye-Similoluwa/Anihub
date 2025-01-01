import 'dart:convert';

import 'package:anihub/common/message.dart';
import 'package:anihub/config/enum.dart';
import 'package:anihub/config/shimmer.dart';
import 'package:anihub/config/styles.dart';
import 'package:anihub/models/jikan_models.dart';
import 'package:anihub/providers/searchprovider.dart';
import 'package:anihub/widgets/anime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert' as json;
import 'package:http/http.dart' as http;

class AllAnimeScreen extends StatefulWidget {
  final String genra;
  final String query;
   List<dynamic>? items;
  final String? type;
  final int? id;

  AllAnimeScreen({
    Key? key, 
    this.genra = "", 
    this.query = "",
    this.items,
    this.type,
    this.id,
  }) : super(key: key);
  
  @override
  _AllAnimeScreenState createState() => _AllAnimeScreenState();
}

class _AllAnimeScreenState extends State<AllAnimeScreen> {
  late SearchProvider searchProvider;
  late ScrollController gridController = ScrollController();
  bool loading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    searchProvider = Provider.of<SearchProvider>(context, listen: false);
    if (widget.items == null) {
      _initialLoad();
      gridController.addListener(_scrollListener);
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _initialLoad() async {
    try {
      if (widget.genra.isNotEmpty) {
        await searchProvider.searchByGenre(widget.genra, refresh: true);
      } else {
        await searchProvider.searchAnime(widget.query, refresh: true);
      }
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    } catch (err) {
      if (mounted) {
        showCustomSnackBar(context, err.toString());
        setState(() {
          loading = false;
        });
      }
    }
  }

  void _scrollListener() {
    if (gridController.position.pixels == gridController.position.maxScrollExtent) {
      if (!searchProvider.isLoading && searchProvider.hasNextPage) {
        if (widget.genra.isNotEmpty) {
          searchProvider.searchByGenre(widget.genra);
        } else {
          searchProvider.searchAnime(widget.query);
        }
      }
    }
  }

  @override
  void dispose() {
    gridController.dispose();
    super.dispose();
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('No anime found'),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: _initialLoad,
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(dynamic item, int index) {
    if (widget.type == 'recommendations') {
      final recommendation = item as Recommendation;
      return _buildRecommendationItem(recommendation);
    } else if (widget.type == 'relations') {
      final relation = item as Relation;
      return _buildRelationItem(relation);
    } else {
      final animeList = widget.genra.isNotEmpty 
          ? searchProvider.getAnimeByGenre(widget.genra.toLowerCase())
          : searchProvider.searchResults;
      return AnimeWidget(
        anime: animeList[index],
        resulType: widget.genra.isNotEmpty ? ResultType.gnera : ResultType.search,
      );
    }
  }

  Widget _buildRecommendationItem(Recommendation recommendation) {
    final imageUrl = recommendation.entry['images']['jpg']['image_url'] as String?;
    final title = recommendation.entry['title'] as String? ?? 'Unknown';
    final malId = recommendation.entry['mal_id'] as int? ?? 0;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/detailscreen',
        arguments: jsonEncode({
          'id': malId,
          'type': ResultType.recommendation.index
        }),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrl ?? '',
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(
                  color: Colors.grey[800],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
          if (recommendation.votes > 0)
            Text(
              '${recommendation.votes} votes',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[400],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRelationItem(Relation relation) {
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
        arguments: jsonEncode({
          'id': entry.malId,
          'type': ResultType.recommendation.index
        }),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.error),
                      ),
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.movie),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            entry.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            relation.relation,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reloadItems() async {
    if (widget.type == null) return;
    
    setState(() {
      loading = true;
      hasError = false;
    });

    try {
      if (widget.type == 'Related Anime') {
        final response = await http.get(
          Uri.parse('https://api.jikan.moe/v4/anime/${widget.id}/relations')
        );

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final List<dynamic> relationsList = jsonResponse['data'];
          setState(() {
            widget.items = relationsList.map((data) => Relation.fromJson(data)).toList();
          });
        } else {
          throw Exception('Failed to load relations');
        }
      } else if (widget.type == 'Recommendations') {
        final response = await http.get(
          Uri.parse('https://api.jikan.moe/v4/anime/${widget.id}/recommendations')
        );
        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final List<dynamic> recommendationsList = jsonResponse['data'];
          setState(() {
            widget.items = recommendationsList.map((data) => Recommendation.fromJson(data)).toList();
          });
        } else {
          throw Exception('Failed to load recommendations');
        }
      }
    } catch (error) {
      print('Error reloading items: $error');
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type != null ? widget.type! : (widget.genra.isNotEmpty ? widget.genra : widget.query),
          style: TextStyles.secondaryTitle,
        ),
      ),
      body: widget.items != null 
          ? loading 
              ? const Center(child: CircularProgressIndicator(color: Colors.red))
              : hasError || widget.items!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            hasError 
                              ? 'Failed to load ${widget.type}'
                              : 'No ${widget.type} found',
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: _reloadItems,
                            child: const Text(
                              'Reload',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: widget.items!.length,
                      itemBuilder: (context, index) => _buildGridItem(widget.items![index], index),
                    )
          : Consumer<SearchProvider>(
              builder: (context, provider, _) {
                final animeList = widget.genra.isNotEmpty 
                    ? provider.getAnimeByGenre(widget.genra.toLowerCase())
                    : provider.searchResults;

                if (loading) {
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.6,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 15,
                    itemBuilder: (_, __) => LoaderWidget.rectangular(
                      height: size.height * 0.3,
                    ),
                  );
                }

                if (!loading && animeList.isEmpty) {
                  return _buildErrorState();
                }

                return GridView.builder(
                  controller: gridController,
                  padding: const EdgeInsets.all(8),
                  gridDelegate:  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: provider.isLoading 
                      ? animeList.length + 1 
                      : animeList.length,
                  itemBuilder: (context, index) {
                    if (index == animeList.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            color: Colors.red,
                          ),
                        ),
                      );
                    }
                    return _buildGridItem(animeList[index], index);
                  },
                );
              },
            ),
    );
  }
}
