// ignore_for_file: file_names

import 'dart:convert';

import 'package:anihub/models/anime.dart';
import 'package:anihub/models/wishlist.dart';
import 'package:anihub/services/jikan_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WishListProvider with ChangeNotifier {
  final JikanService _jikanService = JikanService();
  final List<Anime> _wishlistAnimes = [];
  bool _isLoading = false;
  late Box<WishList> _wishlistBox;

  List<Anime> get wishlistAnimes => [..._wishlistAnimes];
  bool get isLoading => _isLoading;

  WishListProvider() {
    _initHive();
  }

  Future<void> _initHive() async {
    _wishlistBox = await Hive.openBox<WishList>('wishlist');
    await loadWishlist();
  }

  Future<void> loadWishlist() async {
    try {
      _isLoading = true;
      notifyListeners();

      _wishlistAnimes.clear();
      final wishlistItems = _wishlistBox.values.toList();

      for (var item in wishlistItems) {
        try {
          final response = await _jikanService.getAnimeDetails(item.id);
          if (response.statusCode == 200) {
            final jsonResponse = json.decode(response.body);
            final anime = Anime.fromJson(jsonResponse['data']);
            _wishlistAnimes.add(anime);
          }
        } catch (e) {
          print('Error fetching anime details for ID ${item.id}: $e');
        }
      }
    } catch (error) {
      print('Error loading wishlist: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToWishlist(Anime anime) async {
    try {
      final wishlist = WishList(
        id: anime.malId,
        title: anime.title,
        imageUrl: anime.imageUrl,
      );

      await _wishlistBox.put(anime.malId, wishlist);
      
      if (!_wishlistAnimes.any((element) => element.malId == anime.malId)) {
        _wishlistAnimes.add(anime);
        notifyListeners();
      }
    } catch (error) {
      print('Error adding to wishlist: $error');
    }
  }

  Future<void> removeFromWishlist(int id) async {
    try {
      await _wishlistBox.delete(id);
      _wishlistAnimes.removeWhere((anime) => anime.malId == id);
      notifyListeners();
    } catch (error) {
      print('Error removing from wishlist: $error');
    }
  }

  bool isInWishlist(int id) {
    return _wishlistBox.containsKey(id);
  }

  Future<Anime> fetchById(int id) async {
    try {
      final response = await _jikanService.getAnimeDetails(id);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return Anime.fromJson(jsonResponse['data']);
      }
      throw Exception('Failed to fetch anime details');
    } catch (error) {
      print('Error fetching anime by ID: $error');
      return Anime.empty();
    }
  }

  Future<void> clearWishlist() async {
    try {
      await _wishlistBox.clear();
      _wishlistAnimes.clear();
      notifyListeners();
    } catch (error) {
      print('Error clearing wishlist: $error');
    }
  }

  @override
  void dispose() {
    _wishlistBox.close();
    super.dispose();
  }
}
