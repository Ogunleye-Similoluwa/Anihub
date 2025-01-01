import 'dart:convert';
import 'dart:math';

import 'package:anihub/models/anime.dart';
import 'package:anihub/services/jikan_service.dart';
import 'package:flutter/material.dart';

class BannerProvider with ChangeNotifier {

    final JikanService _jikanService = JikanService();

  Anime _bannerAnime = Anime.empty();

  Anime getBanner() {
    return _bannerAnime;
  }

  BannerProvider() {
    getBannerAnime();
  }

  Future<void> getBannerAnime() async {
    try {
      // Get top anime list
      final response = await _jikanService.fetchAnimeList();
      
      final jsonResponse = json.decode(response.body);
     
      final animeList = (jsonResponse['data'] as List);
      // print(animeList.length);

    
      if (animeList.isNotEmpty) {
        
        final randomIndex = Random().nextInt(animeList.length);
        final randomAnimeId = animeList[randomIndex]['mal_id'];
        
       
        // Get detailed information for the selected anime
        final detailResponse = await _jikanService.getAnimeDetails(randomAnimeId);
        
        if (detailResponse.statusCode == 200) {
          final detailJson = json.decode(detailResponse.body);
          _bannerAnime = Anime.fromJson(detailJson['data']);
          notifyListeners();

          // _fetchAdditionalData(randomAnimeId);
        }
      }
    } catch (error) {
      print('Error fetching banner anime: $error');
  
      notifyListeners();
    }
  }

  Future<void> _fetchAdditionalData(int animeId) async {
    try {
      // Fetch videos
      final videosResponse = await _jikanService.getAnimeVideos(animeId);
      if (videosResponse.statusCode == 200) {
        final videosJson = json.decode(videosResponse.body);
        // Handle videos data
      }

      // Fetch characters
      final charactersResponse = await _jikanService.getAnimeCharacters(animeId);
      if (charactersResponse.statusCode == 200) {
        final charactersJson = json.decode(charactersResponse.body);
        // Handle characters data
      }

      // Fetch staff
      final staffResponse = await _jikanService.getAnimeStaff(animeId);
      if (staffResponse.statusCode == 200) {
        final staffJson = json.decode(staffResponse.body);
        // Handle staff data
      }

      // Fetch recommendations
      final recommendationsResponse = await _jikanService.getAnimeRecommendations(animeId);
      if (recommendationsResponse.statusCode == 200) {
        final recommendationsJson = json.decode(recommendationsResponse.body);
        // Handle recommendations data
      }

      // Update the UI after fetching all additional data
      notifyListeners();
    } catch (error) {
      print('Error fetching additional data: $error');
    }
  }
}
