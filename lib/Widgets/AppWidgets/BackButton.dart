import 'package:flutter/material.dart';
import 'package:shakti/Utils/constants/colors.dart';

class BackButton extends StatelessWidget {
  final dynamic Screen;

  const BackButton({
    super.key,
    required this.Screen,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Scolor.primary,
      leading: InkWell(
        onTap: () {
          Navigator.pop(
              context, MaterialPageRoute(builder: (context) =>Screen));
        },
        child:
            Icon(color: Scolor.secondry, Icons.arrow_back),
      ),
    );
  }
}