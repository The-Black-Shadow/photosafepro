part of 'gallery_bloc.dart';

sealed class GalleryState extends Equatable {
  const GalleryState();

  @override
  List<Object> get props => [];
}

/// The initial state when the gallery has not been loaded yet.
class GalleryInitial extends GalleryState {}

/// The state when the app is actively fetching photos from the database.
/// The UI should show a loading indicator, like a CircularProgressIndicator.
class GalleryLoadInProgress extends GalleryState {}

/// The state when the photos have been successfully loaded from the database.
/// It contains the list of photos to be displayed in the UI.
class GalleryLoadSuccess extends GalleryState {
  final List<Photo> photos;

  const GalleryLoadSuccess(this.photos);

  @override
  List<Object> get props => [photos];
}

/// The state when an error has occurred while trying to load the photos.
/// It contains an error message that can be shown to the user.
class GalleryLoadFailure extends GalleryState {
  final String error;

  const GalleryLoadFailure(this.error);

  @override
  List<Object> get props => [error];
}
