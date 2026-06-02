import 'package:flutter/material.dart';

class AboutMeWidget extends StatelessWidget {
  final TextEditingController controller;

  const AboutMeWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 6,
      minLines: 4,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText: 'Tell me about you.',
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}