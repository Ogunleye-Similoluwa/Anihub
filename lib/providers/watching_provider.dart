import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class WatchingProvider with ChangeNotifier {
  List<WatchingAnime> _watchingList = [];
  final SharedPreferences _prefs;

  WatchingProvider(this._prefs) {
    _loadWatchingList();
  }

  List<WatchingAnime> get watchingList => _watchingList;

  Future<void> _loadWatchingList() async {
    final jsonString = _prefs.getString('watching_list');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _watchingList = jsonList.map((json) => WatchingAnime.fromJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveWatchingList() async {
    final jsonString = json.encode(_watchingList.map((anime) => anime.toJson()).toList());
    await _prefs.setString('watching_list', jsonString);
  }

  void addToWatching(WatchingAnime anime) {
    if (!_watchingList.any((element) => element.id == anime.id)) {
      _watchingList.add(anime);
      _saveWatchingList();
      notifyListeners();
    }
  }

  void updateLastWatchedEpisode(int animeId, int episodeNumber) {
    final index = _watchingList.indexWhere((anime) => anime.id == animeId);
    if (index != -1) {
      _watchingList[index] = _watchingList[index].copyWith(
        lastEpisode: episodeNumber,
        lastWatched: DateTime.now(),
      );
      _saveWatchingList();
      notifyListeners();
    }
  }

  void removeFromWatching(int animeId) {
    _watchingList.removeWhere((anime) => anime.id == animeId);
    _saveWatchingList();
    notifyListeners();
  }

  int? getLastWatchedEpisode(int animeId) {
    final anime = _watchingList.firstWhere(
      (anime) => anime.id == animeId,
      orElse: () => WatchingAnime(id: animeId, title: '', imageUrl: ''),
    );
    return anime.lastEpisode;
  }
}

class WatchingAnime {
  final int id;
  final String title;
  final String imageUrl;
  final int? lastEpisode;
  final DateTime? lastWatched;

  WatchingAnime({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.lastEpisode,
    this.lastWatched,
  });

  WatchingAnime copyWith({
    int? lastEpisode,
    DateTime? lastWatched,
  }) {
    return WatchingAnime(
      id: id,
      title: title,
      imageUrl: imageUrl,
      lastEpisode: lastEpisode ?? this.lastEpisode,
      lastWatched: lastWatched ?? this.lastWatched,
    );
  }

  factory WatchingAnime.fromJson(Map<String, dynamic> json) {
    return WatchingAnime(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      lastEpisode: json['lastEpisode'],
      lastWatched: json['lastWatched'] != null 
          ? DateTime.parse(json['lastWatched'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'lastEpisode': lastEpisode,
      'lastWatched': lastWatched?.toIso8601String(),
    };
  }
} 