import 'jikan_models.dart';

class Anime {
  final int malId;
  final String url;
  final Map<String, ImageSet> images;
  final String trailer;
  final bool approved;
  final List<Title> titles;
  final String title;
  final String titleEnglish;
  final String titleJapanese;
  final List<String> titleSynonyms;
  final String type;
  final String source;
  final int episodes;
  final String status;
  final bool airing;
  final Aired aired;
  final String duration;
  final String rating;
  final double score;
  final int scoredBy;
  final int rank;
  final int popularity;
  final int members;
  final int favorites;
  late final String synopsis;
  final String background;
  final String season;
  final int year;
  final Broadcast broadcast;
  final List<Producer> producers;
  final List<Studio> studios;
  final List<Genre> genres;
  final List<Theme> themes;
  final List<Demographic> demographics;
  final List<Relation> relations;
  final List<Character> characters;
  final List<Staff> staff;
  final List<Review> reviews;
  final List<Recommendation> recommendations;
  final List<Licensor> licensors;
  final List<ExplicitGenre> explicitGenres;
  final AnimeTheme? theme;
  final List<ExternalLink> external;
  final List<ExternalLink> streaming;

  Anime({
    required this.malId,
    required this.url,
    required this.images,
    required this.trailer,
    required this.approved,
    required this.titles,
    required this.title,
    required this.titleEnglish,
    required this.titleJapanese,
    required this.titleSynonyms,
    required this.type,
    required this.source,
    required this.episodes,
    required this.status,
    required this.airing,
    required this.aired,
    required this.duration,
    required this.rating,
    required this.score,
    required this.scoredBy,
    required this.rank,
    required this.popularity,
    required this.members,
    required this.favorites,
    required this.synopsis,
    required this.background,
    required this.season,
    required this.year,
    required this.broadcast,
    required this.producers,
    required this.studios,
    required this.genres,
    required this.themes,
    required this.demographics,
    required this.relations,
    required this.characters,
    required this.staff,
    required this.reviews,
    required this.recommendations,
    required this.licensors,
    required this.explicitGenres,
    this.theme,
    required this.external,
    required this.streaming,
  });

  // ... existing code ...

factory Anime.fromJson(Map<String, dynamic> json) {
  return Anime(
    malId: json['mal_id'] ?? 0,
    url: json['url'] ?? '',
    images: {
      'jpg': ImageSet.fromJson(json['images']['jpg'] ?? {}),
      'webp': ImageSet.fromJson(json['images']['webp'] ?? {}),
    },
    trailer: json['trailer'] != null ? json['trailer']['url'] ?? '' : '',
    approved: json['approved'] ?? false,
    titles: (json['titles'] as List? ?? []).map((t) => Title.fromJson(t)).toList(),
    title: json['title'] ?? '',
    titleEnglish: json['title_english'] ?? '',
    titleJapanese: json['title_japanese'] ?? '',
    titleSynonyms: List<String>.from(json['title_synonyms'] ?? []),
    type: json['type'] ?? '',
    source: json['source'] ?? '',
    episodes: json['episodes'] ?? 0,
    status: json['status'] ?? '',
    airing: json['airing'] ?? false,
    aired: Aired.fromJson(json['aired'] ?? {}),
    duration: json['duration'] ?? '',
    rating: json['rating'] ?? '',
    score: (json['score'] ?? 0).toDouble(),
    scoredBy: json['scored_by'] ?? 0,
    rank: json['rank'] ?? 0,
    popularity: json['popularity'] ?? 0,
    members: json['members'] ?? 0,
    favorites: json['favorites'] ?? 0,
    synopsis: json['synopsis'] ?? '',
    background: json['background'] ?? '',
    season: json['season'] ?? '',
    year: json['year'] ?? 0,
    broadcast: Broadcast.fromJson(json['broadcast'] ?? {}),
    producers: (json['producers'] as List? ?? []).map((p) => Producer.fromJson(p)).toList(),
    studios: (json['studios'] as List? ?? []).map((s) => Studio.fromJson(s)).toList(),
    genres: (json['genres'] as List? ?? []).map((g) => Genre.fromJson(g)).toList(),
    themes: (json['themes'] as List? ?? []).map((t) => Theme.fromJson(t)).toList(),
    demographics: (json['demographics'] as List? ?? []).map((d) => Demographic.fromJson(d)).toList(),
    relations: (json['relations'] as List? ?? []).map((r) => Relation.fromJson(r)).toList(),
    characters: (json['characters'] as List? ?? []).map((c) => Character.fromJson(c)).toList(),
    staff: (json['staff'] as List? ?? []).map((s) => Staff.fromJson(s)).toList(),
    reviews: (json['reviews'] as List? ?? []).map((r) => Review.fromJson(r)).toList(),
    recommendations: (json['recommendations'] as List? ?? []).map((r) => Recommendation.fromJson(r)).toList(),
    licensors: (json['licensors'] as List? ?? []).map((l) => Licensor.fromJson(l)).toList(),
    explicitGenres: (json['explicit_genres'] as List? ?? []).map((e) => ExplicitGenre.fromJson(e)).toList(),
    theme: json['theme'] != null ? AnimeTheme.fromJson(json['theme']) : null,
    external: (json['external'] as List? ?? []).map((e) => ExternalLink.fromJson(e)).toList(),
    streaming: (json['streaming'] as List? ?? []).map((e) => ExternalLink.fromJson(e)).toList(),
  );
}

// Also update the empty factory to include the new fields
factory Anime.empty() {
  return Anime(
    malId: 0,
    url: '',
    images: {
      'jpg': ImageSet(imageUrl: '', smallImageUrl: '', largeImageUrl: ''),
      'webp': ImageSet(imageUrl: '', smallImageUrl: '', largeImageUrl: ''),
    },
    trailer: "",
    approved: false,
    titles: [],
    title: '',
    titleEnglish: '',
    titleJapanese: '',
    titleSynonyms: [],
    type: '',
    source: '',
    episodes: 0,
    status: 'Unknown',
    airing: false,
    aired: Aired(),
    duration: '',
    rating: '',
    score: 0.0,
    scoredBy: 0,
    rank: 0,
    popularity: 0,
    members: 0,
    favorites: 0,
    synopsis: '',
    background: '',
    season: '',
    year: 0,
    broadcast: Broadcast(),
    producers: [],
    studios: [],
    genres: [],
    themes: [],
    demographics: [],
    relations: [],
    characters: [],
    staff: [],
    reviews: [],
    recommendations: [],
    licensors: [],
    explicitGenres: [],
    theme: null,
    external: [],
    streaming: [],
  );
}

  String getImage({String format = 'jpg', String size = 'large'}) {
    final imageSet = images[format];
    if (imageSet == null) return '';

    switch (size) {
      case 'small':
        return imageSet.smallImageUrl;
      case 'medium':
        return imageSet.imageUrl;
      case 'large':
        return imageSet.largeImageUrl;
      default:
        return '';
    }
  }

  bool get hasValidImage {
    final url = getImage();
    return url.isNotEmpty && url != 'null';
  }

  String get imageUrl => getImage(format: 'jpg', size: 'medium');
  String get thumbnailUrl => getImage(format: 'jpg', size: 'small');
  String get largeImageUrl => getImage(format: 'jpg', size: 'large');
  
  String get webpImageUrl => getImage(format: 'webp', size: 'medium');
  String get webpThumbnailUrl => getImage(format: 'webp', size: 'small');
  String get webpLargeImageUrl => getImage(format: 'webp', size: 'large');

  String get broadcastString => broadcast.string ?? 'Unknown';
  List<String> get genreNames => genres.map((g) => g.name).toList();
  List<String> get studioNames => studios.map((s) => s.name).toList();
  String get airingStatus => status;
  int get episodeCount => episodes;
  String get synopsisText => synopsis;
  String get animeType => type;
  
  List<Map<String, dynamic>> get recommendationImages {
    return recommendations.map((r) => {
      'image': r.entry['images']['jpg']['large_image_url'] ?? '',
      'title': r.entry['title'] ?? '',
    }).toList();
  }

  List<Map<String, dynamic>> get mainCharacters {
    return characters.map((c) => {
      'name': c.character['name'] ?? '',
      'image': c.character['images']['jpg']['image_url'] ?? '',
      'role': c.role,
    }).toList();
  }
}

class Licensor {
  final int malId;
  final String name;
  final String url;

  Licensor({required this.malId, required this.name, required this.url});

  factory Licensor.fromJson(Map<String, dynamic> json) {
    return Licensor(
      malId: json['mal_id'],
      name: json['name'],
      url: json['url'],
    );
  }
}

class ExplicitGenre {
  final int malId;
  final String name;
  final String url;

  ExplicitGenre({required this.malId, required this.name, required this.url});

  factory ExplicitGenre.fromJson(Map<String, dynamic> json) {
    return ExplicitGenre(
      malId: json['mal_id'],
      name: json['name'],
      url: json['url'],
    );
  }
}

class ImageSet {
  final String imageUrl;
  final String smallImageUrl;
  final String largeImageUrl;

  ImageSet({
    required this.imageUrl,
    required this.smallImageUrl,
    required this.largeImageUrl,
  });

  factory ImageSet.fromJson(Map<String, dynamic> json) {
    return ImageSet(
      imageUrl: json['image_url'] ?? '',
      smallImageUrl: json['small_image_url'] ?? '',
      largeImageUrl: json['large_image_url'] ?? '',
    );
  }
}
