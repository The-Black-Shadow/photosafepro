import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photosafepro/blocs/auth/auth_bloc.dart';
import 'package:photosafepro/repositories/auth_repository.dart';
import 'package:photosafepro/screens/auth/auth_gate.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We create the repository here so we can provide it to the BLoC.
    final authRepository = AuthRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: authRepository)
            ..add(AuthAppStarted()), // Trigger the initial check
        ),
        // We will add other BLoCs like PremiumBloc and GalleryBloc here later
      ],
      child: MaterialApp(
        title: 'PhotoSafe-Pro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFFe94560),
          scaffoldBackgroundColor: const Color(0xFF1a1a2e),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthGate(),
      ),
    );
  }
}