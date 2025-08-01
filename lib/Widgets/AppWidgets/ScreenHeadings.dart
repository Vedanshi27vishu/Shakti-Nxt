import 'package:flutter/material.dart';

class ScreenHeadings extends StatelessWidget {
  final dynamic text;

  const ScreenHeadings({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final titleFontSize = screenWidth < 600 ? 18.0 : (screenWidth < 1000 ? 20.0 : 22.0);

    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: titleFontSize + 4, // e.g. 22, 24, 26
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
