import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shakti/Screens/AI.dart';
import 'package:shakti/Screens/ExpertsInsights.dart';
import 'package:shakti/Screens/FinancialRecords.dart';
import 'package:shakti/Screens/YourBudget.dart';
import 'package:shakti/Screens/YourFeedback.dart';
import 'package:shakti/Screens/YourProgress.dart';
import 'package:shakti/Screens/links.dart';
import 'package:shakti/Screens/usershaktidetails.dart';
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shakti/Utils/constants/sizes.dart';
import 'package:shakti/helpers/helper_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarScreen extends StatefulWidget {
  const AvatarScreen({super.key});

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  List<Map<String, dynamic>> allProgressData = [];
  List<Map<String, dynamic>> allBudgetData = [];
  String suggestion1 = "";
  String suggestion2 = "";
  String suggestion3 = "";
  String suggestionbudget1 = "";
  String suggestionbudget2 = "";
  String suggestionbudget3 = "";
  bool isLoadingProgress = true;
  bool isLoadingBudget = true;

  @override
  void initState() {
    super.initState();
    fetchProgressData();
    fetchbudgetprogress();
  }

  bool isLoading = false;
  String? error;

  Future<void> fetchProgressData() async {
    if (!mounted) return;
    setState(() {
      isLoadingProgress = true;
      error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) throw Exception('No authentication token found');

      final url = Uri.parse('http://65.2.82.85:5000/api/progress/insights');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> progressMap = data;

        List<Map<String, dynamic>> parsedProgress = [];
        progressMap.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            parsedProgress.add({
              "title": value["title"] ?? "",
              "description": value["description"] ?? "",
            });
          }
        });

        if (!mounted) return;

        setState(() {
          allProgressData = parsedProgress;
          suggestion1 = parsedProgress.isNotEmpty
              ? parsedProgress[0]['description']!
              : "No data";
          suggestion2 = parsedProgress.length > 1
              ? parsedProgress[1]['description']!
              : "No data";
          suggestion3 = parsedProgress.length > 2
              ? parsedProgress[2]['description']!
              : "No data";
          isLoadingProgress = false;
        });
      } else {
        throw Exception('Failed to fetch progress data: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Error fetching progress data: $e';
        suggestion1 = "Error loading data";
        suggestion2 = "Error loading data";
        suggestion3 = "Error loading data";
        isLoadingProgress = false;
      });
    }
  }

  Future<void> fetchbudgetprogress() async {
    if (!mounted) return;
    setState(() {
      isLoadingBudget = true;
      error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) throw Exception('No authentication token found');

      final url = Uri.parse('http://65.2.82.85:5000/api/budget/insights');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> budgetMap = data;

        List<Map<String, dynamic>> parsedbudget = [];
        budgetMap.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            parsedbudget.add({
              "title": value["title"] ?? "",
              "description": value["description"] ?? "",
            });
          }
        });

        if (!mounted) return;

        setState(() {
          allBudgetData = parsedbudget;
          suggestionbudget1 = parsedbudget.isNotEmpty
              ? parsedbudget[0]['description']!
              : "No data";
          suggestionbudget2 = parsedbudget.length > 1
              ? parsedbudget[1]['description']!
              : "No data";
          suggestionbudget3 = parsedbudget.length > 2
              ? parsedbudget[2]['description']!
              : "No data";
          isLoadingBudget = false;
        });
      } else {
        throw Exception('Failed to fetch budget data: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Error fetching budget data: $e';
        suggestionbudget1 = "Error loading data";
        suggestionbudget2 = "Error loading data";
        suggestionbudget3 = "Error loading data";
        isLoadingBudget = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using LayoutBuilder and Center for responsive width control
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Scolor.primary,
        elevation: 0,
        // Responsive: LayoutBuilder ka istemaal
        title: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double screenHeight = THelperFunctions.screenHeight(context);

            // ⬇️ AppBar ki size/app icon responsive:
            double titleFontSize;
            double avatarRadius;
            double horizontalPad;

            if (screenWidth < 600) {
              // Mobile
              titleFontSize = screenHeight * 0.03;
              avatarRadius = screenHeight * 0.025;
              horizontalPad = 0;
            } else if (screenWidth < 1000) {
              // Tablet
              titleFontSize = 24;
              avatarRadius = 30;
              horizontalPad = 10;
            } else {
              // Desktop/Laptop
              titleFontSize = 28;
              avatarRadius = 35;
              horizontalPad = 24;
            }

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPad),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hi, Entrepreneur!',
                    style: TextStyle(
                      color: Scolor.white,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: Colors.white,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ShaktiProfileScreen()),
                        );
                      },
                      child: Icon(Icons.person,
                          color: Scolor.primary, size: avatarRadius + 4),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double maxWidth;
              if (constraints.maxWidth < 600) {
                maxWidth = double.infinity;
              } else if (constraints.maxWidth < 1000) {
                maxWidth = 600;
              } else {
                maxWidth = 700;
              }

              // Calculate height and width scaling factors based on maxWidth for better scaling inside suggestions
              double scalingHeight = THelperFunctions.screenHeight(context);
              double scalingWidth = maxWidth == double.infinity
                  ? THelperFunctions.screenWidth(context)
                  : maxWidth;

              return Container(
                width: maxWidth,
                padding: const EdgeInsets.all(ESizes.md),
                child: Column(
                  children: [
                    // Top content section with Image and "I am here to help you..."
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          SizedBox(
                            height: scalingHeight * 0.3,
                            width: maxWidth * 0.6,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BusinessAdvicePage()),
                                );
                              },
                              child: Image.asset(
                                  "assets/3D Business GIF by L3S Research Center.gif",
                                  fit: BoxFit.cover),
                            ),
                          ),
                          SizedBox(height: scalingHeight * 0.05),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BusinessAdvicePage()),
                              );
                            },
                            child: const Text(
                              'I am here to help you...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ESizes.fontSizeLg,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: scalingHeight * 0.05),
                          SizedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CircularContainer(
                                  image: "assets/images/video.png",
                                  label: "Video",
                                  screen: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FinancialInsightsScreen()),
                                    );
                                  },
                                ),
                                CircularContainer(
                                  image: "assets/images/doc.png",
                                  label: "Document",
                                  screen: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FinancialRecordsScreen()),
                                    );
                                  },
                                ),
                                CircularContainer(
                                  image: "assets/images/flowchart.png",
                                  label: "Process",
                                  screen: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FinancialLinkInsights()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: scalingHeight * 0.02),
                        ],
                      ),
                    ),

                    // Suggestions Section
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "What I would suggest is..",
                            style: TextStyle(
                                fontSize: ESizes.fontSizeLg,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: scalingHeight * 0.02),
                          // Horizontal Scroll with suggestion cards
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                SuggestionContainer(
                                  height: scalingHeight,
                                  width: maxWidth,
                                  image: "assets/Progress.png",
                                  heading: "Your Progress",
                                  suggestion1: suggestion1,
                                  suggestion2: suggestion2,
                                  suggestion3: suggestion3,
                                  suggestionbudget1: "",
                                  suggestionbudget2: "",
                                  suggestionbudget3: "",
                                  isLoading: isLoadingProgress,
                                  screen: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            YourProgressScreen(
                                                progressData: allProgressData),
                                      ),
                                    );
                                  },
                                ),
                                SuggestionContainer(
                                  height: scalingHeight,
                                  width: maxWidth,
                                  image: "assets/images/newwallet.png",
                                  heading: "Your Budget",
                                  suggestion1: "",
                                  suggestion2: "",
                                  suggestion3: "",
                                  suggestionbudget1: suggestionbudget1,
                                  suggestionbudget2: suggestionbudget2,
                                  suggestionbudget3: suggestionbudget3,
                                  isLoading: isLoadingBudget,
                                  screen: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => YourBudgetScreen(
                                            budgetData: allBudgetData),
                                      ),
                                    );
                                  },
                                ),
                                SuggestionContainer(
                                  height: scalingHeight,
                                  width: maxWidth,
                                  image: "assets/images/Group (3).png",
                                  heading: "Your Feedback",
                                  suggestion1: "Ask for reviews",
                                  suggestion2: "Improve quality",
                                  suggestion3: "Engage with clients",
                                  suggestionbudget1: "",
                                  suggestionbudget2: "",
                                  suggestionbudget3: "",
                                  isLoading: false,
                                  screen: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              YourFeedbackScreen()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
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

class SuggestionContainer extends StatelessWidget {
  final String image;
  final String heading;
  final String suggestion1;
  final String suggestionbudget1;
  final String suggestionbudget2;
  final String suggestionbudget3;
  final String suggestion2;
  final String suggestion3;
  final double height;
  final double width;
  final bool isLoading;
  final VoidCallback screen;

  const SuggestionContainer({
    required this.image,
    required this.heading,
    required this.suggestion1,
    required this.suggestion2,
    required this.suggestion3,
    required this.suggestionbudget1,
    required this.suggestionbudget2,
    required this.suggestionbudget3,
    required this.height,
    required this.width,
    this.isLoading = false,
    super.key,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    // Use breakpoint based width for container to prevent it from being too wide on large screens
    double containerWidth;
    if (width < 600) {
      containerWidth = width * 0.85;
    } else if (width < 1000) {
      containerWidth = 400;
    } else {
      containerWidth = 450;
    }

    return SizedBox(
      width: containerWidth,
      child: GestureDetector(
        onTap: screen,
        child: Container(
          margin: const EdgeInsets.only(right: 10),
          height: height * 0.28,
          decoration: BoxDecoration(
              color: Scolor.primary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Scolor.secondry, width: 1)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 30,
                        width: 30,
                        child: Image.asset(image),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          heading,
                          style: const TextStyle(
                              color: Scolor.secondry,
                              fontSize: ESizes.fontSizeMd,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Scolor.secondry,
                        strokeWidth: 2,
                      ),
                    )
                  else ...[
                    // Show budget suggestions for "Your Budget" heading
                    if (heading == "Your Budget") ...[
                      Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "1. $suggestionbudget1",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "2. $suggestionbudget2",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "3. $suggestionbudget3",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ])
                    ] else ...[
                      // Show progress or feedback suggestions for other headings
                      Text(
                        "1. $suggestion1",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "2. $suggestion2",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "3. $suggestion3",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CircularContainer extends StatelessWidget {
  final String image;
  final String label;
  final VoidCallback screen;

  const CircularContainer({
    required this.image,
    required this.label,
    super.key,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = THelperFunctions.screenWidth(context);
    double screenHeight = THelperFunctions.screenHeight(context);

    // Responsive sizing for circular containers based on screen width breakpoints
    double containerSize;
    double fontSize;

    if (screenWidth < 600) {
      containerSize = screenWidth * 0.16;
      fontSize = ESizes.fontSizeMd;
    } else if (screenWidth < 1000) {
      containerSize = 100;
      fontSize = 18;
    } else {
      containerSize = 110;
      fontSize = 20;
    }

    return Column(
      children: [
        GestureDetector(
          onTap: screen,
          child: Container(
            height: containerSize,
            width: containerSize,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1000),
                color: Scolor.secondry),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(image, fit: BoxFit.scaleDown),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          label,
          style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w600),
        )
      ],
    );
  }
}
