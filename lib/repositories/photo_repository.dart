import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../models/photo.dart';
import 'database_helper.dart';
import '../utils/encryption_helper.dart';

class PhotoRepository {
  final _dbHelper = DatabaseHelper();
  final _encryptionHelper = EncryptionHelper();
  final _uuid = const Uuid();

  Future<List<Photo>> getPhotos() async {
    return await _dbHelper.getAllPhotos();
  }

  Future<Photo> importPhoto(AssetEntity assetEntity) async {
    // 1. Get both full-res and thumbnail bytes
    final Uint8List? fullResBytes = await assetEntity.originBytes;
    // Get a small thumbnail (e.g., 200x200 pixels) for fast loading
    final Uint8List? thumbBytes = await assetEntity.thumbnailDataWithSize(
      const ThumbnailSize(200, 200),
    );

    if (fullResBytes == null || thumbBytes == null) {
      throw Exception("Could not load image data.");
    }

    // 2. Encrypt both sets of bytes
    final encryptedFullResString = await _encryptionHelper.encryptBytes(
      fullResBytes,
    );
    final encryptedThumbString = await _encryptionHelper.encryptBytes(
      thumbBytes,
    );

    // 3. Save both encrypted files
    final appDir = await getApplicationDocumentsDirectory();
    final uuid = _uuid.v4();

    // Save full-res file
    final fullResFileName = '$uuid.enc';
    final fullResPath = p.join(appDir.path, fullResFileName);
    await File(fullResPath).writeAsString(encryptedFullResString);

    // Save thumbnail file
    final thumbFileName = '${uuid}_thumb.enc';
    final thumbPath = p.join(appDir.path, thumbFileName);
    await File(thumbPath).writeAsString(encryptedThumbString);

    // 4. Create Photo object with both paths
    final newPhoto = Photo(
      encryptedPath: fullResPath,
      encryptedThumbnailPath: thumbPath, // Save new path
      originalId: assetEntity.id,
      createdAt: DateTime.now(),
    );
    final id = await _dbHelper.insertPhoto(newPhoto);

    return Photo(
      id: id,
      encryptedPath: newPhoto.encryptedPath,
      encryptedThumbnailPath: newPhoto.encryptedThumbnailPath,
      originalId: newPhoto.originalId,
      createdAt: newPhoto.createdAt,
    );
  }

  Future<void> deleteVaultPhoto(
    int id,
    String encryptedPath,
    String encryptedThumbnailPath,
  ) async {
    await _dbHelper.deletePhoto(id);
    // Delete both files
    await File(encryptedPath).delete();
    await File(encryptedThumbnailPath).delete();
  }

  Future<bool> deleteOriginalPhoto(String originalId) async {
    try {
      final result = await PhotoManager.editor.deleteWithIds([originalId]);
      return result.isNotEmpty;
    } catch (e) {
      print("Error deleting original photo: $e");
      return false;
    }
  }
}
