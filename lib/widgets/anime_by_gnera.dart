import 'dart:convert';

import 'package:anihub/config/enum.dart';
import 'package:anihub/config/shimmer.dart';
import 'package:anihub/config/styles.dart';
import 'package:anihub/models/anime.dart';
import 'package:anihub/providers/searchprovider.dart';
import 'package:anihub/widgets/anime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnimesByGenra extends StatefulWidget {
  final String genra;
  final int? limit;
  final bool shuffle;
  const AnimesByGenra({Key? key,  this.limit, required this.genra, required this.shuffle}) : super(key: key);

  @override
  _AnimesByGenraState createState() => _AnimesByGenraState();
}

class _AnimesByGenraState extends State<AnimesByGenra> with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadAnimeByGenre();
  }

  Future<void> _loadAnimeByGenre() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final provider = Provider.of<SearchProvider>(context, listen: false);
      await provider.searchByGenre(widget.genra,shuffle: widget.shuffle, limit: widget.limit, refresh: true);
    } catch (error) {
      print('Error loading anime by genre: $error');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                Text(
                  widget.genra,
                  style: TextStyles.secondaryTitle,
                ),
                const Spacer(),
                TextButton(
                  onPressed:() => Navigator.pushNamed(context, '/allanimescreen',
                        arguments: json.encode({
                          'query': "",
                          'genra': widget.genra
                        })),
                  
                  child: const Text(
                    'See All',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: size.height * 0.24,
            child: Consumer<SearchProvider>(
              builder: (context, provider, _) {
                if (_isLoading) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (_, __) => LoaderWidget.rectangular(
                      height: size.height * 0.22,
                      width: size.width * 0.32,
                    ),
                  );
                }

                if (_hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Failed to load anime'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: _loadAnimeByGenre,
                          child: const Text('Retry', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }

                List<Anime> animeList = provider.getAnimeByGenre(widget.genra.toLowerCase());

                if (animeList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No anime found for this genre'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: _loadAnimeByGenre,
                          child: const Text('Reload', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: animeList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AnimeWidget(
                        anime: animeList[index],
                        resulType: ResultType.all,
                      ),
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

  @override
  bool get wantKeepAlive => true;
}
