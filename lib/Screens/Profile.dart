import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shakti/Screens/OtpScreen.dart';
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shakti/Widgets/AppWidgets/Continue.dart';
import 'package:shakti/Widgets/AppWidgets/InputField.dart';
import 'package:shakti/Widgets/AppWidgets/ThreeCircle.dart';
import 'package:shakti/helpers/helper_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController languageController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController qualificationController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> submitForm() async {
    // 🛑 Validation
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        languageController.text.trim().isEmpty ||
        experienceController.text.trim().isEmpty ||
        qualificationController.text.trim().isEmpty) {
      showError("Please fill all the fields.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    final Map<String, dynamic> requestBody = {
      "personalDetails": {
        "Full_Name": nameController.text.trim(),
        "Email": emailController.text.trim(),
        "Preferred_Languages": languageController.text.trim(),
      },
      "professionalDetails": {
        "Business_Experience":
            int.tryParse(experienceController.text.trim()) ?? 0,
        "Educational_Qualifications": qualificationController.text.trim(),
      },
      "passwordDetails": {
        "Password": passwordController.text.trim(),
        "Create_Password": passwordController.text.trim()
      }
    };

    try {
      final response = await http.post(
        Uri.parse('http://65.2.82.85:5000/api/signup/signup1'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sessionId = data['sessionId'];
        if (sessionId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("sessionId", sessionId);

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OTPScreen(
                      sessionId: sessionId,
                    )),
          );
        } else {
          showError("Session ID not found in response.");
        }
      } else {
        showError("Failed to submit. Server returned: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showError("Something went wrong. Please try again.");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // You can keep this or use MediaQuery directly; both fine.
    double screenWidth = THelperFunctions.screenWidth(context);
    double screenHeight = THelperFunctions.screenHeight(context);

    return Scaffold(
      backgroundColor: Scolor.primary,
      appBar: AppBar(
        backgroundColor: Scolor.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Scolor.secondry),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // ================
      // RESPONSIVE BODY
      // ================
      body: Center(
        // 1️⃣ Center everything
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double maxWidth;
              if (constraints.maxWidth < 600) {
                // Mobile: natural (full width with padding)
                maxWidth = double.infinity;
              } else if (constraints.maxWidth < 1000) {
                // Tablet
                maxWidth = 450;
              } else {
                // Desktop/laptop
                maxWidth = 500;
              }
              return Container(
                // Always centered because of Center above, width is limited
                width: maxWidth,
                padding: EdgeInsets.symmetric(
                  horizontal:
                      maxWidth == double.infinity ? screenWidth * 0.08 : 36,
                  vertical: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ThreeCircle(screenWidth: screenWidth),
                    SizedBox(height: screenHeight * 0.03),
                    const Text(
                      "Create Your Profile",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Personal Information
                    buildSectionHeader("Personal Information"),
                    InputField(label: "Full Name", controller: nameController),
                    InputField(label: "Email", controller: emailController),
                    InputField(
                        label: "Preferred Language",
                        controller: languageController),

                    buildSectionHeader("Password"),
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
                          borderSide:
                              const BorderSide(color: Scolor.white, width: 3.5),
                        ),
                        hintText: "Enter Password",
                        hintStyle:
                            TextStyle(color: Scolor.white.withOpacity(0.5)),
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

                    SizedBox(height: screenHeight * 0.02),

                    // Professional Information
                    buildSectionHeader("Professional Details"),
                    InputField(
                        label: "Business Experience",
                        controller: experienceController),
                    InputField(
                        label: "Educational Qualifications",
                        controller: qualificationController),

                    SizedBox(height: screenHeight * 0.04),

                    ContinueButton(
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                      text: isLoading ? "Loading..." : "Continue",
                      onPressed: isLoading ? () {} : submitForm,
                    ),
                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
