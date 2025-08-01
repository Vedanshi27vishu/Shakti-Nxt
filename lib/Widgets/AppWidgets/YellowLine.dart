import 'package:flutter/material.dart';
import 'package:shakti/Utils/constants/colors.dart';

class Yellowline extends StatelessWidget {
  const Yellowline({
    super.key,
    required this.screenWidth,
  });

  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      width: screenWidth * 0.9,
      color: Scolor.secondry,
    );
  }
}
