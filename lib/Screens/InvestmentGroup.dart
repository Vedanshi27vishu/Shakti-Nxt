import 'package:flutter/material.dart';
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shakti/Widgets/AppWidgets/ScreenHeadings.dart';
import 'package:shakti/Widgets/AppWidgets/YellowLine.dart';
import 'package:shakti/helpers/helper_functions.dart';

class InvestmentGroupsScreen extends StatelessWidget {
  const InvestmentGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = THelperFunctions.screenWidth(context);
    double screenHeight = THelperFunctions.screenHeight(context);
    double padding = screenWidth * 0.04;
    double fontSizeSubtitle = screenWidth * 0.045;
    double fontSizeContent = screenWidth * 0.04;
    double buttonHeight = screenHeight * 0.05;

    return Scaffold(
      backgroundColor: Scolor.primary,
      appBar: AppBar(
        backgroundColor: Scolor.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Scolor.secondry, size: screenWidth * 0.06),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeadings(text: "Groups-"),
            SizedBox(height: screenHeight * 0.005),
            Yellowline(screenWidth: screenWidth),
            SizedBox(height: screenHeight * 0.015),
            Text(
              "Investment Groups Near You",
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSizeSubtitle,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Expanded(
              child: ListView.builder(
                itemCount: investmentGroups.length,
                itemBuilder: (context, index) {
                  final group = investmentGroups[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: screenHeight * 0.015),
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.amber, width: screenWidth * 0.004),
                      borderRadius: BorderRadius.circular(screenWidth * 0.025),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group['name']!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSizeContent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          "${group['members']} members | ${group['meeting']}",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: fontSizeContent * 0.8,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      screenWidth * 0.015),
                                ),
                                minimumSize:
                                    Size(screenWidth * 0.35, buttonHeight),
                              ),
                              onPressed: () {},
                              child: const Text("Preview"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      screenWidth * 0.015),
                                ),
                                minimumSize:
                                    Size(screenWidth * 0.35, buttonHeight),
                              ),
                              onPressed: () {},
                              child: const Text("Join"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Sample Data
final List<Map<String, String>> investmentGroups = [
  {
    'name': 'Lakshmi Self-Help Group',
    'members': '15',
    'meeting': 'Meets every Sunday',
  },
  {
    'name': 'Shakti Investment Club',
    'members': '20',
    'meeting': 'Meets every Sunday',
  },
  {
    'name': 'Dhanam Collective',
    'members': '26',
    'meeting': 'Meets every Sunday',
  },
  {
    'name': 'Savitri Investment Group',
    'members': '35',
    'meeting': 'Meets every Sunday',
  },
];
