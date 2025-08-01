import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shakti/Screens/Login.dart';
import 'package:shakti/Utils/constants/colors.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Scolor.primary,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400), // ✅ Centered & limited width
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                SizedBox(height: 120.h),

                // Logo
                CircleAvatar(
                  radius: 70.r,
                  backgroundColor: Colors.transparent,
                  backgroundImage: const AssetImage('assets/logo.png'),
                ),

                SizedBox(height: 20.h),

                // App Name
                Text(
                  "Shakti-Nxt",
                  style: TextStyle(
                    color: Scolor.light,
                    fontSize: 28.sp.clamp(20, 32),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8.h),

                // Tagline
                Text(
                  "Your AI-Powered Business Guide",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Scolor.secondry.withOpacity(0.8),
                    fontSize: 16.sp.clamp(12, 20),
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 40.h),

                // Buttons
                SizedBox(
                  width: double.infinity,
                  height: 50.h.clamp(45, 55),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Scolor.secondry,
                      foregroundColor: Scolor.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "Start Your Journey",
                      style: TextStyle(
                        fontSize: 16.sp.clamp(12, 20),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                SizedBox(
                  width: double.infinity,
                  height: 50.h.clamp(45, 55),
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Scolor.secondry,
                      side: BorderSide(color: Scolor.secondry),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "Learn More",
                      style: TextStyle(
                        fontSize: 16.sp.clamp(12, 20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 80.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
