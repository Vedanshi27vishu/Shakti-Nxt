import 'package:flutter/material.dart';
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shakti/Widgets/AppWidgets/ScreenHeadings.dart';
import 'package:shakti/Widgets/AppWidgets/YellowLine.dart';
import 'package:shakti/helpers/helper_functions.dart';
import 'package:shakti/Widgets/ScreenWidgets/progresscontent.dart';

class BudgetInsights extends StatelessWidget {
  final List<Map<String, dynamic>> budgetData;

  const BudgetInsights({required this.budgetData, super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = THelperFunctions.screenWidth(context);

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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                children: [
                  Image.asset(
                    "assets/Progress.png",
                    height: 24,
                    width: 24,
                  ),
                  const SizedBox(width: 10),
                  ScreenHeadings(text: "Your Budget"),
                ],
              ),

              const SizedBox(height: 10),
              Yellowline(screenWidth: screenWidth),
              const SizedBox(height: 20),

              /// Content
              if (budgetData.isNotEmpty)
                ...budgetData.asMap().entries.map((entry) {
                  int index = entry.key;
                  final item = entry.value;
                  final title = item['title'] ?? '';
                  final description = item['description'] ?? '';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildSection(
                        title: "${index + 1}. $title",
                        description: description,
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }).toList()
              else
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
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
