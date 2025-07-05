// lib/screens/auth/pin_screen.dart

import 'package:flutter/material.dart';

class NumpadButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback onPressed;

  const NumpadButton({
    super.key,
    this.text,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          side: const BorderSide(color: Color(0xFFe94560), width: 2),
        ),
        child: text != null
            ? Text(
                text!,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(icon, size: 28),
      ),
    );
  }
}
