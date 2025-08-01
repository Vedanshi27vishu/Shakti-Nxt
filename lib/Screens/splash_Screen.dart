import 'package:flutter/material.dart';
import 'package:shakti/Screens/Start.dart';
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shakti/helpers/helper_functions.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller!, curve: Curves.easeIn)
      ..addListener(() {
        setState(() {});
      });

    _controller!.forward();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(seconds: 3), () {});
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => StartScreen()));
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder for responsive breakpoints
    return Scaffold(
      backgroundColor: Scolor.primary,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          // --- Set logo and font size by breakpoints ---
          double logoSize;
          double fontSize;
          double spacing;
          if (screenWidth < 600) {
            // Mobile
            logoSize = screenWidth * 0.55;  // e.g. 220px at 400px width
            fontSize = screenWidth * 0.10;
            spacing = screenHeight * 0.02;
          } else if (screenWidth < 1000) {
            // Tablet
            logoSize = 320;
            fontSize = 48;
            spacing = 30;
          } else {
            // Laptop/Desktop
            logoSize = 400;
            fontSize = 64;
            spacing = 38;
          }
          // ---------------------------------------------

          return FadeTransition(
            opacity: _animation!,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    height: logoSize,
                    width: logoSize,
                    child: Image.asset('assets/logo.png'),
                  ),
                  SizedBox(height: spacing),
                  // App Name
                  Text(
                    "Shakti-Nxt",
                    style: TextStyle(
                      color: Scolor.light,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
