import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photosafepro/blocs/auth/auth_bloc.dart';
import 'package:photosafepro/widgets/numpad.dart';
import 'package:photosafepro/widgets/pin_dots.dart';

enum PinPurpose { set, login }

class PinScreen extends StatefulWidget {
  final PinPurpose purpose;
  final String? errorMessage;

  const PinScreen({super.key, required this.purpose, this.errorMessage});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _enteredPin = '';
  String? _pinToConfirm;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
  }

  void _onNumberPressed(String value) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += value;
      });
      if (_enteredPin.length == 4) {
        _submitPin();
      }
    }
  }

  void _onBackspacePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  void _submitPin() {
    if (widget.purpose == PinPurpose.login) {
      context.read<AuthBloc>().add(AuthPinEntered(_enteredPin));
      setState(() {
        _enteredPin = '';
      });
    } else {
      if (!_isConfirming) {
        setState(() {
          _pinToConfirm = _enteredPin;
          _enteredPin = '';
          _isConfirming = true;
        });
      } else {
        if (_enteredPin == _pinToConfirm) {
          context.read<AuthBloc>().add(AuthPinSet(_enteredPin));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("PINs do not match. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _enteredPin = '';
            _pinToConfirm = null;
            _isConfirming = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title;
    if (widget.purpose == PinPurpose.set) {
      title = _isConfirming ? 'Confirm Your PIN' : 'Create a Secure PIN';
    } else {
      title = 'Enter Your PIN';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Show fingerprint icon button if available for login
            if (widget.purpose == PinPurpose.login)
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  bool isBiometricAvailable = false;
                  if (state is AuthUnauthenticated) {
                    isBiometricAvailable = state.isBiometricAvailable;
                  } else if (state is AuthFailure) {
                    isBiometricAvailable = state.isBiometricAvailable;
                  }

                  if (isBiometricAvailable) {
                    return IconButton(
                      icon: const Icon(
                        Icons.fingerprint,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthBiometricRequested());
                      },
                    );
                  }
                  return const SizedBox(
                    height: 40,
                  ); // Placeholder to keep layout consistent
                },
              ),
            const SizedBox(height: 20),
            PinDots(enteredPinLength: _enteredPin.length),
            const SizedBox(height: 20),
            if (widget.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  widget.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
            const Spacer(),
            Numpad(
              onNumberPressed: _onNumberPressed,
              onBackspacePressed: _onBackspacePressed,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
