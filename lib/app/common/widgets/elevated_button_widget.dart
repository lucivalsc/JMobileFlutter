import 'package:flutter/material.dart';

class ElevatedButtonWidget extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final TextStyle textStyle;

  const ElevatedButtonWidget({
    super.key,
    required this.label,
    required this.onPressed,
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        // padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Text(label),
    );
  }
}
