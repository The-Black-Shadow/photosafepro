import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:photosafepro/models/photo.dart';
import 'package:photosafepro/repositories/photo_repository.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

part 'gallery_event.dart';
part 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final PhotoRepository photoRepository;

  GalleryBloc({required this.photoRepository}) : super(GalleryInitial()) {
    on<GalleryStarted>(_onGalleryStarted);
    on<GalleryPhotoAdded>(_onGalleryPhotoAdded);
    on<GalleryPhotoDeleted>(_onGalleryPhotoDeleted);
    on<GalleryDeleteOriginalConfirmed>(_onDeleteOriginalConfirmed);
  }

  Future<void> _onGalleryStarted(
    GalleryStarted event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryLoadInProgress());
    try {
      final photos = await photoRepository.getPhotos();
      emit(GalleryLoadSuccess(photos));
    } catch (e) {
      emit(GalleryLoadFailure(e.toString()));
    }
  }

  Future<void> _onGalleryPhotoAdded(
    GalleryPhotoAdded event,
    Emitter<GalleryState> emit,
  ) async {
    try {
      final newPhoto = await photoRepository.importPhoto(event.asset);

      // --- THIS IS THE CORRECTED LOGIC ---
      // 1. First, tell the UI to show the delete prompt. The listener will catch this.
      emit(GalleryShowDeletePrompt(newPhoto));

      // 2. Then, trigger the event to refresh the gallery grid in the background.
      add(GalleryStarted());
    } catch (e) {
      emit(GalleryLoadFailure(e.toString()));
    }
  }

  Future<void> _onGalleryPhotoDeleted(
    GalleryPhotoDeleted event,
    Emitter<GalleryState> emit,
  ) async {
    try {
      // Pass all required info to the repository
      await photoRepository.deleteVaultPhoto(
        event.photoId,
        event.encryptedPath,
        event.encryptedThumbnailPath,
      );
      add(GalleryStarted());
    } catch (e) {
      emit(GalleryLoadFailure(e.toString()));
    }
  }

  Future<void> _onDeleteOriginalConfirmed(
    GalleryDeleteOriginalConfirmed event,
    Emitter<GalleryState> emit,
  ) async {
    try {
      await photoRepository.deleteOriginalPhoto(event.originalId);
      // Optionally, you could emit a success message state here
    } catch (e) {
      emit(GalleryLoadFailure(e.toString()));
    }
  }
}
