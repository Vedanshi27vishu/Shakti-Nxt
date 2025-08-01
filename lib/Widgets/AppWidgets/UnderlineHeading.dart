  import 'package:flutter/material.dart';
import 'package:shakti/Utils/constants/colors.dart';

Widget buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Scolor.secondry, width: 1.5)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Scolor.secondry,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }