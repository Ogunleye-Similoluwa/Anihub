class Episode {
  final String id;
  final int number;
  final String? title;
  final String? description;
  final String? image;
  final String? videoUrl;

  Episode({
    required this.id,
    required this.number,
    this.title,
    this.description,
    this.image,
    this.videoUrl,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] ?? '',
      number: json['number'] ?? 0,
      title: json['title'],
      description: json['description'],
      image: json['image'],
      videoUrl: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'title': title,
      'description': description,
      'image': image,
      'videoUrl': videoUrl,
    };
  }
}
