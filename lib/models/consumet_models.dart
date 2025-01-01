class ConsumetAnime {
  final String id;
  final String title;
  final String image;
  final List<Episode> episodes;

  ConsumetAnime({
    required this.id,
    required this.title,
    required this.image,
    required this.episodes,
  });

  factory ConsumetAnime.fromJson(Map<String, dynamic> json) {
    return ConsumetAnime(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      episodes: (json['episodes'] as List?)
          ?.map((e) => Episode.fromJson(e))
          .toList() ?? [],
    );
  }
}

class Episode {
  final String id;
  final String number;
  final String title;

  Episode({
    required this.id,
    required this.number,
    required this.title,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] ?? '',
      number: json['number']?.toString() ?? '',
      title: json['title'] ?? '',
    );
  }
} 