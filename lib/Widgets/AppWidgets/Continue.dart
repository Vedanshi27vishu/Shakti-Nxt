import 'package:flutter/material.dart';
import 'package:shakti/Utils/constants/colors.dart';

class ContinueButton extends StatelessWidget {
  const ContinueButton({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.text,
    required this.onPressed,
  });

  final double screenHeight;
  final double screenWidth;
  final dynamic text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // Define responsive height and fontSize based on screenWidth breakpoints
    double buttonHeight;
    double fontSize;

    if (screenWidth < 600) {
      // Mobile
      buttonHeight = screenHeight * 0.6;
      fontSize = screenWidth * 0.09;
    } else if (screenWidth < 1000) {
      // Tablet
      buttonHeight = 65;
      fontSize = 25;
    } else {
      // Desktop / Laptop
      buttonHeight = 70;
      fontSize = 25;
    }

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Scolor.secondry,
          foregroundColor: Scolor.primary,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
