// lib/screens/gallery/vault_screen.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:photosafepro/models/photo.dart';
import '../../blocs/gallery/gallery_bloc.dart';
import '../../utils/encryption_helper.dart';

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  void _showDeleteConfirmationDialog(BuildContext context, Photo photo) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF16213e),
          title: const Text(
            'Delete Photo',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to permanently delete this photo from your vault?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: Color(0xFFe94560)),
              ),
              onPressed: () {
                context.read<GalleryBloc>().add(
                  GalleryPhotoDeleted(
                    photoId: photo.id!,
                    encryptedPath: photo.encryptedPath,
                  ),
                );
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndImportPhoto(BuildContext context) async {
    PermissionStatus status;
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      status = await Permission.photos.request();
    } else {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      final List<AssetEntity>? assets = await AssetPicker.pickAssets(
        context,
        pickerConfig: const AssetPickerConfig(
          maxAssets: 1,
          requestType: RequestType.image,
          themeColor: Color(0xFFe94560),
        ),
      );

      if (assets != null && assets.isNotEmpty) {
        final AssetEntity selectedAsset = assets.first;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Securing photo...')));
        context.read<GalleryBloc>().add(GalleryPhotoAdded(selectedAsset));
      }
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Photo permission is needed. Please enable it in settings.',
          ),
          action: SnackBarAction(label: 'Settings', onPressed: openAppSettings),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission to access photos was denied.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PhotoSafe-Pro Vault'),
        backgroundColor: const Color(0xFF1a1a2e),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickAndImportPhoto(context),
        backgroundColor: const Color(0xFFe94560),
        child: const Icon(Icons.add_photo_alternate_rounded),
      ),
      body: BlocConsumer<GalleryBloc, GalleryState>(
        listener: (context, state) {
          if (state is GalleryLoadFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
          }
        },
        builder: (context, state) {
          if (state is GalleryLoadInProgress || state is GalleryInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GalleryLoadSuccess) {
            if (state.photos.isEmpty) {
              return const Center(
                child: Text(
                  'Your vault is empty.\nTap the + button to add a photo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: state.photos.length,
              itemBuilder: (context, index) {
                final photo = state.photos[index];
                return GestureDetector(
                  onLongPress: () =>
                      _showDeleteConfirmationDialog(context, photo),
                  child: PhotoThumbnail(photo: photo),
                );
              },
            );
          }
          return const Center(child: Text('Something went wrong.'));
        },
      ),
    );
  }
}

class PhotoThumbnail extends StatefulWidget {
  final Photo photo;
  const PhotoThumbnail({super.key, required this.photo});

  @override
  State<PhotoThumbnail> createState() => _PhotoThumbnailState();
}

class _PhotoThumbnailState extends State<PhotoThumbnail> {
  Future<Uint8List>? _decryptionFuture;

  @override
  void initState() {
    super.initState();
    _decryptionFuture = _decryptPhoto();
  }

  // --- THIS DECRYPTION LOGIC IS NOW CORRECTED ---
  Future<Uint8List> _decryptPhoto() async {
    final encryptionHelper = EncryptionHelper();
    final file = File(widget.photo.encryptedPath);

    // Read the combined encrypted string from the file
    final encryptedString = await file.readAsString();

    // Decrypt the data using the new helper method
    final decryptedBytes = await encryptionHelper.decryptString(
      encryptedString,
    );

    return Uint8List.fromList(decryptedBytes);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: FutureBuilder<Uint8List>(
        future: _decryptionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Image.memory(snapshot.data!, fit: BoxFit.cover);
          }
          if (snapshot.hasError) {
            print("Decryption Error in FutureBuilder: ${snapshot.error}");
            return const Icon(Icons.error, color: Colors.red);
          }
          return Container(color: Colors.grey.shade800);
        },
      ),
    );
  }
}
