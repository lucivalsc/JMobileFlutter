import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:connect_force_app/app/common/styles/app_styles.dart';

class TextFieldDate extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final VoidCallback? clearSearch;
  final double? height;
  const TextFieldDate({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.clearSearch,
    this.height = 45,
  });

  @override
  Widget build(BuildContext context) {
    AppStyles appStyles = AppStyles();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 2),
        SizedBox(
          height: height,
          child: TextField(
            controller: controller,
            readOnly: true,
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
            onTap: () => showDatePicker(
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: appStyles.primaryColor, // header background color
                      onPrimary: Colors.white, // header text color
                      onSurface: appStyles.primaryColor, // body text color
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: appStyles.primaryColor, // button text color
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(3999),
            ).then(
              (DateTime? value) {
                if (value != null) {
                  final String date = DateFormat('dd/MM/yyyy').format(value);
                  controller.text = date;
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
