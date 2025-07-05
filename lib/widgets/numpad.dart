// lib/screens/auth/pin_screen.dart

import 'package:flutter/material.dart';
import 'package:photosafepro/widgets/numpad_button.dart';

class Numpad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onBackspacePressed;

  const Numpad({
    super.key,
    required this.onNumberPressed,
    required this.onBackspacePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            NumpadButton(text: '1', onPressed: () => onNumberPressed('1')),
            NumpadButton(text: '2', onPressed: () => onNumberPressed('2')),
            NumpadButton(text: '3', onPressed: () => onNumberPressed('3')),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            NumpadButton(text: '4', onPressed: () => onNumberPressed('4')),
            NumpadButton(text: '5', onPressed: () => onNumberPressed('5')),
            NumpadButton(text: '6', onPressed: () => onNumberPressed('6')),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            NumpadButton(text: '7', onPressed: () => onNumberPressed('7')),
            NumpadButton(text: '8', onPressed: () => onNumberPressed('8')),
            NumpadButton(text: '9', onPressed: () => onNumberPressed('9')),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 70, height: 70), // Placeholder for alignment
            NumpadButton(text: '0', onPressed: () => onNumberPressed('0')),
            NumpadButton(
              icon: Icons.backspace_rounded,
              onPressed: onBackspacePressed,
            ),
          ],
        ),
      ],
    );
  }
}
