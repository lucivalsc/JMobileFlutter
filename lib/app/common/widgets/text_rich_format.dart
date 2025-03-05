import 'package:flutter/material.dart';

class TextRichFormat extends StatelessWidget {
  final String? title;
  final String? subtitle;
  const TextRichFormat({
    super.key,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        children: [
          TextSpan(
            text: subtitle,
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
