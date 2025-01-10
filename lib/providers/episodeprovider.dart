import 'package:anihub/models/episode.dart';
import 'package:flutter/material.dart';
import 'package:anihub/services/consumet_service.dart';

class EpisodeProvider with ChangeNotifier {
  final ConsumetService _consumetService = ConsumetService();
  List<Episode> _episodes = [];
  bool _isLoading = false;
  String? _error;
  Episode? _currentEpisode;

  List<Episode> get episodes => _episodes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Episode? get currentEpisode => _currentEpisode;

  void setEpisodes(List<Episode> episodes) {
    _episodes = episodes.reversed.toList(); // Latest first
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> fetchEpisodes(String animeId) async {
    try {
      setLoading(true);
      setError(null);

      final searchResults = await _consumetService.searchAnime(animeId);
      if (searchResults.isEmpty) {
        throw Exception('Anime not found');
      }

      final consumetAnimeId = searchResults[0]['id'];
      final animeInfo = await _consumetService.getAnimeInfo(consumetAnimeId);
      final episodesList = animeInfo['episodes'] as List;
      
      setEpisodes(
        episodesList.map((e) => Episode.fromJson(e)).toList()
      );

    } catch (e) {
      setError(e.toString());
      print('Error fetching episodes: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> playEpisode(Episode episode) async {
    try {
      setLoading(true);

      final streamingData = await _consumetService.getStreamingLinks(episode.id);
      final sources = streamingData['sources'] as List;
      
      if (sources.isEmpty) {
        throw Exception('No streaming sources available');
      }

      final videoUrl = _consumetService.getBestQualityUrl(sources);
      _currentEpisode = Episode(
        id: episode.id,
        number: episode.number,
        title: episode.title,
        videoUrl: videoUrl,
        image: episode.image,
        description: episode.description,
      );

      notifyListeners();
    } catch (e) {
      setError(e.toString());
      print('Error playing episode: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  void clearEpisodes() {
    _episodes = [];
    _currentEpisode = null;
    setError(null);
  }

  List<Episode> getLatestEpisodes(int count) {
    return _episodes.take(count).toList();
  }

  Episode? getNextEpisode() {
    if (_currentEpisode == null) return null;
    final currentIndex = _episodes.indexWhere((e) => e.id == _currentEpisode!.id);
    if (currentIndex == -1 || currentIndex == _episodes.length - 1) return null;
    return _episodes[currentIndex + 1];
  }

  Episode? getPreviousEpisode() {
    if (_currentEpisode == null) return null;
    final currentIndex = _episodes.indexWhere((e) => e.id == _currentEpisode!.id);
    if (currentIndex <= 0) return null;
    return _episodes[currentIndex - 1];
  }
}
