import 'package:anihub/models/anime.dart';

import 'jikan_models.dart';

class Manga {
  final int malId;
  final String url;
  final Map<String, ImageSet> images;
  final bool approved;
  final List<Title> titles;
  final String title;
  final String? titleEnglish;
  final String? titleJapanese;
  final List<String> titleSynonyms;
  final String type;
  final int? chapters;
  final int? volumes;
  final String status;
  final bool publishing;
  final Published published;
  final double score;
  final int scoredBy;
  final int rank;
  final int popularity;
  final int members;
  final int favorites;
  final String synopsis;
  final String? background;
  final List<Author> authors;
  final List<Serialization> serializations;
  final List<Genre> genres;
  final List<ExplicitGenre> explicitGenres;
  final List<Genre> themes;
  final List<Genre> demographics;
  final List<Relation> relations;
  final List<ExternalLink> external;

  Manga({
    required this.malId,
    required this.url,
    required this.images,
    required this.approved,
    required this.titles,
    required this.title,
    this.titleEnglish,
    this.titleJapanese,
    required this.titleSynonyms,
    required this.type,
    this.chapters,
    this.volumes,
    required this.status,
    required this.publishing,
    required this.published,
    required this.score,
    required this.scoredBy,
    required this.rank,
    required this.popularity,
    required this.members,
    required this.favorites,
    required this.synopsis,
    this.background,
    required this.authors,
    required this.serializations,
    required this.genres,
    required this.explicitGenres,
    required this.themes,
    required this.demographics,
    required this.relations,
    required this.external,
  });

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

  factory Manga.fromJson(Map<String, dynamic> json) {
    return Manga(
      malId: json['mal_id'] ?? 0,
      url: json['url'] ?? '',
      images: {
        'jpg': ImageSet.fromJson(json['images']['jpg'] ?? {}),
        'webp': ImageSet.fromJson(json['images']['webp'] ?? {}),
      },
      approved: json['approved'] ?? false,
      titles: (json['titles'] as List? ?? []).map((t) => Title.fromJson(t)).toList(),
      title: json['title'] ?? '',
      titleEnglish: json['title_english'],
      titleJapanese: json['title_japanese'],
      titleSynonyms: List<String>.from(json['title_synonyms'] ?? []),
      type: json['type'] ?? '',
      chapters: json['chapters'],
      volumes: json['volumes'],
      status: json['status'] ?? '',
      publishing: json['publishing'] ?? false,
      published: Published.fromJson(json['published'] ?? {}),
      score: (json['score'] ?? 0).toDouble(),
      scoredBy: json['scored_by'] ?? 0,
      rank: json['rank'] ?? 0,
      popularity: json['popularity'] ?? 0,
      members: json['members'] ?? 0,
      favorites: json['favorites'] ?? 0,
      synopsis: json['synopsis'] ?? '',
      background: json['background'],
      authors: (json['authors'] as List? ?? []).map((a) => Author.fromJson(a)).toList(),
      serializations: (json['serializations'] as List? ?? []).map((s) => Serialization.fromJson(s)).toList(),
      genres: (json['genres'] as List? ?? []).map((g) => Genre.fromJson(g)).toList(),
      explicitGenres: (json['explicit_genres'] as List? ?? []).map((e) => ExplicitGenre.fromJson(e)).toList(),
      themes: (json['themes'] as List? ?? []).map((t) => Genre.fromJson(t)).toList(),
      demographics: (json['demographics'] as List? ?? []).map((d) => Genre.fromJson(d)).toList(),
      relations: (json['relations'] as List? ?? []).map((r) => Relation.fromJson(r)).toList(),
      external: (json['external'] as List? ?? []).map((e) => ExternalLink.fromJson(e)).toList(),
    );
  }

  String get imageUrl => getImage(format: 'jpg', size: 'medium');
  String get thumbnailUrl => getImage(format: 'jpg', size: 'small');
  String get largeImageUrl => getImage(format: 'jpg', size: 'large');
  
  String get webpImageUrl => getImage(format: 'webp', size: 'medium');
  String get webpThumbnailUrl => getImage(format: 'webp', size: 'small');
  String get webpLargeImageUrl => getImage(format: 'webp', size: 'large');
}

class Serialization {
  final int malId;
  final String type;
  final String name;
  final String url;

  Serialization({
    required this.malId,
    required this.type,
    required this.name,
    required this.url,
  });

  factory Serialization.fromJson(Map<String, dynamic> json) {
    return Serialization(
      malId: json['mal_id'] ?? 0,
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class Published {
  final String? from;
  final String? to;
  final PublishedProp prop;
  final String? string;

  Published({
    this.from,
    this.to,
    required this.prop,
    this.string,
  });

  factory Published.fromJson(Map<String, dynamic> json) {
    return Published(
      from: json['from'],
      to: json['to'],
      prop: PublishedProp.fromJson(json['prop'] ?? {}),
      string: json['string'],
    );
  }
}

class PublishedProp {
  final DateProp from;
  final DateProp to;

  PublishedProp({
    required this.from,
    required this.to,
  });

  factory PublishedProp.fromJson(Map<String, dynamic> json) {
    return PublishedProp(
      from: DateProp.fromJson(json['from'] ?? {}),
      to: DateProp.fromJson(json['to'] ?? {}),
    );
  }
}

class DateProp {
  final int? day;
  final int? month;
  final int? year;

  DateProp({
    this.day,
    this.month,
    this.year,
  });

  factory DateProp.fromJson(Map<String, dynamic> json) {
    return DateProp(
      day: json['day'],
      month: json['month'],
      year: json['year'],
    );
  }
}

class Author {
  final int malId;
  final String type;
  final String name;
  final String url;

  Author({
    required this.malId,
    required this.type,
    required this.name,
    required this.url,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      malId: json['mal_id'] ?? 0,
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

// class Genre {
//   final int malId;
//   final String type;
//   final String name;
//   final String url;

//   Genre({
//     required this.malId,
//     required this.type,
//     required this.name,
//     required this.url,
//   });

//   factory Genre.fromJson(Map<String, dynamic> json) {
//     return Genre(
//       malId: json['mal_id'] ?? 0,
//       type: json['type'] ?? '',
//       name: json['name'] ?? '',
//       url: json['url'] ?? '',
//     );
  // }
// }