class Title {
  final String type;
  final String title;

  Title({required this.type, required this.title});

  factory Title.fromJson(Map<String, dynamic> json) {
    return Title(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
    );
  }
}

class Aired {
  final String? from;
  final String? to;
  final Map<String, dynamic>? prop;
  final String? string;

  Aired({this.from, this.to, this.prop, this.string});

  factory Aired.fromJson(Map<String, dynamic> json) {
    return Aired(
      from: json['from'],
      to: json['to'],
      prop: json['prop'],
      string: json['string'],
    );
  }
}

class Broadcast {
  final String? day;
  final String? time;
  final String? timezone;
  final String? string;

  Broadcast({this.day, this.time, this.timezone, this.string});

  factory Broadcast.fromJson(Map<String, dynamic> json) {
    return Broadcast(
      day: json['day'],
      time: json['time'],
      timezone: json['timezone'],
      string: json['string'],
    );
  }
}

class Producer {
  final int malId;
  final String type;
  final String name;
  final String url;

  Producer({
    required this.malId,
    required this.type,
    required this.name,
    required this.url,
  });

  factory Producer.fromJson(Map<String, dynamic> json) {
    return Producer(
      malId: json['mal_id'],
      type: json['type'],
      name: json['name'],
      url: json['url'],
    );
  }
}

class Studio {
  final int malId;
  final String type;
  final String name;
  final String url;

  Studio({
    required this.malId,
    required this.type,
    required this.name,
    required this.url,
  });

  factory Studio.fromJson(Map<String, dynamic> json) {
    return Studio(
      malId: json['mal_id'],
      type: json['type'],
      name: json['name'],
      url: json['url'],
    );
  }
}

class Genre {
  final int malId;
  final String name;
  final String url;
  final int count;

  Genre({
    required this.malId,
    required this.name,
    required this.url,
    required this.count,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      malId: json['mal_id'] ?? 0,
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Genre && runtimeType == other.runtimeType && malId == other.malId;

  @override
  int get hashCode => malId.hashCode;

  @override
  String toString() => 'Genre(malId: $malId, name: $name)';
}

class Theme {
  final int malId;
  final String type;
  final String name;
  final String url;

  Theme({
    required this.malId,
    required this.type,
    required this.name,
    required this.url,
  });

  factory Theme.fromJson(Map<String, dynamic> json) {
    return Theme(
      malId: json['mal_id'],
      type: json['type'],
      name: json['name'],
      url: json['url'],
    );
  }
}

class Demographic {
  final int malId;
  final String type;
  final String name;
  final String url;

  Demographic({
    required this.malId,
    required this.type,
    required this.name,
    required this.url,
  });

  factory Demographic.fromJson(Map<String, dynamic> json) {
    return Demographic(
      malId: json['mal_id'],
      type: json['type'],
      name: json['name'],
      url: json['url'],
    );
  }
}

class Relation {
  final String relation;
  final List<RelationEntry> entry;

  Relation({required this.relation, required this.entry});

  factory Relation.fromJson(Map<String, dynamic> json) {
    return Relation(
      relation: json['relation'],
      entry: (json['entry'] as List).map((e) => RelationEntry.fromJson(e)).toList(),
    );
  }
}

class RelationEntry {
  final int malId;
  final String type;
  final String name;
  final String url;

  RelationEntry({
    required this.malId,
    required this.type,
    required this.name,
    required this.url,
  });

  factory RelationEntry.fromJson(Map<String, dynamic> json) {
    return RelationEntry(
      malId: json['mal_id'],
      type: json['type'],
      name: json['name'],
      url: json['url'],
    );
  }
}

class Character {
  final String role;
  final Map<String, dynamic> character;
  final List<Map<String, dynamic>> voiceActors;

  Character({
    required this.role,
    required this.character,
    required this.voiceActors,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      role: json['role'],
      character: json['character'],
      voiceActors: List<Map<String, dynamic>>.from(json['voice_actors']),
    );
  }
}

class Staff {
  final Map<String, dynamic> person;
  final List<String> positions;

  Staff({required this.person, required this.positions});

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      person: json['person'],
      positions: List<String>.from(json['positions']),
    );
  }
}

class Review {
  final Map<String, dynamic> user;
  final String content;

  Review({required this.user, required this.content});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      user: json['user'],
      content: json['content'],
    );
  }
}

class Recommendation {
  final Map<String, dynamic> entry;
  final String url;
  final int votes;

  Recommendation({
    required this.entry,
    required this.url,
    required this.votes,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      entry: json['entry'],
      url: json['url'],
      votes: json['votes'],
    );
  }
}

class AnimeTheme {
  final List<String> openings;
  final List<String> endings;

  AnimeTheme({
    required this.openings,
    required this.endings,
  });

  factory AnimeTheme.fromJson(Map<String, dynamic> json) {
    return AnimeTheme(
      openings: List<String>.from(json['openings'] ?? []),
      endings: List<String>.from(json['endings'] ?? []),
    );
  }
}

class ExternalLink {
  final String name;
  final String url;

  ExternalLink({
    required this.name,
    required this.url,
  });

  factory ExternalLink.fromJson(Map<String, dynamic> json) {
    return ExternalLink(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class Trailer {
  final String? youtubeId;
  final String? url;
  final String? embedUrl;

  Trailer({
    this.youtubeId,
    this.url,
    this.embedUrl,
  });

  factory Trailer.fromJson(Map<String, dynamic> json) {
    return Trailer(
      youtubeId: json['youtube_id'],
      url: json['url'],
      embedUrl: json['embed_url'],
    );
  }
}

class VoiceActor {
  final String language;
  final Map<String, dynamic> person;

  VoiceActor({
    required this.language,
    required this.person,
  });

  factory VoiceActor.fromJson(Map<String, dynamic> json) {
    return VoiceActor(
      language: json['language'] ?? '',
      person: json['person'] ?? {},
    );
  }

} 