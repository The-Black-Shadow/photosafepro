import 'package:photosafepro/models/photo.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton pattern to ensure only one instance of the database helper.
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database.
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'photosafepro.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create the 'photos' table when the database is first created.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        encryptedPath TEXT NOT NULL,
        originalId TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // --- CRUD Operations for Photos ---

  /// Inserts a new photo record into the database.
  Future<int> insertPhoto(Photo photo) async {
    final db = await database;
    // Use toMap() to convert the Photo object to a Map.
    return await db.insert('photos', photo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Retrieves all photos from the database, ordered by creation date.
  Future<List<Photo>> getAllPhotos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'photos',
      orderBy: 'createdAt DESC', // Show newest photos first
    );

    return List.generate(maps.length, (i) {
      return Photo.fromMap(maps[i]);
    });
  }

  /// Deletes a photo from the database by its ID.
  Future<int> deletePhoto(int id) async {
    final db = await database;
    return await db.delete(
      'photos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}