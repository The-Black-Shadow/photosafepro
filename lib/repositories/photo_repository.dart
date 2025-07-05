// lib/repositories/photo_repository.dart

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

  Future<void> importPhoto(AssetEntity assetEntity) async {
    final Uint8List? bytes = await assetEntity.originBytes;
    if (bytes == null) {
      throw Exception("Could not load image data.");
    }

    // Use the new helper method to get the combined IV:data string
    final encryptedString = await _encryptionHelper.encryptBytes(bytes);

    final appDir = await getApplicationDocumentsDirectory();
    final encryptedFileName = '${_uuid.v4()}.enc';
    final encryptedPath = p.join(appDir.path, encryptedFileName);
    final encryptedFile = File(encryptedPath);

    // Save the combined string to the file
    await encryptedFile.writeAsString(encryptedString);

    final newPhoto = Photo(
      encryptedPath: encryptedPath,
      originalId: assetEntity.id,
      createdAt: DateTime.now(),
    );
    await _dbHelper.insertPhoto(newPhoto);
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

  Future<void> deleteVaultPhoto(int id, String encryptedPath) async {
    await _dbHelper.deletePhoto(id);
    final file = File(encryptedPath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
