import 'package:flutter/material.dart';
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shakti/Widgets/AppWidgets/ScreenHeadings.dart';
import 'package:shakti/Widgets/AppWidgets/YellowLine.dart';
import 'package:shakti/helpers/helper_functions.dart';

class YourFeedbackScreen extends StatelessWidget {
  const YourFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Scolor.primary, // Dark background
      appBar: AppBar(
        backgroundColor: Scolor.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Scolor.secondry),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = MediaQuery.of(context).size.height;

            // Define max width breakpoints for readability on larger screens
            double maxWidth;
            if (screenWidth < 600) {
              maxWidth = double.infinity; // Full width on mobile
            } else if (screenWidth < 1000) {
              maxWidth = 700; // Tablet max width
            } else {
              maxWidth = 900; // Desktop max width
            }

            // Responsive horizontal padding and vertical spacing
            final horizontalPadding = maxWidth == double.infinity ? screenWidth * 0.06 : 24.0;
            final sectionSpacing = screenHeight * 0.025;

            // Responsive font sizes
            final titleFontSize = screenWidth < 600 ? 18.0 : (screenWidth < 1000 ? 20.0 : 22.0);
            final descriptionFontSize = screenWidth < 600 ? 16.0 : (screenWidth < 1000 ? 18.0 : 20.0);

            return Container(
              width: maxWidth,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Row with Icon
                    Row(
                      children: [
                        Image.asset(
                          "assets/Progress.png",
                          height: 24,
                          width: 24,
                        ),
                        const SizedBox(width: 10),
                        ScreenHeadings(
                          text: "Your Feedback",
                         // fontSize: titleFontSize + 4, // Slightly larger font for heading
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    // Divider
                    Yellowline(screenWidth: screenWidth),

                    SizedBox(height: 20),

                    // Sections
                    buildSection(
                      title: "1. Set Clear Financial Goals",
                      description:
                          "Establishing clear financial goals helps you define where you want your business to be in the short, medium, and long term. These goals guide your decision-making process and allow you to track progress. For example:\n\n"
                          "• Short-term goals could include covering monthly expenses or improving cash flow.\n"
                          "• Mid-term goals might focus on growing revenue or expanding your product range.\n"
                          "• Long-term goals could involve building a strong financial base for sustainability or planning for business expansion.\n\n"
                          "Setting goals will give your business direction and a clear path forward.",
                      titleFontSize: titleFontSize,
                      descriptionFontSize: descriptionFontSize,
                    ),

                    SizedBox(height: sectionSpacing),

                    buildSection(
                      title: "2. Track and Monitor Cash Flow",
                      description:
                          "Cash flow is critical for the survival and growth of any business, especially for SMEs. Regularly monitoring cash flow allows you to understand whether your business has enough liquidity to cover operational expenses and pursue opportunities.",
                      titleFontSize: titleFontSize,
                      descriptionFontSize: descriptionFontSize,
                    ),

                    SizedBox(height: sectionSpacing),
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
        // Optional border for visual grouping can be enabled
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
