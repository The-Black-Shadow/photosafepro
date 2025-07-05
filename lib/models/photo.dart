class Photo {
  final int? id;
  final String encryptedPath; // Path to the encrypted file in our app's directory
  final String originalId;    // The ID of the original photo from the gallery (for deletion)
  final DateTime createdAt;

  Photo({
    this.id,
    required this.encryptedPath,
    required this.originalId,
    required this.createdAt,
  });

  // Method to convert a Photo object to a Map, for inserting into the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'encryptedPath': encryptedPath,
      'originalId': originalId,
      'createdAt': createdAt.toIso8601String(), // Store datetime as a string
    };
  }

  // Method to create a Photo object from a Map, for reading from the database.
  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'],
      encryptedPath: map['encryptedPath'],
      originalId: map['originalId'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}