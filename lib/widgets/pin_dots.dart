// lib/screens/auth/pin_screen.dart

import 'package:flutter/material.dart';

class PinDots extends StatelessWidget {
  final int enteredPinLength;
  const PinDots({super.key, required this.enteredPinLength});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: index < enteredPinLength
                ? const Color(0xFFe94560)
                : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFe94560), width: 2),
          ),
        );
      }),
    );
  }
}
