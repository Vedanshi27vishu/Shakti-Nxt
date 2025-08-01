import 'package:flutter/material.dart';
import 'package:shakti/Screens/labview.dart';
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shakti/helpers/helper_functions.dart';

class GovernmentLoansScreen extends StatelessWidget {
  final List<dynamic> loans;

  const GovernmentLoansScreen({Key? key, required this.loans}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Scolor.primary,
      appBar: AppBar(
        backgroundColor: Scolor.primary,
        title: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double screenHeight = MediaQuery.of(context).size.height;
            double fontSize;
            if (screenWidth < 600) {
              fontSize = screenHeight * 0.025;
            } else if (screenWidth < 1000) {
              fontSize = 26;
            } else {
              fontSize = 32;
            }
            return Text(
              "Government Loan Schemes",
              style: TextStyle(
                color: Scolor.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        iconTheme: IconThemeData(color: Scolor.white),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = MediaQuery.of(context).size.height;

            double maxWidth, cardPadding, loanTitleFont, descFont, eligibilityFont, spacing;
            if (screenWidth < 600) {
              maxWidth = double.infinity;
              cardPadding = screenWidth * 0.04;
              loanTitleFont = screenHeight * 0.022;
              descFont = screenHeight * 0.018;
              eligibilityFont = screenHeight * 0.016;
              spacing = screenHeight * 0.01;
            } else if (screenWidth < 1000) {
              maxWidth = 700;
              cardPadding = 28;
              loanTitleFont = 22;
              descFont = 17;
              eligibilityFont = 15;
              spacing = 12;
            } else {
              maxWidth = 900;
              cardPadding = 32;
              loanTitleFont = 26;
              descFont = 19;
              eligibilityFont = 16.5;
              spacing = 14;
            }

            return Container(
              width: maxWidth,
              padding: EdgeInsets.all(cardPadding),
              child: loans.isEmpty
                  ? Center(
                      child: Text(
                        "No loan schemes available",
                        style: TextStyle(
                          color: Scolor.white,
                          fontSize: descFont,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: loans.length,
                      itemBuilder: (context, index) {
                        final loan = loans[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: spacing * 2),
                          padding: EdgeInsets.all(cardPadding),
                          decoration: BoxDecoration(
                            border: Border.all(color: Scolor.secondry),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loan['name'] ?? 'Unknown Loan',
                                style: TextStyle(
                                  color: Scolor.secondry,
                                  fontSize: loanTitleFont,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: spacing),
                              Text(
                                loan['description'] ?? 'No description available',
                                style: TextStyle(
                                  color: Scolor.white,
                                  fontSize: descFont,
                                ),
                              ),
                              SizedBox(height: spacing * 1.5),
                              Text(
                                "Eligibility:",
                                style: TextStyle(
                                  color: Scolor.secondry,
                                  fontSize: eligibilityFont + 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: spacing * 0.8),
                              if (loan['eligibility'] != null) ...[
                                ...List<String>.from(loan['eligibility']).map(
                                  (criteria) => Padding(
                                    padding: EdgeInsets.only(
                                      left: cardPadding * 0.6,
                                      bottom: spacing * 0.5,
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "• ",
                                          style: TextStyle(
                                            color: Scolor.white,
                                            fontSize: eligibilityFont,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            criteria,
                                            style: TextStyle(
                                              color: Scolor.white,
                                              fontSize: eligibilityFont,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              if (loan['link'] != null) ...[
                                SizedBox(height: spacing * 1.5),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LoanWebViewScreen(
                                                  url: loan['link'],
                                                  title: loan['name'],
                                                )));
                                  },
                                  child: Text(
                                    "Learn More",
                                    style: TextStyle(
                                      color: Scolor.secondry,
                                      fontSize: eligibilityFont,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
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
