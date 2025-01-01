import 'package:anihub/models/jikan_models.dart';
import 'package:anihub/models/manga.dart';
import 'package:anihub/screens/manga_reader_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MangaProvider with ChangeNotifier {
  List<Manga> _popularManga = [];
  List<Manga> _readingManga = [];
  List<Manga> _completedManga = [];
  List<Manga> _searchResults = [];
  bool _isLoading = false;
  bool _hasNextPage = true;
  int _currentPage = 1;
  String? _error;
  Genre? _selectedGenre;
  List<Genre> _genres = [];
  List <dynamic>? _selectedMangaChapters;
  List<dynamic>? _currentChapters;
  String? _selectedMangaId;
  Map<String, String> _chapterFirstPages = {};
  int? _currentChapterIndex;
  
  bool get isLoading => _isLoading;
  bool get hasNextPage => _hasNextPage;
  String? get error => _error;
  List<Manga> get searchResults => _searchResults;
  Genre? get selectedGenre => _selectedGenre;
  List<Genre> get genres => _genres;
 List<dynamic>? get selectedMangaChapter => _selectedMangaChapters;
  List<dynamic>? get currentChapters => _currentChapters;
  String? getChapterFirstPage(String chapterId) => _chapterFirstPages[chapterId];
  int? get currentChapterIndex => _currentChapterIndex;

  List<Manga> getPopularManga() => _popularManga;
  List<Manga> getReadingManga() => _readingManga;
  List<Manga> getCompletedManga() => _completedManga;

  static const Map<String, int> genreIds = {
    // Demographics
    'Shounen': 27,
    'Shoujo': 25,
    'Seinen': 41,
    'Josei': 42,
    'Kids': 15,

    // Genres
    'Action': 1,
    'Adventure': 2,
    'Avant Garde': 5,
    'Award Winning': 46,
    'Boys Love': 28,
    'Comedy': 4,
    'Drama': 8,
    'Fantasy': 10,
    'Girls Love': 26,
    'Gourmet': 47,
    'Horror': 14,
    'Mystery': 7,
    'Romance': 22,
    'Sci-Fi': 24,
    'Slice of Life': 36,
    'Sports': 30,
    'Supernatural': 37,
    'Suspense': 45,

    // Explicit Genres
    'Ecchi': 9,
    'Erotica': 49,
    'Hentai': 12,

    // Themes
    'Adult Cast': 50,
    'Anthropomorphic': 51,
    'CGDCT': 52,
    'Childcare': 53,
    'Combat Sports': 54,
    'Crossdressing': 44,
    'Delinquents': 55,
    'Detective': 39,
    'Educational': 56,
    'Gag Humor': 57,
    'Gore': 58,
    'Harem': 35,
    'High Stakes Game': 59,
    'Historical': 13,
    'Idols (Female)': 60,
    'Idols (Male)': 61,
    'Isekai': 62,
    'Iyashikei': 63,
    'Love Polygon': 64,
    'Magical Sex Shift': 65,
    'Mahou Shoujo': 66,
    'Martial Arts': 17,
    'Mecha': 18,
    'Medical': 67,
    'Memoir': 68,
    'Military': 38,
    'Music': 19,
    'Mythology': 6,
    'Organized Crime': 69,
    'Otaku Culture': 70,
    'Parody': 20,
    'Performing Arts': 71,
    'Pets': 72,
    'Psychological': 40,
    'Racing': 3,
    'Reincarnation': 73,
    'Reverse Harem': 74,
    'Samurai': 21,
    'School': 23,
    'Showbiz': 76,
    'Space': 29,
    'Strategy Game': 11,
    'Super Power': 31,
    'Survival': 77,
    'Team Sports': 78,
    'Time Travel': 79,
    'Vampire': 32,
    'Video Game': 80,
    'Villainess': 81,
    'Visual Arts': 82,
    'Workplace': 48,
    'Urban Fantasy': 83,
  };

  static const String baseUrl = 'https://api.jikan.moe/v4';

  Future<void> fetchGenres() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/genres/manga')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['data'];
        
        // Convert to set and back to list to remove duplicates
        _genres = results.map((json) => Genre.fromJson(json))
          .toSet()
          .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
        
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void setGenre(Genre? genre) {
    _selectedGenre = genre;
    if (genre != null) {
      fetchMangaByGenre(genre.malId, refresh: true);
    } else {
      fetchPopularManga(refresh: true);
    }
  }

  Future<void> fetchMangaByGenre(int genreId, {bool refresh = false}) async {
    if (_isLoading || (!_hasNextPage && !refresh)) return;

    try {
      if (refresh) {
        _currentPage = 1;
        _popularManga = [];
        _hasNextPage = true;
      }

      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$baseUrl/manga?page=$_currentPage&limit=20&genres=$genreId&sfw=true')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['data'];
        final pagination = data['pagination'];
        
        _hasNextPage = pagination['has_next_page'] ?? false;
        _popularManga.addAll(results.map((json) => Manga.fromJson(json)).toList());
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPopularManga({bool refresh = false}) async {
    if (_isLoading || (!_hasNextPage && !refresh)) return;

    try {
      if (refresh) {
        _currentPage = 1;
        _popularManga = [];
        _hasNextPage = true;
      }

      _isLoading = true;
      notifyListeners();

      // Get random order_by parameter
      final orderByOptions = ['popularity', 'rank', 'favorites', 'score'];
      final randomOrderBy = orderByOptions[DateTime.now().millisecondsSinceEpoch % orderByOptions.length];
      
      final response = await http.get(
        Uri.parse('$baseUrl/manga?page=$_currentPage&limit=20&order_by=$randomOrderBy&sfw=true')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['data'];
        final pagination = data['pagination'];
        
        // Shuffle the results before adding them
        final shuffledResults = List.from(results)..shuffle();
        
        _hasNextPage = pagination['has_next_page'] ?? false;
        _popularManga.addAll(shuffledResults.map((json) => Manga.fromJson(json)).toList());
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchManga(String query, {bool refresh = false}) async {
    if (_isLoading || (query.isEmpty && !refresh)) return;

    try {
      if (refresh) {
        _currentPage = 1;
        _popularManga = [];
        _searchResults = [];
        _hasNextPage = true;
      }

      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$baseUrl/manga?q=$query&page=$_currentPage&limit=20&sfw=true')
      );

      print('Search Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['data'];
        final pagination = data['pagination'];
        
        _hasNextPage = pagination['has_next_page'] ?? false;
        _searchResults.addAll(results.map((json) => Manga.fromJson(json)).toList());
        _currentPage++;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetSearch() {
    _searchResults = [];
    _popularManga = [];
    _currentPage = 1;
    _hasNextPage = true;
    _error = null;
    fetchPopularManga(refresh: true);
    notifyListeners();
  }

  // Mock methods for reading and completed manga
  void addToReading(Manga manga) {
    if (!_readingManga.contains(manga)) {
      _readingManga.add(manga);
      notifyListeners();
    }
  }

  void addToCompleted(Manga manga) {
    if (!_completedManga.contains(manga)) {
      _completedManga.add(manga);
      notifyListeners();
    }
  }

  Future<void> fetchRandomManga({bool refresh = false}) async {
    if (_isLoading || (!_hasNextPage && !refresh)) return;

    try {
      if (refresh) {
        _currentPage = 1;
        _popularManga = [];
        _hasNextPage = true;
      }

      _isLoading = true;
      notifyListeners();

      // Get a random page number between 1 and 20
      final randomPage = _currentPage + (DateTime.now().millisecondsSinceEpoch % 20);
      
      final response = await http.get(
        Uri.parse('$baseUrl/manga?page=$randomPage&limit=20&order_by=popularity&sort=random')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['data'];
        final pagination = data['pagination'];
        
        _hasNextPage = pagination['has_next_page'] ?? false;
        _popularManga.addAll(results.map((json) => Manga.fromJson(json)).toList());
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  final String mangaBaseUrl = 'http://localhost:3000';


  Future<void> searchMangaInfo(String query) async {
    try {
      _isLoading = true;
      _selectedMangaChapters = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$mangaBaseUrl/manga/mangahere/${Uri.encodeComponent(query)}')
      );

      print('Manga Search Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          _selectedMangaId = results[0]['id'];
          await fetchMangaInfo(_selectedMangaId!);
        }
      }
    } catch (e) {
      print('Error searching manga: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMangaInfo(String mangaId) async {
    try {
      final response = await http.get(
        Uri.parse('$mangaBaseUrl/manga/mangahere/info?id=$mangaId')
      );

      print('Manga Info Response: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> mangaInfo = json.decode(response.body);
        _selectedMangaChapters = mangaInfo["chapters"];
        notifyListeners();
      }
    } catch (e) {
      print('Error getting manga info: $e');
      _error = e.toString();
    }
  }

  Future<List<ChapterPage>> getMangaChapters(String chapterId) async {
    try {
      final response = await http.get(
        Uri.parse('$mangaBaseUrl/manga/mangahere/read?chapterId=$chapterId')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> images = data;
        if (images.isNotEmpty && !_chapterFirstPages.containsKey(chapterId)) {
          _chapterFirstPages[chapterId] = images[0]['img'];
        }
         return images.map((json) => ChapterPage.fromJson(json)).toList();
;
      }
      throw Exception('Failed to get manga chapters');
    } catch (e) {
      print('Error getting manga chapters: $e');
      throw Exception('Failed to get manga chapters');
    }
  }

  void clearMangaInfo() {
    _selectedMangaChapters = null;
    _currentChapters = null;
    notifyListeners();
  }

  Future<void> fetchChapterFirstPage(String chapterId) async {
    try {
      final response = await http.get(
        Uri.parse('$mangaBaseUrl/manga/mangahere/read?chapterId=$chapterId')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> images = data['images'] ?? [];
        if (images.isNotEmpty) {
          _chapterFirstPages[chapterId] = images[0]['img'];
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error getting chapter first page: $e');
    }
  }

  String? getNextChapterId() {
    if (_selectedMangaChapters == null || _currentChapterIndex == null) return null;
    if (_currentChapterIndex! < _selectedMangaChapters!.length - 1) {
      return _selectedMangaChapters![_currentChapterIndex! + 1]['id'];
    }
    return null;
  }

  String? getPreviousChapterId() {
    if (_selectedMangaChapters == null || _currentChapterIndex == null) return null;
    if (_currentChapterIndex! > 0) {
      return _selectedMangaChapters![_currentChapterIndex! - 1]['id'];
    }
    return null;
  }

  void setCurrentChapterIndex(String chapterId) {
    if (_selectedMangaChapters != null) {
      _currentChapterIndex = _selectedMangaChapters!.indexWhere((chapter) => chapter['id'] == chapterId);
      notifyListeners();
    }
  }
}



