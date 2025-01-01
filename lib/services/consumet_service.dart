import 'package:http/http.dart' as http;
import 'dart:convert';

class ConsumetService {
  final String baseUrl = 'http://localhost:3000';

  Future<List<dynamic>> searchAnime(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/anime/gogoanime/${Uri.encodeComponent(query)}')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'] ?? [];
      }
      throw Exception('Failed to search anime');
    } catch (e) {
      print('Error searching anime: $e');
      throw Exception('Failed to search anime');
    }
  }

  Future<Map<String, dynamic>> getAnimeInfo(String animeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/anime/gogoanime/info/$animeId')
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to get anime info');
    } catch (e) {
      print('Error getting anime info: $e');
      throw Exception('Failed to get anime info');
    }
  }

  Future<Map<String, dynamic>> getStreamingLinks(String episodeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/anime/gogoanime/watch/$episodeId')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['sources'] == null || (data['sources'] as List).isEmpty) {
          throw Exception('No streaming sources available');
        }
        return data;
      }
      throw Exception('Failed to get streaming links');
    } catch (e) {
      print('Error getting streaming links: $e');
      throw Exception('Failed to get streaming links');
    }
  }

  String getBestQualityUrl(List<dynamic> sources) {
    // Try to find 1080p first
    var source = sources.firstWhere(
      (source) => source['quality'] == '1080p',
      orElse: () => sources.firstWhere(
        (source) => source['quality'] == '720p',
        orElse: () => sources.first,
      ),
    );
    return source['url'] as String;
  }

  Future<List<dynamic>> searchManga(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/manga/mangahere/${Uri.encodeComponent(query)}')
      );

      print('Manga Search Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'] ?? [];
      }
      throw Exception('Failed to search manga');
    } catch (e) {
      print('Error searching manga: $e');
      throw Exception('Failed to search manga');
    }
  }

  Future<Map<String, dynamic>> getMangaInfo(String mangaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/manga/mangahere/info?id=$mangaId')
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to get manga info');
    } catch (e) {
      print('Error getting manga info: $e');
      throw Exception('Failed to get manga info');
    }
  }

  Future<List<dynamic>> getMangaChapters(String chapterId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/manga/mangahere/read?chapterId=$chapterId')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['images'] ?? [];
      }
      throw Exception('Failed to get manga chapters');
    } catch (e) {
      print('Error getting manga chapters: $e');
      throw Exception('Failed to get manga chapters');
    }
  }
} 