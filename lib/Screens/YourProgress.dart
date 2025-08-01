import 'package:flutter/material.dart';
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shakti/Widgets/AppWidgets/ScreenHeadings.dart';
import 'package:shakti/Widgets/AppWidgets/YellowLine.dart';
import 'package:shakti/helpers/helper_functions.dart';

class YourProgressScreen extends StatelessWidget {
  final List<Map<String, dynamic>> progressData;

  const YourProgressScreen({
    super.key,
    this.progressData = const [],
  });

  @override
  Widget build(BuildContext context) {
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
      // Responsive body with Center + LayoutBuilder for max width control
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = MediaQuery.of(context).size.height;

            // Set max content width for tablets and desktops
            // Mobile: full width, tablet: 700, desktop: 900
            double maxWidth;
            if (screenWidth < 600) {
              maxWidth = double.infinity;
            } else if (screenWidth < 1000) {
              maxWidth = 700;
            } else {
              maxWidth = 900;
            }

            // Calculate paddings and font sizes dynamically
            final horizontalPadding = maxWidth == double.infinity ? screenWidth * 0.06 : 24.0;
            final titleFontSize = screenWidth < 600 ? 18.0 : (screenWidth < 1000 ? 20.0 : 22.0);
            final descriptionFontSize = screenWidth < 600 ? 16.0 : (screenWidth < 1000 ? 18.0 : 20.0);
            final sectionSpacing = screenHeight * 0.025;

            return Container(
              width: maxWidth,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/Progress.png",
                          height: 24,
                          width: 24,
                        ),
                        const SizedBox(width: 10),
                        ScreenHeadings(
                          text: "Your Progress",
                          //fontSize: titleFontSize + 4,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Yellowline(screenWidth: screenWidth),
                    SizedBox(height: sectionSpacing),

                    // Dynamic Progress Content
                    if (progressData.isNotEmpty) ...[
                      ...progressData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final title = item['title'] ?? '';
                        final description = item['description'] ?? '';

                        return Column(
                          children: [
                            buildSection(
                              title: "${index + 1}. $title",
                              description: description,
                              titleFontSize: titleFontSize,
                              descriptionFontSize: descriptionFontSize,
                            ),
                            SizedBox(height: sectionSpacing),
                          ],
                        );
                      }).toList(),
                    ] else ...[
                      buildSection(
                        title: "1. Set Clear Financial Goals",
                        description:
                            "Establishing clear financial goals helps you define where you want your business to be in the short, medium, and long term.\n\n"
                            "Implementation Tips:\n"
                            "• Break this goal into smaller, manageable tasks\n"
                            "• Set specific deadlines and milestones\n"
                            "• Track your progress regularly\n"
                            "• Adjust your approach based on results\n\n"
                            "Remember: Consistent small steps lead to significant progress over time.",
                        titleFontSize: titleFontSize,
                        descriptionFontSize: descriptionFontSize,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildSection({
    required String title,
    required String description,
    required double titleFontSize,
    required double descriptionFontSize,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Scolor.primary,
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: Scolor.secondry.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Scolor.secondry,
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: Colors.white,
              fontSize: descriptionFontSize,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
