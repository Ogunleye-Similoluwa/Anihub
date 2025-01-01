import 'package:http/http.dart' as http;

class JikanService {
  static const String baseUrl = 'https://api.jikan.moe/v4';

  Future<void> _rateLimit() async {
    await Future.delayed(const Duration(milliseconds: 250));
  }

  Future<http.Response> fetchAnimeList() async {
    await _rateLimit();
    final url = Uri.parse('https://api.jikan.moe/v4/top/anime?limit=25&order_by=popularity');
    final response = await http.get(url);
   
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load anime list: ${response.statusCode}');
    }
  }


  Future<http.Response> fetchMangaList() async {
    await _rateLimit();
    final url = Uri.parse('$baseUrl/manga?order_by=popularity&sfw=true');
    final response = await http.get(url);
   
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load manga list: ${response.statusCode}');
    }
  }

  Future<http.Response> getAnimeDetails(int id) async {
    await _rateLimit();
    final url = Uri.parse('https://api.jikan.moe/v4/anime/$id/full');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load anime details: ${response.statusCode}');
    }
  }

  Future<http.Response> getAnimeVideos(int id) async {
    await _rateLimit();
    final url = Uri.parse('$baseUrl/anime/$id/videos');
    return await http.get(url);
  }

  Future<http.Response> getAnimeCharacters(int id) async {
    await _rateLimit();
    final url = Uri.parse('$baseUrl/anime/$id/characters');
    return await http.get(url);
  }

  Future<http.Response> getAnimeStaff(int id) async {
    await _rateLimit();
    final url = Uri.parse('$baseUrl/anime/$id/staff');
    return await http.get(url);
  }

  Future<http.Response> getAnimeReviews(int id) async {
    await _rateLimit();
    final url = Uri.parse('$baseUrl/anime/$id/reviews');
    return await http.get(url);
  }

  Future<http.Response> getAnimeRecommendations(int id) async {
    await _rateLimit();
    final url = Uri.parse('$baseUrl/anime/$id/recommendations');
    return await http.get(url);
  }

  Future<http.Response> getMangaDetails(int id) async {
    await _rateLimit();
    final url = Uri.parse('$baseUrl/manga/$id/full');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load manga details: ${response.statusCode}');
    }
  }

  Future<http.Response> getMangaPictures(int id) async {
    await _rateLimit();
    final url = Uri.parse('$baseUrl/manga/$id/pictures');
    return await http.get(url);
  }

  Future<http.Response> getMangaRecommendations(int id) async {
    await _rateLimit();
    final url = Uri.parse('$baseUrl/manga/$id/recommendations');
    return await http.get(url);
  }

  Future<http.Response> getMangaRelations(int id) async {
    await _rateLimit();
    final url = Uri.parse('$baseUrl/manga/$id/relations');
    return await http.get(url);
  }
} 