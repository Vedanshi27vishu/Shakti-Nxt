import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shakti/Screens/InvestScreen.dart';
import 'package:shakti/Screens/InvestmentGroup.dart';
import 'package:shakti/Screens/government.dart';
import 'package:shakti/Screens/tracker.dart';
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DeviceScreenType { Mobile, Tablet, Laptop }

DeviceScreenType getDeviceType(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width >= 900) {
    return DeviceScreenType.Laptop;
  } else if (width >= 600) {
    return DeviceScreenType.Tablet;
  } else {
    return DeviceScreenType.Mobile;
  }
}

class Invest extends StatefulWidget {
  const Invest({super.key});

  @override
  State<Invest> createState() => _InvestState();
}

class _InvestState extends State<Invest> {
  List<dynamic> recommendedLoans = [];
  List<dynamic> privateSchemes = [];
  List<dynamic> userLoans = [];
  double totalRemainingLoanAmount = 0;
  double investmentAmount = 0;
  double totalInstallment = 0;
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      fetchRecommendedLoans(),
      fetchPrivateSchemes(),
      fetchUserLoans(),
    ]);
    if (!mounted) return;
    setState(() {});
  }

  String _formatCurrency(double amount) {
    String amountStr = amount.toInt().toString();
    if (amountStr.length > 3) {
      String result = '';
      int count = 0;
      for (int i = amountStr.length - 1; i >= 0; i--) {
        if (count == 3 || (count > 3 && (count - 3) % 2 == 0)) {
          result = ',$result';
        }
        result = '${amountStr[i]}$result';
        count++;
      }
      return result;
    }
    return amountStr;
  }

  Future<void> fetchRecommendedLoans() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('No authentication token found');

      final url = Uri.parse('http://65.2.82.85:5000/filter-loans');

      final response = await http.post(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          recommendedLoans = data['recommendedLoans'] ?? [];
        });
      } else {
        throw Exception('Failed to fetch loans: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Error fetching recommended loans: $e';
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> fetchPrivateSchemes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('No authentication token found');

      final url = Uri.parse('http://65.2.82.85:5000/private-schemes');

      final response = await http.post(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          privateSchemes = data['recommendedLoans'] ?? [];
        });
      } else {
        throw Exception(
            'Failed to fetch private schemes: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Error fetching private schemes: $e';
      });
    }
  }

  Future<void> fetchUserLoans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('No authentication token found');

      final url = Uri.parse('http://65.2.82.85:5000/api/financial/loans');

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          userLoans = data['loans'] ?? [];
          totalRemainingLoanAmount =
              (data['totalRemainingAmount'] ?? 0).toDouble();
          investmentAmount = (data['investmentAmount'] ?? 0).toDouble();
          totalInstallment = (data['totalinstallment'] ?? 0).toDouble();
        });
      } else {
        throw Exception('Failed to fetch user loans: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Error fetching user loans: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Determine max width of main content based on screen size
    double contentMaxWidth;
    if (screenWidth < 600) {
      contentMaxWidth = screenWidth; // Phones — full width
    } else if (screenWidth < 1000) {
      contentMaxWidth = 700; // Tablets — max width 700
    } else {
      contentMaxWidth = 900; // Laptops/Desktops — max width 900
    }
    final deviceType = getDeviceType(context);

    // Define layout parameters based on device type
    double headingFontSize;
    double cardHeightFactor;
    Axis cardsDirection;
    double bottomButtonWidthFactor;

    switch (deviceType) {
      case DeviceScreenType.Laptop:
        headingFontSize = screenHeight * 0.019;
        cardHeightFactor = 0.16;
        cardsDirection = Axis.horizontal;
        bottomButtonWidthFactor = 0.18;
        break;
      case DeviceScreenType.Tablet:
        headingFontSize = screenHeight * 0.13;
        cardHeightFactor = 0.16;
        cardsDirection = Axis.horizontal;
        bottomButtonWidthFactor = 0.18;
        break;
      case DeviceScreenType.Mobile:
      default:
        headingFontSize = screenHeight * 0.045;
        cardHeightFactor = 0.15;
        cardsDirection = Axis.vertical;
        bottomButtonWidthFactor = 0.74;
        break;
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: LayoutBuilder(builder: (context, constraints) {
          double width = constraints.maxWidth;
          double iconSize = (deviceType == DeviceScreenType.Mobile)
              ? 26
              : (deviceType == DeviceScreenType.Tablet)
                  ? 30
                  : 36;
          double horizontalPadding = (deviceType == DeviceScreenType.Mobile)
              ? 0
              : (deviceType == DeviceScreenType.Tablet)
                  ? 10
                  : 30;

          return AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Scolor.primary,
            elevation: 0,
            titleSpacing: 0,
            // title:
            title: LayoutBuilder(
              builder: (context, constraints) {
                // You may define custom breakpoints as per your design
                double width;
                if (constraints.maxWidth < 600) {
                  // Mobile: use full width with padding
                  width = double.infinity;
                } else if (constraints.maxWidth < 1000) {
                  // Tablet: medium box
                  width = 400;
                } else {
                  // Desktop/Laptop: slightly larger, but still centered
                  width = 500;
                }

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Text(
                    "Hi, Entrepreneur!",
                    style: TextStyle(
                      fontSize: headingFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                );
              },
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: horizontalPadding + 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => TrackerScreen()));
                  },
                  child: SizedBox(
                    height: iconSize,
                    width: iconSize,
                    child: Image.asset("assets/images/newwallet.png"),
                  ),
                ),
              )
            ],
          );
        }),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: contentMaxWidth,
            child: LayoutBuilder(builder: (context, constraints) {
              double maxWidth;
              if (screenWidth < 600) {
                maxWidth = screenWidth;
              } else if (screenWidth < 1000) {
                maxWidth = 700;
              } else {
                maxWidth = 900;
              }

              // Info card width based on maxWidth and layout direction
              double infoCardWidth = (cardsDirection == Axis.horizontal)
                  ? (maxWidth - 2 * 16) / 3
                  : maxWidth;

              return Container(
                width: maxWidth,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   "Hi, Entrepreneur!",
                    //   style: TextStyle(
                    //     fontSize: headingFontSize,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.white,
                    //   ),
                    // ),
                    // SizedBox(height: screenHeight * 0.05),

                    // Info cards
                    cardsDirection == Axis.horizontal
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _infoCard(
                                "Total Outstanding Loans",
                                "₹${_formatCurrency(totalRemainingLoanAmount)}",
                                "Across ${userLoans.length} active loans",
                                cardHeightFactor * screenHeight,
                                infoCardWidth,
                                "assets/images/rupeesyellow.png",
                              ),
                              _infoCard(
                                "Monthly Payment",
                                "₹${_formatCurrency(totalInstallment)}",
                                "Due Every Month",
                                cardHeightFactor * screenHeight,
                                infoCardWidth,
                                "assets/images/Vector-1.png",
                              ),
                              _infoCard(
                                "Investment Amount",
                                "₹${_formatCurrency(investmentAmount)}",
                                "Available Funds",
                                cardHeightFactor * screenHeight,
                                infoCardWidth,
                                "assets/images/arrow (1).png",
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _infoCard(
                                "Total Outstanding Loans",
                                "₹${_formatCurrency(totalRemainingLoanAmount)}",
                                "Across ${userLoans.length} active loans",
                                cardHeightFactor * screenHeight,
                                infoCardWidth,
                                "assets/images/rupeesyellow.png",
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              _infoCard(
                                "Monthly Payment",
                                "₹${_formatCurrency(totalInstallment)}",
                                "Due Every Month",
                                cardHeightFactor * screenHeight,
                                infoCardWidth,
                                "assets/images/Vector-1.png",
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              _infoCard(
                                "Investment Amount",
                                "₹${_formatCurrency(investmentAmount)}",
                                "Available Funds",
                                cardHeightFactor * screenHeight,
                                infoCardWidth,
                                "assets/images/arrow (1).png",
                              ),
                            ],
                          ),

                    SizedBox(height: screenHeight * 0.05),

                    // Active loans heading
                    Text(
                      "Active Loans",
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // loan table inside limited height
                    SizedBox(
                      height: screenHeight * 0.35,
                      child: _loanTable(),
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // Scheme cards horizontal view or wrap on mobile
                    if (deviceType == DeviceScreenType.Mobile)
                      Wrap(
                        spacing: 12,
                        runSpacing: 20,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GovernmentLoansScreen(
                                      loans: recommendedLoans),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: maxWidth * 0.9,
                              child: _schemeCard(
                                screenHeight,
                                maxWidth,
                                "Government Schemes",
                                "assets/images/raphael_piechart.png",
                                true,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GovernmentLoansScreen(
                                      loans: privateSchemes),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: maxWidth * 0.9,
                              child: _schemeCard(
                                screenHeight,
                                maxWidth,
                                "Private Schemes",
                                "assets/images/famicons_person-outline.png",
                                false,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GovernmentLoansScreen(
                                        loans: recommendedLoans),
                                  ),
                                );
                              },
                              child: _schemeCard(
                                screenHeight,
                                maxWidth,
                                "Government Schemes",
                                "assets/images/raphael_piechart.png",
                                true,
                              ),
                            ),
                            SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GovernmentLoansScreen(
                                        loans: privateSchemes),
                                  ),
                                );
                              },
                              child: _schemeCard(
                                screenHeight,
                                maxWidth,
                                "Private Schemes",
                                "assets/images/famicons_person-outline.png",
                                false,
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: screenHeight * 0.05),

                    // Bottom buttons (responsive layout)
                    if (deviceType == DeviceScreenType.Mobile)
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const Invest())),
                            child: BottomContainer(
                                width: maxWidth * bottomButtonWidthFactor,
                                height: screenHeight,
                                heading: "INVEST"),
                          ),
                          SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const InvestmentGroupsScreen())),
                            child: BottomContainer(
                                width: maxWidth * bottomButtonWidthFactor,
                                height: screenHeight,
                                heading: "GROUPS"),
                          ),
                          SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const TrackerScreen())),
                            child: BottomContainer(
                                width: maxWidth * bottomButtonWidthFactor,
                                height: screenHeight,
                                heading: "TRACKER"),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const InvestmentScreen())),
                            child: BottomContainer(
                                width: maxWidth * bottomButtonWidthFactor,
                                height: screenHeight,
                                heading: "INVEST"),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const InvestmentGroupsScreen())),
                            child: BottomContainer(
                                width: maxWidth * bottomButtonWidthFactor,
                                height: screenHeight,
                                heading: "GROUPS"),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const TrackerScreen())),
                            child: BottomContainer(
                                width: maxWidth * bottomButtonWidthFactor,
                                height: screenHeight,
                                heading: "TRACKER"),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title, String amount, String subtitle, double height,
      double width, String image) {
    return Container(
      height: height * 1.2,
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Scolor.secondry),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height * 0.25,
            width: height * 0.25,
            child: Image.asset(image),
          ),
          SizedBox(height: height * 0.05),
          Text(
            title,
            style: TextStyle(
              fontSize: height * 0.11,
              fontWeight: FontWeight.bold,
              color: Scolor.secondry,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: height * 0.05),
          Text(
            amount,
            style: TextStyle(
              fontSize: height * 0.14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: height * 0.05),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: height * 0.1,
              color: const Color(0xFF41836B),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _loanTable() {
    return LayoutBuilder(builder: (context, constraints) {
      double tableWidth = MediaQuery.of(context).size.width < 600
          ? MediaQuery.of(context).size.width
          : 700;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: tableWidth * 1.2,
          child: Column(
            children: [
              Container(
                color: Scolor.secondry,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    _tableHeader("Lender"),
                    _tableHeader("Type"),
                    _tableHeader("Total Amount"),
                    _tableHeader("Remaining"),
                    _tableHeader("Monthly"),
                  ],
                ),
              ),
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                      child: CircularProgressIndicator(color: Scolor.secondry)),
                )
              else if (error != null)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                )
              else if (userLoans.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "No active loans found",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...userLoans.map((loan) => _loanRow(
                      loan['Lender_Name'] ?? 'Unknown',
                      loan['Loan_Type'] ?? 'Unknown',
                      "₹${_formatCurrency((loan['Total_Loan_Amount'] ?? 0).toDouble())}",
                      "₹${_formatCurrency((loan['Remaining_Loan_Amount'] ?? 0).toDouble())}",
                      "₹${_formatCurrency((loan['Monthly_Payment'] ?? 0).toDouble())}",
                    )),
            ],
          ),
        ),
      );
    });
  }

  Widget _tableHeader(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _loanRow(String lender, String loanType, String totalAmount,
      String remaining, String monthly) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white24, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              lender,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: Text(
              loanType,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              totalAmount,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.amber,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              remaining,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              monthly,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _schemeCard(double height, double width, String heading, String image,
      bool isGovernment) {
    final schemes = isGovernment ? recommendedLoans : privateSchemes;
    return Container(
      height: height * 0.22,
      width: width * 0.55,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Scolor.secondry),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                height: height * 0.03,
                width: height * 0.03,
                child: Image.asset(image),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  heading,
                  style: TextStyle(
                    fontSize: height * 0.035,
                    fontWeight: FontWeight.bold,
                    color: Scolor.secondry,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: height * 0.01),
          Expanded(
            child: schemes.isEmpty
                ? Center(
                    child: Text(
                      isGovernment
                          ? "No Government Schemes."
                          : "No Private Schemes.",
                      style: TextStyle(
                          color: Colors.white70, fontSize: height * 0.03),
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.zero,
                    children: schemes.take(4).map<Widget>((scheme) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 4),
                        child: Text(
                          "• ${scheme['name'] ?? (isGovernment ? "Government Scheme" : "Private Scheme")}",
                          style: TextStyle(
                            fontSize: height * 0.028,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class BottomContainer extends StatelessWidget {
  final double width;
  final double height;
  final String heading;

  const BottomContainer(
      {required this.width,
      required this.height,
      required this.heading,
      super.key});

  @override
  Widget build(BuildContext context) {
    final fontSize = width * 0.045 > 16 ? 16 : width * 0.045;
    return Container(
      width: width * 1,
      height: height * 0.1,
      decoration: BoxDecoration(
        border: Border.all(color: Scolor.secondry),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          heading,
          style: TextStyle(
            // fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
