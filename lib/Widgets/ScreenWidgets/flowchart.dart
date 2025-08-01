  import 'package:flutter/material.dart';

Widget flowChartNode(String text, {bool isOval = false, Color color = Colors.amber}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: isOval ? BorderRadius.circular(50) : BorderRadius.circular(5),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget connector() {
    return Column(
      children: [
   Image.asset(
  "assets/arrow.png",
  width: 30,  // Adjust size as needed
  height: 30,
  fit: BoxFit.contain,
) ],
    );
  }
