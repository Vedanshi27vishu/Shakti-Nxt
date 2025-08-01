import 'package:flutter/material.dart';
import 'package:shakti/Utils/constants/colors.dart';

class InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const InputField({
    super.key,
    required this.label,
    required this.controller, 
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Scolor.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            style: const TextStyle(color: Scolor.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Scolor.primary, // Background color
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Scolor.secondry, width: 1), // Default border
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Scolor.white, width: 3.5), // Focused border
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2), // Error border
              ),
              hintText: "Enter $label",
              hintStyle: TextStyle(color: Scolor.white.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }
}
