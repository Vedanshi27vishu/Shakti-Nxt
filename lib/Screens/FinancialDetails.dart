import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shakti/Screens/BusinessDetails.dart';
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shakti/Widgets/AppWidgets/Continue.dart';
import 'package:shakti/Widgets/AppWidgets/InputField.dart';
import 'package:shakti/Widgets/AppWidgets/Subheading.dart';
import 'package:shakti/Widgets/AppWidgets/ThreeCircle.dart';
import 'package:shakti/Widgets/AppWidgets/UnderlineHeading.dart';
import 'package:shakti/helpers/helper_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinancialDetails extends StatefulWidget {
  const FinancialDetails({super.key});

  @override
  State<FinancialDetails> createState() => _FinancialDetailsState();
}

class _FinancialDetailsState extends State<FinancialDetails> {
  final TextEditingController primaryIncomeController = TextEditingController();
  final TextEditingController additionalIncomeController =
      TextEditingController();
  final TextEditingController goldAmountController = TextEditingController();
  final TextEditingController goldValueController = TextEditingController();
  final TextEditingController landAreaController = TextEditingController();
  final TextEditingController landValueController = TextEditingController();
  final TextEditingController cashAmountController = TextEditingController();
  final TextEditingController cashValueController = TextEditingController();

  double screenWidth = 0;
  double screenHeight = 0;

  List<Map<String, TextEditingController>> loanControllers = [
    {
      "Monthly_Payment": TextEditingController(),
      "Lender_Name": TextEditingController(),
      "Loan_Type": TextEditingController(),
      "Total_Loan_Amount": TextEditingController(),
      "Loan_Years": TextEditingController(),
      "Interest_Rate": TextEditingController(),
    }
  ];

  Future<void> submitFinancialDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('sessionId');

    if (sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Session ID not found. Please restart the form.")),
      );
      return;
    }

    final url = Uri.parse("http://65.2.82.85:5000/api/signup/signup2");

    final loanList = loanControllers.map((loan) {
      return {
        "Monthly_Payment":
            int.tryParse(loan["Monthly_Payment"]!.text.trim()) ?? 0,
        "Lender_Name": loan["Lender_Name"]!.text.trim(),
        "Loan_Type": loan["Loan_Type"]!.text.trim(),
        "Total_Loan_Amount":
            int.tryParse(loan["Total_Loan_Amount"]!.text.trim()) ?? 0,
      };
    }).toList();

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "sessionId": sessionId,
        "incomeDetails": {
          "Primary_Monthly_Income":
              int.tryParse(primaryIncomeController.text.trim()) ?? 0,
          "Additional_Monthly_Income":
              int.tryParse(additionalIncomeController.text.trim()) ?? 0,
        },
        "assetDetails": {
          "Gold_Asset_amount":
              int.tryParse(goldAmountController.text.trim()) ?? 0,
          "Gold_Asset_App_Value":
              int.tryParse(goldValueController.text.trim()) ?? 0,
          "Land_Asset_Area": int.tryParse(landAreaController.text.trim()) ?? 0,
          "Land_Asset_App_Value":
              int.tryParse(landValueController.text.trim()) ?? 0,
        },
        "existingloanDetails": loanList,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BusinessDetails()),
      );
    } else {
      debugPrint("Error: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit financial details.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = THelperFunctions.screenWidth(context);
    screenHeight = THelperFunctions.screenHeight(context);

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
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ThreeCircle(screenWidth: screenWidth),
              SizedBox(height: screenHeight * 0.03),
              const Text(
                "Financial Details",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              buildSectionHeader("Income Details"),
              InputField(
                  label: "Primary Monthly Income",
                  controller: primaryIncomeController),
              InputField(
                  label: "Additional Monthly Income",
                  controller: additionalIncomeController),
              SizedBox(height: screenHeight * 0.02),
              buildSectionHeader("Assets Details"),
              buildSubSection("Gold Assets"),
              InputField(
                  label: "Amount (in grams)", controller: goldAmountController),
              InputField(
                  label: "Approximate Value (₹)",
                  controller: goldValueController),
              SizedBox(height: screenHeight * 0.02),
              buildSubSection("Land Assets"),
              InputField(
                  label: "Area (in acres)", controller: landAreaController),
              InputField(
                  label: "Approximate Value (₹)",
                  controller: landValueController),
              SizedBox(height: screenHeight * 0.02),
              buildSectionHeader("Existing Loans"),
              Column(
                children: List.generate(loanControllers.length, (index) {
                  final loan = loanControllers[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Loan ${index + 1}",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      InputField(
                          label: "Monthly Payment",
                          controller: loan["Monthly_Payment"]!),
                      InputField(
                          label: "Lender Name",
                          controller: loan["Lender_Name"]!),
                      InputField(
                          label: "Loan Type", controller: loan["Loan_Type"]!),
                      InputField(
                          label: "Total Loan Amount",
                          controller: loan["Total_Loan_Amount"]!),
                      const SizedBox(height: 16),
                    ],
                  );
                }),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      loanControllers.add({
                        "Monthly_Payment": TextEditingController(),
                        "Lender_Name": TextEditingController(),
                        "Loan_Type": TextEditingController(),
                        "Total_Loan_Amount": TextEditingController(),
                        "Loan_Years": TextEditingController(),
                        "Interest_Rate": TextEditingController(),
                      });
                    });
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Add Another Loan",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              ContinueButton(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                text: "Continue",
                onPressed: submitFinancialDetails,
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
