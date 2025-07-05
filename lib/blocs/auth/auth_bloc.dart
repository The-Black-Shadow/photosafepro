import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:photosafepro/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthAppStarted>(_onAppStarted);
    on<AuthPinSet>(_onPinSet);
    on<AuthPinEntered>(_onPinEntered);
    on<AuthBiometricRequested>(_onBiometricRequested); // Register new handler
    on<AuthLoggedOut>(_onLoggedOut);
  }

  Future<void> _onAppStarted(
    AuthAppStarted event,
    Emitter<AuthState> emit,
  ) async {
    final bool hasPin = await authRepository.hasPin();
    if (hasPin) {
      final bool isBiometricAvailable = await authRepository
          .isBiometricAvailable();
      emit(AuthUnauthenticated(isBiometricAvailable: isBiometricAvailable));
    } else {
      emit(AuthFirstTime());
    }
  }

  Future<void> _onPinSet(AuthPinSet event, Emitter<AuthState> emit) async {
    emit(AuthInProgress());
    await authRepository.setPin(event.pin);
    emit(AuthAuthenticated());
  }

  Future<void> _onPinEntered(
    AuthPinEntered event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthInProgress());
    final bool isValid = await authRepository.verifyPin(event.pin);
    if (isValid) {
      emit(AuthAuthenticated());
    } else {
      // Check biometric availability for failure state
      final bool isBiometricAvailable = await authRepository
          .isBiometricAvailable();
      // We emit AuthUnauthenticated again to signal the UI to re-enable input,
      // but we could also emit AuthFailure to show a specific error message.
      emit(
        AuthFailure(
          "Incorrect PIN. Please try again.",
          isBiometricAvailable: isBiometricAvailable,
        ),
      );
      // After showing failure, go back to the unauthenticated state
      await Future.delayed(const Duration(seconds: 2));
      emit(AuthUnauthenticated(isBiometricAvailable: isBiometricAvailable));
    }
  }

  // New handler for biometric requests
  Future<void> _onBiometricRequested(
    AuthBiometricRequested event,
    Emitter<AuthState> emit,
  ) async {
    final isAvailable = await authRepository.isBiometricAvailable();
    if (isAvailable) {
      final didAuthenticate = await authRepository.authenticateWithBiometrics();
      if (didAuthenticate) {
        emit(AuthAuthenticated());
      } else {
        // User cancelled or failed authentication, stay on the login screen
        emit(AuthUnauthenticated(isBiometricAvailable: isAvailable));
      }
    }
  }

  Future<void> _onLoggedOut(
    AuthLoggedOut event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthInProgress());
    await authRepository.deletePin(); // Or just emit AuthUnauthenticated
    final bool isBiometricAvailable = await authRepository
        .isBiometricAvailable();
    emit(AuthUnauthenticated(isBiometricAvailable: isBiometricAvailable));
  }
}
