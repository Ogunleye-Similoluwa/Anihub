import 'dart:convert';
import 'dart:math';

import 'package:anihub/config/enum.dart';
import 'package:anihub/config/styles.dart';
import 'package:anihub/providers/bannerprovider.dart';
import 'package:anihub/providers/searchprovider.dart';
import 'package:anihub/widgets/anime_by_gnera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final RefreshController _refreshController = RefreshController();
  final List<String> _selectedGenres = ['Action'];
  bool _isLoadingGenres = true;

  @override
  void initState() {
    super.initState();
    _selectRandomGenres();
    _loadGenresSequentially();
  }

  void _selectRandomGenres() {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    final availableGenres = searchProvider.gneres.where((g) => g != 'Action').toList();
    availableGenres.shuffle();
    _selectedGenres.addAll(availableGenres.take(9));
  }

  Future<void> _loadGenresSequentially() async {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    
    try {
     
      await Provider.of<BannerProvider>(context, listen: false).getBannerAnime();
      for (String genre in _selectedGenres) {
        await searchProvider.searchByGenre(genre, limit: 7, 
                          shuffle: true,refresh: true);
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      print('Error loading genres: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingGenres = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    try {
      setState(() {
        _isLoadingGenres = true;
      });
      
      await _loadGenresSequentially();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
      print('Refresh error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingGenres = false;
        });
      }
    }
  }

  Widget buildAnimeImage(BuildContext context, String imageUrl) {
    final size = MediaQuery.of(context).size;

    if (imageUrl.isEmpty || imageUrl == '') {
      return  Image.network(
        "https://dummyimage.com/600x800/0a090a/fa0810.jpg&text=ANIHUB",
        fit: BoxFit.cover,
        width: size.width,
        height: size.height * 0.4,
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: size.width,
      height: size.height * 0.4,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ANIHUB',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.of(context).size;
    final banner = Provider.of<BannerProvider>(context).getBanner();

    return Scaffold(
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        header: const WaterDropHeader(
          waterDropColor: Colors.red,
          complete: Icon(Icons.done, color: Colors.red),
          failed: Icon(Icons.error, color: Colors.red),
        ),
        child: SingleChildScrollView(
          child: Stack(
            children: [
              buildAnimeImage(context, banner.getImage(format: "webp", size: "large")),
              Column(
                children: [
                  Container(
                    height: size.height * 0.40,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter),
                    ),
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.all(12),
                      width: size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  banner.title,
                                  style: TextStyles.secondaryTitle,
                                ),
                                Text(banner.genres
                                    .sublist(0, min(3, banner.genres.length))
                                    .map((genre) => genre.name)
                                    .join(", "))
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: Colors.red),
                              onPressed: () => Navigator.pushNamed(
                                  context, '/detailscreen',
                                  arguments: json.encode({
                                    'id': banner.malId,
                                    'type': ResultType.banner.index
                                  })),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text("Watch Now"))
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: size.width,
                    color: Colors.black,
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 12),
                          child: const Text("Discover",
                              style: TextStyles.primaryTitle),
                        ),
                        ..._selectedGenres.map((genre) => AnimesByGenra(
                          limit: 7,
                          shuffle: true,
                          genra: genre,
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
