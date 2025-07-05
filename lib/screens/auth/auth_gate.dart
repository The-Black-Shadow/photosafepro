import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photosafepro/blocs/auth/auth_bloc.dart';
import 'package:photosafepro/blocs/gallery/gallery_bloc.dart';
import 'package:photosafepro/screens/auth/pin_screen.dart';
import 'package:photosafepro/screens/vault/vault_screen.dart';
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial) {
          // Show a loading spinner while the app checks for a PIN
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (state is AuthFirstTime) {
          // If no PIN is set, show the setup screen
          return const PinScreen(purpose: PinPurpose.set);
        }
        if (state is AuthUnauthenticated || state is AuthFailure) {
          // If a PIN exists, show the login screen
          // Also handles the failure state to allow re-entry
          return PinScreen(
            purpose: PinPurpose.login,
            errorMessage: state is AuthFailure ? state.message : null,
          );
        }
        if (state is AuthAuthenticated) {
          // When authenticated, trigger the gallery to load and show the VaultScreen.
          context.read<GalleryBloc>().add(GalleryStarted());
          return VaultScreen();
        }
        // Show a loading indicator for any in-progress states
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}