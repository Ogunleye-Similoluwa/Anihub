import 'dart:convert';
import 'dart:math';
import 'package:anihub/models/anime.dart';
import 'package:anihub/services/jikan_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchProvider with ChangeNotifier {
  final JikanService _jikanService = JikanService();
  final List<Anime> _searchResults = [];
  final List<Anime> _genreResults = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasNextPage = true;
  String _currentQuery = '';
  String _currentGenre = '';

  List<Anime> action = [];
  List<Anime> adventure = [];
  List<Anime> romance = [];
  List<Anime> sciFi = [];
  List<Anime> comedy = [];

  List<String> _genres = [
  'Action',
  'Adventure',
  'Avant Garde',
  'Award Winning',
  'Boys Love',
  'Comedy',
  'Drama',
  'Fantasy',
  'Girls Love',
  'Gourmet',
  'Horror',
  'Mystery',
  'Romance',
  'Sci-Fi',
  'Slice of Life',
  'Sports',
  'Supernatural',
  'Suspense',
  'Ecchi',
  'Erotica',
  'Hentai',
  'Adult Cast',
  'Anthropomorphic',
  'CGDCT',
  'Childcare',
  'Combat Sports',
  'Crossdressing',
  'Delinquents',
  'Detective',
  'Educational',
  'Gag Humor',
  'Gore',
  'Harem',
  'High Stakes Game',
  'Historical',
  'Idols (Female)',
  'Idols (Male)',
  'Isekai',
  'Iyashikei',
  'Love Polygon',
  'Magical Sex Shift',
  'Mahou Shoujo',
  'Martial Arts',
  'Mecha',
  'Medical',
  'Military',
  'Music',
  'Mythology',
  'Organized Crime',
  'Otaku Culture',
  'Parody',
  'Performing Arts',
  'Pets',
  'Psychological',
  'Racing',
  'Reincarnation',
  'Reverse Harem',
  'Love Status Quo',
  'Samurai',
  'School',
  'Showbiz',
  'Space',
  'Strategy Game',
  'Super Power',
  'Survival',
  'Team Sports',
  'Time Travel',
  'Vampire',
  'Video Game',
  'Visual Arts',
  'Workplace',
  'Urban Fantasy',
  'Villainess',
  'Josei',
  'Kids',
  'Seinen',
  'Shoujo',
  'Shounen'
];

  final List<String> _formats = [
    'TV',
    'Movie',
    'OVA',
    'Special',
    'ONA',
    'Music',
  ];

  final List<String> _seasons = [
    'Winter',
    'Spring',
    'Summer',
    'Fall',
  ];

  final Set<String> _selectedFormats = {};
  final Set<String> _selectedSeasons = {};
  int? _selectedYear;

  final Map<String, List<Anime>> _genreLists = {};

  final Map<String, int> _genreIds = {
  'action': 1,
  'adventure': 2,
  'avant_garde': 5,
  'award_winning': 46,
  'boys_love': 28,
  'comedy': 4,
  'drama': 8,
  'fantasy': 10,
  'girls_love': 26,
  'gourmet': 47,
  'horror': 14,
  'mystery': 7,
  'romance': 22,
  'sci-fi': 24,
  'slice_of_life': 36,
  'sports': 30,
  'supernatural': 37,
  'suspense': 41,
  'ecchi': 9,
  'erotica': 49,
  'hentai': 12,
  'adult_cast': 50,
  'anthropomorphic': 51,
  'cgdct': 52,
  'childcare': 53,
  'combat_sports': 54,
  'crossdressing': 81,
  'delinquents': 55,
  'detective': 39,
  'educational': 56,
  'gag_humor': 57,
  'gore': 58,
  'harem': 35,
  'high_stakes_game': 59,
  'historical': 13,
  'idols_female': 60,
  'idols_male': 61,
  'isekai': 62,
  'iyashikei': 63,
  'love_polygon': 64,
  'magical_sex_shift': 65,
  'mahou_shoujo': 66,
  'martial_arts': 17,
  'mecha': 18,
  'medical': 67,
  'military': 38,
  'music': 19,
  'mythology': 6,
  'organized_crime': 68,
  'otaku_culture': 69,
  'parody': 20,
  'performing_arts': 70,
  'pets': 71,
  'psychological': 40,
  'racing': 3,
  'reincarnation': 72,
  'reverse_harem': 73,
  'love_status_quo': 74,
  'samurai': 21,
  'school': 23,
  'showbiz': 75,
  'space': 29,
  'strategy_game': 11,
  'super_power': 31,
  'survival': 76,
  'team_sports': 77,
  'time_travel': 78,
  'vampire': 32,
  'video_game': 79,
  'visual_arts': 80,
  'workplace': 48,
  'urban_fantasy': 82,
  'villainess': 83,
  'josei': 43,
  'kids': 15,
  'seinen': 42,
  'shoujo': 25,
  'shounen': 27
};
  List<String> get gneres => _genres;
  List<Anime> get searchResults => [..._searchResults];
  List<Anime> get genreResults => [..._genreResults];
  bool get isLoading => _isLoading;
  bool get hasNextPage => _hasNextPage;
  List<String> get formats => _formats;
  List<String> get seasons => _seasons;
  Set<String> get selectedFormats => _selectedFormats;
  Set<String> get selectedSeasons => _selectedSeasons;
  int? get selectedYear => _selectedYear;

  Future<void> searchAnime(String query, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _searchResults.clear();
      _hasNextPage = true;
    }

    if (!_hasNextPage && !refresh) return;

    try {
      _isLoading = true;
      _currentQuery = query;

      
      notifyListeners();

      var url = Uri.parse(
          'https://api.jikan.moe/v4/anime?q=$query&page=$_currentPage&sfw=false');
      
      if (_selectedFormats.isNotEmpty) {
        url = url.replace(queryParameters: {
          ...url.queryParameters,
          'type': _selectedFormats.join(','),
        });
      }
      
      if (_selectedSeasons.isNotEmpty) {
        url = url.replace(queryParameters: {
          ...url.queryParameters,
          'season': _selectedSeasons.join(','),
        });
      }
      
      if (_selectedYear != null) {
        url = url.replace(queryParameters: {
          ...url.queryParameters,
          'year': _selectedYear.toString(),
        });
      }

      

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final pagination = jsonResponse['pagination'];
        _hasNextPage = pagination['has_next_page'] ?? false;

        final List<dynamic> animeList = jsonResponse['data'];
        for (var animeData in animeList) {
          final anime = Anime.fromJson(animeData);
          _searchResults.add(anime);
        }

        _currentPage++;
      }
    } catch (error) {
      print('Error searching anime: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchByGenre(String genre, {
    bool refresh = false, 
    int? limit,
    bool shuffle = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _genreResults.clear();
      _genreLists[genre.toLowerCase()]?.clear();
      _hasNextPage = true;
    }

    if (!_hasNextPage && !refresh) return;

    try {
      _isLoading = true;
      _currentGenre = genre;
      notifyListeners();

      final genreId = _genreIds[genre.toLowerCase()] ?? 1;

      
      final pageToFetch = shuffle ? Random().nextInt(60) + 1 : _currentPage;

      print(pageToFetch);
      var url = Uri.parse(
          'https://api.jikan.moe/v4/anime?genres=$genreId&page=$pageToFetch&order_by=popularity');

      if (limit != null) {
        url = url.replace(queryParameters: {
          ...url.queryParameters,
          'limit': limit.toString(),
        });
      }

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final pagination = jsonResponse['pagination'];
        _hasNextPage = pagination['has_next_page'] ?? false;

        final List<dynamic> animeList = jsonResponse['data'];
        
        // Only shuffle if requested
        final processedList = shuffle ? (List.from(animeList)..shuffle()) : animeList;
        
        _genreLists.putIfAbsent(genre.toLowerCase(), () => []);

        for (var animeData in processedList) {
          final anime = Anime.fromJson(animeData);
          _genreLists[genre.toLowerCase()]?.add(anime);
          _genreResults.add(anime);
        }

        _currentPage++;
      }
    } catch (error) {
      print('Error searching by genre: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!_isLoading) {
      if (_currentGenre.isNotEmpty) {
        await searchByGenre(_currentGenre);
      } else if (_currentQuery.isNotEmpty) {
        await searchAnime(_currentQuery);
      }
    }
  }

  Future<void> refresh() async {
    if (_currentGenre.isNotEmpty) {
      await searchByGenre(_currentGenre, refresh: true);
    } else if (_currentQuery.isNotEmpty) {
      await searchAnime(_currentQuery, refresh: true);
    }
  }

  Future<List<String>> fetchGenres() async {
    try {
      final url = Uri.parse('https://api.jikan.moe/v4/genres/anime');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> genreList = jsonResponse['data'];
        _genres = genreList.map((g) => g['name'] as String).toList();
        notifyListeners();
      }
    } catch (error) {
      print('Error fetching genres: $error');
    }
    return _genres;
  }

  void clearResults() {
    _searchResults.clear();
    _genreResults.clear();
    _genreLists.clear();
    _currentPage = 1;
    _hasNextPage = true;
    _currentQuery = '';
    _currentGenre = '';
    notifyListeners();
  }

  Anime getSearchById(int id) {
    return _searchResults.firstWhere(
      (element) => element.malId == id,
      orElse: () => Anime.empty(),
    );
  }

  Anime getGneraById(int id) {
    return _genreResults.firstWhere(
      (element) => element.malId == id,
      orElse: () => Anime.empty(),
    );
  }

  void toggleFormat(String format) {
    if (_selectedFormats.contains(format)) {
      _selectedFormats.remove(format);
    } else {
      _selectedFormats.add(format);
    }
    notifyListeners();
  }

  void toggleSeason(String season) {
    if (_selectedSeasons.contains(season)) {
      _selectedSeasons.remove(season);
    } else {
      _selectedSeasons.add(season);
    }
    notifyListeners();
  }

  void setYear(int? year) {
    _selectedYear = year;
    notifyListeners();
  }

  void clearFilters() {
    _selectedFormats.clear();
    _selectedSeasons.clear();
    _selectedYear = null;
    notifyListeners();
  }

  List<Anime> getAnimeByGenre(String genre) {
    return _genreLists[genre.toLowerCase()] ?? [];
  }
}
