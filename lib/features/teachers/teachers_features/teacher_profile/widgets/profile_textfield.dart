import 'package:flutter/material.dart';

class ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool readOnly;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final Color? color;

  const ProfileTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1000;

    final double fontSize = isMobile
        ? 15
        : isTablet
            ? 16
            : 17;

    final double iconSize = isMobile
        ? 22
        : 24;

    final double verticalPadding = isMobile
        ? 16
        : 18;

    return Padding(
      padding: EdgeInsets.only(
        bottom: isMobile ? 16 : 20,
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: TextStyle(
          fontSize: fontSize,
        ),
        decoration: InputDecoration(
          labelText: label,

          labelStyle: TextStyle(
            fontSize: fontSize,
            color: color,
          ),

          prefixIcon: Icon(
            icon,
            size: iconSize,
            color: color,
          ),

          filled: true,
          fillColor: Colors.white,

          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: verticalPadding,
          ),

          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: BorderSide(
              color:
                  color ?? Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}