import 'package:flutter/material.dart';
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shakti/helpers/helper_functions.dart';

class InvestmentScreen extends StatelessWidget {
  const InvestmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Scolor.primary,
      appBar: AppBar(
        backgroundColor: Scolor.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Scolor.secondry),
          onPressed: () => Navigator.pop(context),
        ),
        title: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            double fontSize = 20;
            if (width < 600) {
              fontSize = 18;
            } else if (width < 1000) {
              fontSize = 22;
            } else {
              fontSize = 26;
            }
            return Text(
              'Investment Plans',
              style: TextStyle(
                color:Scolor.white,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            );
          },
        ),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            // Define max width to constrain layout for desktop/tablet
            final maxWidth = (width < 600)
                ? width
                : (width < 900 ? 600.0 : 700.0);
            final horizontalPadding = maxWidth * 0.04;

            // Font size breakpoints
            double titleFontSize = 16;
            double subtitleFontSize = 13;
            double featureFontSize = 12;
            double smallSpacing = 8;
            double mediumSpacing = 12;

            if (width < 600) {
              titleFontSize = 16;
              subtitleFontSize = 13;
              featureFontSize = 12;
              smallSpacing = 6;
              mediumSpacing = 10;
            } else if (width < 1000) {
              titleFontSize = 18;
              subtitleFontSize = 14;
              featureFontSize = 13;
              smallSpacing = 8;
              mediumSpacing = 12;
            } else {
              titleFontSize = 20;
              subtitleFontSize = 15;
              featureFontSize = 14;
              smallSpacing = 10;
              mediumSpacing = 14;
            }

            return Container(
              width: maxWidth,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: mediumSpacing),
              child: ListView.builder(
                itemCount: investmentPlans.length,
                itemBuilder: (context, index) {
                  final plan = investmentPlans[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: mediumSpacing),
                    padding: EdgeInsets.all(horizontalPadding),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: plan['borderColor'] ?? Scolor.secondry,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              "assets/rupees.png",
                              width: maxWidth * 0.07,
                              height: maxWidth * 0.07,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: mediumSpacing),
                            Expanded(
                              child: Text(
                                plan['title'] ?? '',
                                style: TextStyle(
                                  color: Scolor.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: titleFontSize,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: smallSpacing),
                        Text(
                          plan['subtitle'] ?? '',
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.w600,
                            fontSize: subtitleFontSize,
                          ),
                        ),
                        SizedBox(height: smallSpacing),
                        Text(
                          "Minimum: ${plan['minimum'] ?? ''}",
                          style: TextStyle(
                            color: Scolor.white,
                            fontSize: subtitleFontSize,
                          ),
                        ),
                        Text(
                          "Duration: ${plan['duration'] ?? ''}",
                          style: TextStyle(
                            color: Scolor.white,
                            fontSize: subtitleFontSize,
                          ),
                        ),
                        SizedBox(height: smallSpacing),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List<Widget>.from(
                            (plan['features'] as List<dynamic>? ?? []).map(
                              (feature) => Padding(
                                padding: EdgeInsets.only(bottom: smallSpacing / 2),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 6.0),
                                      child: Icon(Icons.circle, size: 6, color: Colors.amber),
                                    ),
                                    SizedBox(width: smallSpacing),
                                    Expanded(
                                      child: Text(
                                        feature,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: featureFontSize,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: smallSpacing),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Returns: ${plan['returns'] ?? ''}",
                              style: TextStyle(
                                color: Scolor.white,
                                fontSize: subtitleFontSize,
                              ),
                            ),
                            Text(
                              "Group: ${plan['group'] ?? ''}",
                              style: TextStyle(
                                color: Scolor.white,
                                fontSize: subtitleFontSize,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// Sample data remains the same
final List<Map<String, dynamic>> investmentPlans = [
  {
    'title': 'Daily Savings Scheme',
    'subtitle': 'Start with just ₹20 per day',
    'minimum': '₹20',
    'duration': 'Flexible',
    'features': [
      'No lock-in period',
      'Daily collection',
      'Mobile money deposit',
    ],
    'returns': '6%',
    'group': 'Individual',
    'borderColor': Colors.amber,
  },
  {
    'title': 'Micro Enterprise Bond',
    'subtitle': 'For established micro business',
    'minimum': '₹500',
    'duration': '1 year',
    'features': [
      'Business loans',
      'Insurance coverage',
      'Expert mentorship',
    ],
    'returns': '12%',
    'group': 'Individual',
    'borderColor': Colors.amber,
  },
  {
    'title': 'Self-Help Group',
    'subtitle': 'Group-based weekly investment',
    'minimum': '₹100',
    'duration': '6 months',
    'features': [
      'Group liability',
      'Weekly meetings',
      'Skill development',
    ],
    'returns': '8%-10%',
    'group': '10-15 women',
    'borderColor': Colors.amber,
  },
];
