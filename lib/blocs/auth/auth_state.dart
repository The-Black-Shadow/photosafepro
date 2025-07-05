part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

// Initial state, app is loading.
class AuthInitial extends AuthState {}

// User is successfully authenticated.
class AuthAuthenticated extends AuthState {}

// We now include a flag to tell the UI if biometrics are available.
class AuthUnauthenticated extends AuthState {
  final bool isBiometricAvailable;
  const AuthUnauthenticated({this.isBiometricAvailable = false});
  @override
  List<Object> get props => [isBiometricAvailable];
}

// User needs to set a PIN for the first time.
class AuthFirstTime extends AuthState {}

// An operation is in progress (e.g., verifying PIN).
class AuthInProgress extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  final bool isBiometricAvailable;
  const AuthFailure(this.message, {this.isBiometricAvailable = false});
  @override
  List<Object> get props => [message, isBiometricAvailable];
}
