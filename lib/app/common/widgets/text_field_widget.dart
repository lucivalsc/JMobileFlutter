import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? clearSearch;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final bool? obscureText;
  final int? maxLines;
  final double? height;
  final TextInputType? keyboardType;

  const TextFieldWidget({
    super.key,
    required this.label,
    this.icon,
    this.clearSearch,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.maxLines = 1,
    this.height = 45,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 2),
        SizedBox(
          height: height,
          child: TextFormField(
            controller: controller,
            onChanged: onChanged,
            obscureText: obscureText!,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              hintText: label,
              prefixIcon: icon != null ? Icon(icon) : null,
              suffixIcon:
                  clearSearch != null ? IconButton(onPressed: clearSearch, icon: const Icon(Icons.clear)) : null,
            ),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
