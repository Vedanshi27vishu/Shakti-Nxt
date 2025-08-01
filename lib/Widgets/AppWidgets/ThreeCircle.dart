import 'package:flutter/material.dart';
import 'package:shakti/Utils/constants/colors.dart';

class ThreeCircle extends StatelessWidget {
  const ThreeCircle({
    super.key,
    required this.screenWidth,
  });

  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    // 👇 Responsive sizes based on device width (breakpoints)
    double circleSize;
    double spacing;
    if (screenWidth < 600) {
      // Mobile: size is percent of screen
      circleSize = screenWidth * 0.1;
      spacing = screenWidth * 0.02;
    } else if (screenWidth < 1000) {
      // Tablet: fixed circle size
      circleSize = 50;
      spacing = 12;
    } else {
      // Laptop/Desktop: slightly larger fixed size
      circleSize = 60;
      spacing = 16;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing),
          child: Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Scolor.secondry, width: 2),
              color: index == 0 ? Scolor.secondry : Colors.transparent,
            ),
            child: Center(
              child: index == 0
                  ? const Icon(Icons.check, color: Colors.white)
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Scolor.secondry,
                        fontWeight: FontWeight.bold,
                        fontSize: circleSize * 0.4, // Font scales with circle
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
