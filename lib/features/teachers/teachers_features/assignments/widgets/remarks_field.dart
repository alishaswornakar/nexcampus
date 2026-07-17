import 'package:flutter/material.dart';

class RemarksField extends StatelessWidget {
  final TextEditingController controller;

  const RemarksField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: "Remarks (Optional)",
        hintText:
            "Write remarks for the teacher...",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),
      ),
    );
  }
}