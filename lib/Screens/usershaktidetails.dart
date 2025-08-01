import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShaktiProfileScreen extends StatefulWidget {
  const ShaktiProfileScreen({super.key});

  @override
  _ShaktiProfileScreenState createState() => _ShaktiProfileScreenState();
}

class _ShaktiProfileScreenState extends State<ShaktiProfileScreen> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchProfileData() async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No auth token found');
      }
      final response = await http.get(
        Uri.parse('http://65.2.82.85:5000/shakti/shaktidetails'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          profileData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching profile data: $e');
      // Use static data as fallback
      setState(() {
        profileData = {
          "name": "vedu",
          "email": "vedanshi2213219@akgec.ac.in",
          "business": {
            "ideaDetails": {
              "Business_Name": "sugar ",
              "Business_Sector": "Beauty ",
              "Business_City": "ghaziabad ",
              "Buisness_Location": "uttar pradesh ",
              "Idea_Description": "organic ingredients ",
              "Target_Market": "teenager, female ",
              "Unique_Selling_Proposition": "Lipstick "
            },
            "financialPlan": {
              "Estimated_Startup_Cost": 450000,
              "Funding_Required": 68990,
              "Expected_Revenue_First_Year": 67899
            },
            "operationalPlan": {
              "Team_Size": 10,
              "Resources_Required": "infrastructure",
              "Timeline_To_Launch": "6 months"
            }
          },
          "financial": {
            "incomeDetails": {
              "Primary_Monthly_Income": 56,
              "Additional_Monthly_Income": 57
            },
            "assetDetails": {
              "Gold_Asset_amount": 67,
              "Gold_Asset_App_Value": 67,
              "Land_Asset_Area": 67,
              "Land_Asset_App_Value": 77
            },
            "existingloanDetails": [
              {
                "Monthly_Payment": 77,
                "Lender_Name": "hdfc",
                "Loan_Type": "home loan",
                "Total_Loan_Amount": 688
              }
            ]
          }
        };
      });
    }
  }

  Future<void> updateProfileData(Map<String, dynamic> updatedData) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No auth token found');
      }

      final response = await http.put(
        Uri.parse('http://65.2.82.85:5000/shakti/shaktidetails'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          profileData = responseData['data'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to update profile data');
      }
    } catch (e) {
      print('Error updating profile data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditBusinessDialog() {
    final business = profileData!['business'];
    final ideaDetails = business?['ideaDetails'] ?? {};
    final financialPlan = business?['financialPlan'] ?? {};
    final operationalPlan = business?['operationalPlan'] ?? {};

    // Controllers for text fields
    final businessNameController =
        TextEditingController(text: ideaDetails['Business_Name'] ?? '');
    final businessSectorController =
        TextEditingController(text: ideaDetails['Business_Sector'] ?? '');
    final businessCityController =
        TextEditingController(text: ideaDetails['Business_City'] ?? '');
    final businessLocationController =
        TextEditingController(text: ideaDetails['Buisness_Location'] ?? '');
    final ideaDescriptionController =
        TextEditingController(text: ideaDetails['Idea_Description'] ?? '');
    final targetMarketController =
        TextEditingController(text: ideaDetails['Target_Market'] ?? '');
    final uspController = TextEditingController(
        text: ideaDetails['Unique_Selling_Proposition'] ?? '');

    final startupCostController = TextEditingController(
        text: financialPlan['Estimated_Startup_Cost']?.toString() ?? '');
    final fundingRequiredController = TextEditingController(
        text: financialPlan['Funding_Required']?.toString() ?? '');
    final expectedRevenueController = TextEditingController(
        text: financialPlan['Expected_Revenue_First_Year']?.toString() ?? '');

    final teamSizeController = TextEditingController(
        text: operationalPlan['Team_Size']?.toString() ?? '');
    final resourcesController = TextEditingController(
        text: operationalPlan['Resources_Required'] ?? '');
    final timelineController = TextEditingController(
        text: operationalPlan['Timeline_To_Launch'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF283593),
          title: Text('Edit Business Information',
              style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEditTextField('Business Name', businessNameController),
                _buildEditTextField(
                    'Business Sector', businessSectorController),
                _buildEditTextField('Business City', businessCityController),
                _buildEditTextField(
                    'Business Location', businessLocationController),
                _buildEditTextField(
                    'Idea Description', ideaDescriptionController),
                _buildEditTextField('Target Market', targetMarketController),
                _buildEditTextField('USP', uspController),
                _buildEditTextField('Startup Cost', startupCostController,
                    isNumeric: true),
                _buildEditTextField(
                    'Funding Required', fundingRequiredController,
                    isNumeric: true),
                _buildEditTextField(
                    'Expected Revenue', expectedRevenueController,
                    isNumeric: true),
                _buildEditTextField('Team Size', teamSizeController,
                    isNumeric: true),
                _buildEditTextField('Resources Required', resourcesController),
                _buildEditTextField('Timeline to Launch', timelineController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedData = {
                  'business': {
                    'ideaDetails': {
                      'Business_Name': businessNameController.text,
                      'Business_Sector': businessSectorController.text,
                      'Business_City': businessCityController.text,
                      'Buisness_Location': businessLocationController.text,
                      'Idea_Description': ideaDescriptionController.text,
                      'Target_Market': targetMarketController.text,
                      'Unique_Selling_Proposition': uspController.text,
                    },
                    'financialPlan': {
                      'Estimated_Startup_Cost':
                          int.tryParse(startupCostController.text) ?? 0,
                      'Funding_Required':
                          int.tryParse(fundingRequiredController.text) ?? 0,
                      'Expected_Revenue_First_Year':
                          int.tryParse(expectedRevenueController.text) ?? 0,
                    },
                    'operationalPlan': {
                      'Team_Size': int.tryParse(teamSizeController.text) ?? 0,
                      'Resources_Required': resourcesController.text,
                      'Timeline_To_Launch': timelineController.text,
                    },
                  }
                };

                Navigator.of(context).pop();
                updateProfileData(updatedData);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFC107)),
              child: Text('Save', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _showEditFinancialDialog() {
    final financial = profileData!['financial'];
    final incomeDetails = financial?['incomeDetails'] ?? {};

    final primaryIncomeController = TextEditingController(
        text: incomeDetails['Primary_Monthly_Income']?.toString() ?? '');
    final additionalIncomeController = TextEditingController(
        text: incomeDetails['Additional_Monthly_Income']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF283593),
          title: Text('Edit Financial Information',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEditTextField(
                  'Primary Monthly Income', primaryIncomeController,
                  isNumeric: true),
              _buildEditTextField(
                  'Additional Monthly Income', additionalIncomeController,
                  isNumeric: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedData = {
                  'financial': {
                    'incomeDetails': {
                      'Primary_Monthly_Income':
                          int.tryParse(primaryIncomeController.text) ?? 0,
                      'Additional_Monthly_Income':
                          int.tryParse(additionalIncomeController.text) ?? 0,
                    }
                  }
                };

                Navigator.of(context).pop();
                updateProfileData(updatedData);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFC107)),
              child: Text('Save', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _showEditAssetsDialog() {
    final financial = profileData!['financial'];
    final assetDetails = financial?['assetDetails'] ?? {};

    final goldAmountController = TextEditingController(
        text: assetDetails['Gold_Asset_amount']?.toString() ?? '');
    final goldValueController = TextEditingController(
        text: assetDetails['Gold_Asset_App_Value']?.toString() ?? '');
    final landAreaController = TextEditingController(
        text: assetDetails['Land_Asset_Area']?.toString() ?? '');
    final landValueController = TextEditingController(
        text: assetDetails['Land_Asset_App_Value']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF283593),
          title: Text('Edit Assets Information',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEditTextField('Gold Amount (grams)', goldAmountController,
                  isNumeric: true),
              _buildEditTextField('Gold Value', goldValueController,
                  isNumeric: true),
              _buildEditTextField('Land Area (sq ft)', landAreaController,
                  isNumeric: true),
              _buildEditTextField('Land Value', landValueController,
                  isNumeric: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedData = {
                  'financial': {
                    'assetDetails': {
                      'Gold_Asset_amount':
                          int.tryParse(goldAmountController.text) ?? 0,
                      'Gold_Asset_App_Value':
                          int.tryParse(goldValueController.text) ?? 0,
                      'Land_Asset_Area':
                          int.tryParse(landAreaController.text) ?? 0,
                      'Land_Asset_App_Value':
                          int.tryParse(landValueController.text) ?? 0,
                    }
                  }
                };

                Navigator.of(context).pop();
                updateProfileData(updatedData);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFC107)),
              child: Text('Save', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _showEditLoanDialog({int? loanIndex}) {
    final financial = profileData!['financial'];
    final loans = financial?['existingloanDetails'] ?? [];

    // If editing existing loan, get its data, otherwise use empty values
    final loan = loanIndex != null ? loans[loanIndex] : {};

    final monthlyPaymentController =
        TextEditingController(text: loan['Monthly_Payment']?.toString() ?? '');
    final lenderNameController =
        TextEditingController(text: loan['Lender_Name'] ?? '');
    final loanTypeController =
        TextEditingController(text: loan['Loan_Type'] ?? '');
    final totalAmountController = TextEditingController(
        text: loan['Total_Loan_Amount']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF283593),
          title: Text(loanIndex != null ? 'Edit Loan Details' : 'Add New Loan',
              style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEditTextField('Lender Name', lenderNameController),
                _buildEditTextField('Loan Type', loanTypeController),
                _buildEditTextField('Total Loan Amount', totalAmountController,
                    isNumeric: true),
                _buildEditTextField('Monthly Payment', monthlyPaymentController,
                    isNumeric: true),
              ],
            ),
          ),
          actions: [
            if (loanIndex != null) // Show delete button only when editing
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteLoan(loanIndex);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedLoan = {
                  'Monthly_Payment':
                      int.tryParse(monthlyPaymentController.text) ?? 0,
                  'Lender_Name': lenderNameController.text,
                  'Loan_Type': loanTypeController.text,
                  'Total_Loan_Amount':
                      int.tryParse(totalAmountController.text) ?? 0,
                };

                Navigator.of(context).pop();
                _updateLoanDetails(updatedLoan, loanIndex);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFC107)),
              child: Text('Save', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _updateLoanDetails(Map<String, dynamic> loanData, int? loanIndex) async {
    try {
      final financial = profileData!['financial'];
      List<dynamic> loans = List.from(financial?['existingloanDetails'] ?? []);

      if (loanIndex != null) {
        // Update existing loan
        loans[loanIndex] = loanData;
      } else {
        // Add new loan
        loans.add(loanData);
      }

      final updatedData = {
        'financial': {'existingloanDetails': loans}
      };

      await updateProfileData(updatedData);
    } catch (e) {
      print('Error updating loan details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update loan details'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteLoan(int loanIndex) async {
    try {
      final financial = profileData!['financial'];
      List<dynamic> loans = List.from(financial?['existingloanDetails'] ?? []);

      loans.removeAt(loanIndex);

      final updatedData = {
        'financial': {'existingloanDetails': loans}
      };

      await updateProfileData(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Loan deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting loan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete loan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildEditTextField(String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFFFC107)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFFC107)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFFC107), width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Scolor.primary, // Dark blue background
      appBar: AppBar(
        title: Text('Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF0D47A1),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)))
          : profileData == null
              ? Center(
                  child: Text('Failed to load profile',
                      style: TextStyle(color: Colors.white)))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile Header
                      _buildProfileHeader(),
                      SizedBox(height: 24),

                      // Business Information
                      _buildSectionCard(
                          'Business Information', _buildBusinessDetails(),
                          onEdit: _showEditBusinessDialog,
                          onicon: Icon(Icons.edit,
                              color: Color(0xFFFFC107), size: 20)),
                      SizedBox(height: 16),

                      // Financial Information
                      _buildSectionCard(
                          'Financial Information', _buildFinancialDetails(),
                          onEdit: _showEditFinancialDialog,
                          onicon: Icon(Icons.edit,
                              color: Color(0xFFFFC107), size: 20)),

                      SizedBox(height: 16),

                      // Assets Information
                      _buildSectionCard('Assets', _buildAssetsDetails(),
                          onEdit: _showEditAssetsDialog,
                          onicon: Icon(Icons.edit,
                              color: Color(0xFFFFC107), size: 20)),
                      SizedBox(height: 16),

                      // Loans Information
                      _buildLoansDetails()
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3F51B5), Scolor.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFFFFC107), width: 3),
              color: Color(0xFFFFC107).withOpacity(0.2),
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: Color(0xFFFFC107),
            ),
          ),
          SizedBox(width: 20),

          // Name and Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profileData!['name'] ?? 'N/A',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  profileData!['email'] ?? 'N/A',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // // Edit Icon
          // IconButton(
          //   onPressed: () {
          //     // Handle profile edit
          //   },
          //   icon: Icon(Icons.edit, color: Color(0xFFFFC107)),
          // ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    String title,
    Widget content, {
    VoidCallback? onEdit,
    Widget? onicon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF283593),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF3F51B5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: onEdit,
                  child: onicon,
                ),
              ],
            ),
          ),

          // Section Content
          Padding(
            padding: EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessDetails() {
    final business = profileData!['business'];
    if (business == null)
      return Text('No business information',
          style: TextStyle(color: Colors.white70));

    return Column(
      children: [
        if (business['ideaDetails'] != null) ...[
          _buildDetailRow(
              'Business Name', business['ideaDetails']['Business_Name']),
          _buildDetailRow('Sector', business['ideaDetails']['Business_Sector']),
          _buildDetailRow('City', business['ideaDetails']['Business_City']),
          _buildDetailRow(
              'Location', business['ideaDetails']['Buisness_Location']),
          _buildDetailRow(
              'Description', business['ideaDetails']['Idea_Description']),
          _buildDetailRow(
              'Target Market', business['ideaDetails']['Target_Market']),
          _buildDetailRow(
              'USP', business['ideaDetails']['Unique_Selling_Proposition']),
        ],
        if (business['financialPlan'] != null) ...[
          SizedBox(height: 16),
          Text('Financial Plan',
              style: TextStyle(
                  color: Color(0xFFFFC107),
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          SizedBox(height: 8),
          _buildDetailRow('Startup Cost',
              '₹${business['financialPlan']['Estimated_Startup_Cost']}'),
          _buildDetailRow('Funding Required',
              '₹${business['financialPlan']['Funding_Required']}'),
          _buildDetailRow('Expected Revenue (Year 1)',
              '₹${business['financialPlan']['Expected_Revenue_First_Year']}'),
        ],
        if (business['operationalPlan'] != null) ...[
          SizedBox(height: 16),
          Text('Operational Plan',
              style: TextStyle(
                  color: Color(0xFFFFC107),
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          SizedBox(height: 8),
          _buildDetailRow(
              'Team Size', business['operationalPlan']['Team_Size'].toString()),
          _buildDetailRow('Resources Required',
              business['operationalPlan']['Resources_Required']),
          _buildDetailRow('Timeline to Launch',
              business['operationalPlan']['Timeline_To_Launch']),
        ],
      ],
    );
  }

  Widget _buildFinancialDetails() {
    final financial = profileData!['financial'];
    if (financial == null || financial['incomeDetails'] == null) {
      return Text('No financial information',
          style: TextStyle(color: Colors.white70));
    }

    return Column(
      children: [
        _buildDetailRow('Primary Monthly Income',
            '₹${financial['incomeDetails']['Primary_Monthly_Income']}'),
        _buildDetailRow('Additional Monthly Income',
            '₹${financial['incomeDetails']['Additional_Monthly_Income']}'),
      ],
    );
  }

  Widget _buildAssetsDetails() {
    final financial = profileData!['financial'];
    if (financial == null || financial['assetDetails'] == null) {
      return Text('No asset information',
          style: TextStyle(color: Colors.white70));
    }

    final assets = financial['assetDetails'];
    return Column(
      children: [
        _buildDetailRow('Gold Amount', '${assets['Gold_Asset_amount']} grams'),
        _buildDetailRow('Gold Value', '₹${assets['Gold_Asset_App_Value']}'),
        _buildDetailRow('Land Area', '${assets['Land_Asset_Area']} sq ft'),
        _buildDetailRow('Land Value', '₹${assets['Land_Asset_App_Value']}'),
      ],
    );
  }

  Widget _buildLoansDetails() {
    final financial = profileData!['financial'];
    if (financial == null ||
        financial['existingloanDetails'] == null ||
        financial['existingloanDetails'].isEmpty) {
      return Column(
        children: [
          // Add New Loan Button with lighter background
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF3F51B5), // Lighter blue background like Assets
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('No existing loans',
                    style: TextStyle(color: Colors.white70)),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _showEditLoanDialog(),
                  icon: Icon(Icons.add, color: Colors.black),
                  label:
                      Text('Add Loan', style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFC107)),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        // Add New Loan Button with lighter background
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF3F51B5),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Existing Loans',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _showEditLoanDialog(),
                  icon: Icon(Icons.add, color: Colors.black, size: 18),
                  label: Text('Add Loan',
                      style: TextStyle(color: Colors.black, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFC107),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Existing Loans with darker background
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF283593), // Darker blue background for loan details
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Column(
            children: financial['existingloanDetails']
                .asMap()
                .entries
                .map<Widget>((entry) {
              int index = entry.key;
              var loan = entry.value;

              return Column(
                children: [
                  // Loan header with edit icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Loan ${index + 1}',
                        style: TextStyle(
                          color: Color(0xFFFFC107),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showEditLoanDialog(loanIndex: index),
                        child: Icon(
                          Icons.edit,
                          color: Color(0xFFFFC107),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Loan details
                  _buildDetailRow('Lender', loan['Lender_Name']),
                  _buildDetailRow('Loan Type', loan['Loan_Type']),
                  _buildDetailRow(
                      'Total Amount', '₹${loan['Total_Loan_Amount']}'),
                  _buildDetailRow(
                      'Monthly Payment', '₹${loan['Monthly_Payment']}'),

                  // Add divider between loans if there are multiple loans
                  if (index < financial['existingloanDetails'].length - 1) ...[
                    SizedBox(height: 16),
                    Divider(
                        color: Color(0xFFFFC107).withOpacity(0.3),
                        thickness: 1),
                    SizedBox(height: 16),
                  ],
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Color(0xFFFFC107),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.toString() ?? 'N/A',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
