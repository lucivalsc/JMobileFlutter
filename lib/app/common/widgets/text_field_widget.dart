import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? clearSearch;
  final TextEditingController? controller;
  final Function(String)? onChanged;

  const TextFieldWidget({
    super.key,
    required this.label,
    this.icon,
    this.clearSearch,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        hintText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixIcon: clearSearch != null
            ? IconButton(onPressed: clearSearch, icon: const Icon(Icons.clear))
            : null,
      ),
      style: const TextStyle(color: Colors.black),
    );
  }
}
