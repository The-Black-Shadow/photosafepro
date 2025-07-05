class Photo {
  final int? id;
  final String encryptedPath;
  final String encryptedThumbnailPath;
  final String originalId;
  final DateTime createdAt;

  Photo({
    this.id,
    required this.encryptedPath,
    required this.encryptedThumbnailPath,
    required this.originalId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'encryptedPath': encryptedPath,
      'encryptedThumbnailPath': encryptedThumbnailPath,
      'originalId': originalId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'],
      encryptedPath: map['encryptedPath'],
      encryptedThumbnailPath: map['encryptedThumbnailPath'],
      originalId: map['originalId'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
