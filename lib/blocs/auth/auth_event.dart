part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

// Event to check the auth status when the app starts.
class AuthAppStarted extends AuthEvent {}

// Event triggered when a user sets their PIN for the first time.
class AuthPinSet extends AuthEvent {
  final String pin;
  const AuthPinSet(this.pin);

  @override
  List<Object> get props => [pin];
}

// Event triggered when a user enters their PIN to log in.
class AuthPinEntered extends AuthEvent {
  final String pin;
  const AuthPinEntered(this.pin);

  @override
  List<Object> get props => [pin];
}

// New event to trigger biometric authentication
class AuthBiometricRequested extends AuthEvent {}

// Event to log the user out.
class AuthLoggedOut extends AuthEvent {}