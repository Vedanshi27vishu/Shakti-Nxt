import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shakti/Screens/BottomNavBar.dart';
import 'package:shakti/Screens/Profile.dart';
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shakti/Widgets/AppWidgets/Continue.dart';
import 'package:shakti/Widgets/AppWidgets/InputField.dart';
import 'package:shakti/Widgets/AppWidgets/Subheading.dart';
import 'package:shakti/Widgets/AppWidgets/communitywidget/authhelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isLoading = false;

  final String loginUrl = "http://65.2.82.85:5000/api/auth/login";

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Email": email,
          "Password": password,
        }),
      );

      final responseData = jsonDecode(response.body);
      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200 && responseData['token'] != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", responseData['token']);
        await AuthHelper.saveLoginData(responseData);
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BottomNavBarExample()),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? "Login failed")),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Scolor.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Scolor.secondry),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      // =============================
      // MAIN RESPONSIVE LAYOUT CHANGE
      // =============================
      body: Center(
        // <--- (1) Wrap content in Center
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // You may define custom breakpoints as per your design
              double width;
              if (constraints.maxWidth < 600) {
                // Mobile: use full width with padding
                width = double.infinity;
              } else if (constraints.maxWidth < 1000) {
                // Tablet: medium box
                width = 400;
              } else {
                // Desktop/Laptop: slightly larger, but still centered
                width = 600;
              }

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                width: width,
                // This box is always centered because of the Center above
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 30.h),
                    CircleAvatar(
                      radius: 70.r,
                      backgroundColor: Colors.transparent,
                      backgroundImage: const AssetImage('assets/logo.png'),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "Shakti-Nxt",
                      style: TextStyle(
                        color: Scolor.light,
                        fontSize: 28.sp.clamp(20, 32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Log in",
                        style: TextStyle(
                          color: Scolor.light,
                          fontSize: 24.sp.clamp(18, 28),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileScreen()),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            text: "Need a Shakti-Nxt account? ",
                            style: TextStyle(color: Scolor.light),
                            children: [
                              TextSpan(
                                text: "Create an account",
                                style: TextStyle(
                                  color: Scolor.secondry,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // =============================
                    // CONTENT BOX, CENTERED
                    // =============================
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Scolor.secondry),
                        borderRadius: BorderRadius.circular(7.r),
                      ),
                      child: Column(
                        children: [
                          InputField(
                            controller: emailController,
                            label: "Email-Id",
                          ),
                          SizedBox(height: 20.h),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: buildSubSection("Password"),
                          ),
                          TextField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            style: const TextStyle(color: Scolor.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Scolor.primary,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Scolor.secondry, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Scolor.white, width: 2.5),
                              ),
                              hintText: "Enter Password",
                              hintStyle: TextStyle(
                                  color: Scolor.white.withOpacity(0.5)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 30.h),
                          isLoading
                              ? const CircularProgressIndicator(
                                  color: Scolor.secondry)
                              : ContinueButton(
                                  screenHeight: 60, // no need to use .h here
                                  screenWidth: 200, // no need to use .h here
                                  text: "Log in",
                                  onPressed: loginUser,
                                ),
                          SizedBox(height: 20.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                " ",
                                style: TextStyle(
                                  color: Scolor.secondry,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Forgot password?",
                                style: TextStyle(
                                  color: Scolor.secondry,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // =============================
                    // HERE you can add more content
                    // =============================
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
