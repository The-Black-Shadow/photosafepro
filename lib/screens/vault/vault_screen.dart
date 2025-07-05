// lib/screens/gallery/vault_screen.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:photosafepro/models/photo.dart';
import '../../blocs/gallery/gallery_bloc.dart';
import '../../utils/encryption_helper.dart';

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  // --- NEW DIALOG FOR DELETING THE ORIGINAL ---
  void _showDeleteOriginalConfirmationDialog(
    BuildContext context,
    Photo newPhoto,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must choose an option
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF16213e),
          title: const Text(
            'Photo Secured',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Delete the original photo from your public gallery?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Keep',
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
                // Tell the BLoC to perform the deletion
                context.read<GalleryBloc>().add(
                  GalleryDeleteOriginalConfirmed(newPhoto.originalId),
                );
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Original photo deleted.')),
                );
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
      body: BlocListener<GalleryBloc, GalleryState>(
        listener: (context, state) {
          if (state is GalleryLoadFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
          }
          // --- LISTEN FOR THE NEW STATE ---
          if (state is GalleryShowDeletePrompt) {
            _showDeleteOriginalConfirmationDialog(context, state.newPhoto);
          }
        },
        child: BlocBuilder<GalleryBloc, GalleryState>(
          builder: (context, state) {
            if (state is GalleryLoadInProgress || state is GalleryInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is GalleryLoadSuccess) {
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
                        _showDeleteFromVaultDialog(context, photo),
                    // --- FIX #2: ADD A UNIQUE KEY ---
                    child: PhotoThumbnail(
                      key: ValueKey(photo.id), // This fixes the deletion bug
                      photo: photo,
                    ),
                  );
                },
              );
            }
            return const Center(child: Text('Something went wrong.'));
          },
        ),
      ),
    );
  }
}

// Renamed for clarity
void _showDeleteFromVaultDialog(BuildContext context, Photo photo) {
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
              // --- UPDATE EVENT WITH NEW PARAMETER ---
              context.read<GalleryBloc>().add(
                GalleryPhotoDeleted(
                  photoId: photo.id!,
                  encryptedPath: photo.encryptedPath,
                  encryptedThumbnailPath: photo.encryptedThumbnailPath,
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

// PhotoThumbnail widget remains the same...
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

  Future<Uint8List> _decryptPhoto() async {
    final encryptionHelper = EncryptionHelper();
    // --- FIX #1: DECRYPT THE THUMBNAIL, NOT THE FULL IMAGE ---
    final file = File(widget.photo.encryptedThumbnailPath);
    final encryptedString = await file.readAsString();
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
