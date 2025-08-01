import 'package:flutter/material.dart';
import 'package:shakti/Screens/BottomNavBar.dart';
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shakti/helpers/helper_functions.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = THelperFunctions.screenWidth(context);

    return Scaffold(
      backgroundColor: Scolor.primary, // Dark background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            CircleAvatar(
              radius: screenWidth * 0.18,
              backgroundColor: Colors.transparent,
              backgroundImage: const AssetImage(
                  'assets/logo.png'), // Replace with your actual asset path
            ),

            const SizedBox(height: 10),

            // App Name
            const Text(
              "Shakti",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // Success Box
            Container(
              width: screenWidth * 0.85,
              padding: EdgeInsets.all(screenWidth * 0.08),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  // Checkmark Icon
                  CircleAvatar(
                    radius: screenWidth * 0.1,
                    backgroundColor: Scolor.secondry, // Yellow color
                    child: const Icon(
                      Icons.check,
                      size: 40,
                      color: Scolor.primary, // Dark blue icon
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Congratulations Text
                  const Text(
                    "Congratulations!",
                    style: TextStyle(
                      color: Color(0xFF0F1A3C), // Dark blue
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Success Message
                  const Text(
                    "You have registered Successfully",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  // OK Button
                  SizedBox(
                    width: screenWidth * 0.5,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BottomNavBarExample()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Scolor.secondry, // Yellow button
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "OK",
                        style: TextStyle(
                          color: Scolor.primary, // Dark blue text
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
