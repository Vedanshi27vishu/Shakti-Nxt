import 'package:flutter/material.dart';
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shakti/Widgets/AppWidgets/ScreenHeadings.dart';
import 'package:shakti/Widgets/AppWidgets/YellowLine.dart';
import 'package:shakti/Widgets/ScreenWidgets/flowchart.dart';
import 'package:shakti/helpers/helper_functions.dart';

class FinancialFlowChartScreen extends StatelessWidget {
  const FinancialFlowChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const ScreenHeadings(text: "Financial Process FlowChart-"),
              SizedBox(height: screenHeight * 0.01),
              Yellowline(screenWidth: screenWidth),
              SizedBox(height: screenHeight * 0.01),

              // FLOWCHART
              Column(
                children: [
                  flowChartNode("Assess current Financial Situation",
                      isOval: true),
                  connector(),
                  flowChartNode("Set Financial Goals\n(Short, Mid, Long-term)",
                      isOval: true),
                  connector(),
                  flowChartNode("Establish an Emergency Fund",
                      color: Colors.green),
                  connector(),
                  flowChartNode("Create Emergency Fund"),
                  connector(),
                  flowChartNode(
                      "Analyze Cash Flow\n(Track Spending, Save More)"),
                  connector(),
                  flowChartNode(
                      "Develop Investment Strategy\n(Risk Tolerance, Diversification)"),
                  connector(),
                  flowChartNode(
                      "Monitor and Adjust Plan\n(Regular Reviews, Revisions)"),
                  connector(),
                  flowChartNode("Achieve Financial Stability", isOval: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
