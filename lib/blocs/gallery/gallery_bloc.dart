import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photosafepro/models/photo.dart';
import 'package:photosafepro/repositories/photo_repository.dart';

part 'gallery_event.dart';
part 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final PhotoRepository photoRepository;

  GalleryBloc({required this.photoRepository}) : super(GalleryInitial()) {
    on<GalleryStarted>(_onGalleryStarted);
    on<GalleryPhotoAdded>(_onGalleryPhotoAdded);
    on<GalleryPhotoDeleted>(_onGalleryPhotoDeleted);
  }

  Future<void> _onGalleryStarted(GalleryStarted event, Emitter<GalleryState> emit) async {
    emit(GalleryLoadInProgress());
    try {
      final photos = await photoRepository.getPhotos();
      emit(GalleryLoadSuccess(photos));
    } catch (e) {
      emit(GalleryLoadFailure(e.toString()));
    }
  }

  Future<void> _onGalleryPhotoAdded(GalleryPhotoAdded event, Emitter<GalleryState> emit) async {
    // The UI is likely showing a loading indicator while the user picks a photo.
    // We can go straight to processing.
    try {
      // Pass the asset from the event directly to the repository.
      await photoRepository.importPhoto(event.asset);
      // After importing, refresh the list of photos by triggering the GalleryStarted event.
      add(GalleryStarted());
    } catch (e) {
      emit(GalleryLoadFailure(e.toString()));
    }
  }

  Future<void> _onGalleryPhotoDeleted(GalleryPhotoDeleted event, Emitter<GalleryState> emit) async {
    try {
      await photoRepository.deleteVaultPhoto(event.photoId, event.encryptedPath);
      // After deleting, refresh the list of photos.
      add(GalleryStarted());
    } catch (e) {
      emit(GalleryLoadFailure(e.toString()));
    }
  }
}
