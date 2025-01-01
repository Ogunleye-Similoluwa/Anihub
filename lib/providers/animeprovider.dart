import 'dart:convert';
import 'package:anihub/config/enum.dart';
import 'package:anihub/models/anime.dart';
import 'package:anihub/services/jikan_service.dart';
import 'package:flutter/material.dart';

class AnimeProvider with ChangeNotifier {
  final List<Anime> _animes = [];
  final Set<int> _wishlist = {};
  final JikanService _jikanService = JikanService();
  int _currentPage = 1;
  bool _hasNextPage = true;

  DataStatus _datastatus = DataStatus.loading;

  AnimeProvider() {
    fetchAnimes();
  }

  DataStatus get datastatus => _datastatus;
  List<Anime> get animes => [..._animes];
  bool isSaved(int id) => _wishlist.contains(id);
  bool get hasNextPage => _hasNextPage;

  Future<void> fetchAnimes({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _animes.clear();
      }

      if (!_hasNextPage && !refresh) return;

      if (_currentPage == 1) {
        _datastatus = DataStatus.loading;
        notifyListeners();
      }

      final response = await _jikanService.fetchAnimeList();
      final jsonResponse = json.decode(response.body);
      // print(jsonResponse);
      // Check pagination info
      final pagination = jsonResponse['pagination'];
      _hasNextPage = pagination['has_next_page'] ?? false;
      
      // Parse anime list
      final List<dynamic> animeList = jsonResponse['data'];
      
      // print(animeList.length);
      for (var animeData in animeList) {
        try {
          // Get detailed information for each anime
          final detailResponse = await _jikanService.getAnimeDetails(animeData['mal_id']);
          if (detailResponse.statusCode == 200) {
            final detailJson = json.decode(detailResponse.body);
            final anime = Anime.fromJson(detailJson['data']);
            _animes.add(anime);
          }
        } catch (e) {
          print('Error fetching anime details: $e');
        }
      }

      _currentPage++;
      _datastatus = DataStatus.loaded;
      notifyListeners();
    } catch (err) {
      _datastatus = DataStatus.error;
      notifyListeners();
      print('Error fetching anime list: $err');
    }
  }

  Future<void> loadMore() async {
    if (_datastatus != DataStatus.loading) {
      await fetchAnimes();
    }
  }

  Future<void> refresh() async {
    await fetchAnimes(refresh: true);
  }

  List<Anime> getAnimeByGenre(String genre) {
    List<Anime> result = [];
    for (var anime in _animes) {
      if (anime.genreNames.contains(genre)) {
        result.add(anime);
      }
    }
    result.shuffle();
    return result;
  }

  Anime getAnimeById(int id) {
    return _animes.firstWhere(
      (element) => element.malId == id,
      orElse: () => Anime.empty(),
    );
  }

  void toggleWishlist(int id) {
    if (_wishlist.contains(id)) {
      _wishlist.remove(id);
    } else {
      _wishlist.add(id);
    }
    notifyListeners();
  }

  List<Anime> getWishlistAnimes() {
    return _animes.where((anime) => _wishlist.contains(anime.malId)).toList();
  }
}
