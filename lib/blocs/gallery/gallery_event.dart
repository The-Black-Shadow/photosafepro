part of 'gallery_bloc.dart';

sealed class GalleryEvent extends Equatable {
  const GalleryEvent();

  @override
  List<Object> get props => [];
}

/// Event to load all photos from the database when the vault is opened.
class GalleryStarted extends GalleryEvent {}

/// Event to add a new photo to the vault.
/// It now carries the AssetEntity selected by the user from the gallery.
class GalleryPhotoAdded extends GalleryEvent {
  final AssetEntity asset;

  const GalleryPhotoAdded(this.asset);

  @override
  List<Object> get props => [asset];
}

/// Event to delete a photo from the vault.
class GalleryPhotoDeleted extends GalleryEvent {
  final int photoId;
  final String encryptedPath;

  const GalleryPhotoDeleted({required this.photoId, required this.encryptedPath});

  @override
  List<Object> get props => [photoId, encryptedPath];
}