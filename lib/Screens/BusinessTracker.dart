import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shakti/Screens/Budget_insights.dart';
import 'package:shakti/Utils/constants/colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ComparativeTrackerScreen extends StatefulWidget {
  const ComparativeTrackerScreen({super.key});

  @override
  State<ComparativeTrackerScreen> createState() =>
      _ComparativeTrackerScreenState();
}

class _ComparativeTrackerScreenState extends State<ComparativeTrackerScreen> {
  List<double> currentMonthData = [];
  List<double> nextMonthData = [];
  List<String> monthLabels = [
    'COGs',
    'Salaries',
    'Maintenance',
    'Marketing',
    'Investment'
  ];

  String currentMonthValue = '0';
  String currentMonthGrowth = '0%';
  String projectedValue = '0';
  String projectedGrowth = '0%';
  String businessType = 'Business';

  bool isLoading = true;

  final TextEditingController _profitController = TextEditingController();
  bool _isPredictingBudget = false;
  String _predictedBudget = '';
  Map<String, dynamic>? insights;

  @override
  void initState() {
    super.initState();
    fetchInsights();
    loadExpenditureData();
  }

  Future<void> fetchInsights() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('http://65.2.82.85:5000/api/business/insights'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;

        if (mounted) {
          setState(() {
            insights = jsonData;
          });
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> loadExpenditureData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://65.2.82.85:5000/api/last-two-expenditures'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final apiResponse = ApiResponse.fromJson(data);

        if (mounted) {
          if (apiResponse.expenditures.isNotEmpty) {
            processExpenditureData(apiResponse.expenditures.first);
          }
          setState(() {
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        useFallback();
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void useFallback() {
    if (mounted) {
      setState(() {
        currentMonthData = [2000, 1500, 1200, 800, 1800];
        nextMonthData = [2200, 1600, 1300, 900, 1900];
        monthLabels = [
          'COGs',
          'Salaries',
          'Maintenance',
          'Marketing',
          'Investment'
        ];
        currentMonthValue = '727500';
        currentMonthGrowth = '6.2%';
        projectedValue = '940000';
        projectedGrowth = '9.6%';
        businessType = 'BUSINESS';
      });
    }
  }

  Future<void> _predictBudget() async {
    if (_profitController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter current month profit'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isPredictingBudget = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      String sector = businessType.toLowerCase();

      final response = await http.post(
        Uri.parse('http://65.2.82.85:5000/api/predict-budget/$sector'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'newProfit': double.parse(_profitController.text)}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _predictedBudget = responseData['predictedBudget']?.toString() ?? '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to predict budget: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to predict budget: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isPredictingBudget = false;
      });
    }
  }

  void processExpenditureData(BusinessExpenditure data) {
    if (data.lastTwoExpenditures.length >= 2) {
      final first = data.lastTwoExpenditures[0];
      final second = data.lastTwoExpenditures[1];

      currentMonthData = [
        first.cogs,
        first.salaries,
        first.maintenance,
        first.marketing,
        first.investment
      ];
      nextMonthData = [
        second.cogs,
        second.salaries,
        second.maintenance,
        second.marketing,
        second.investment
      ];

      final double currentTotal = first.total;
      final double nextTotal = second.total;
      final double growth = ((nextTotal - currentTotal) / currentTotal) * 100;

      if (mounted) {
        setState(() {
          businessType = data.businessType.toUpperCase();
          currentMonthValue = currentTotal.toInt().toString();
          projectedValue = nextTotal.toInt().toString();
          currentMonthGrowth = '${growth.toStringAsFixed(1)}%';
          projectedGrowth =
              '${(growth + 2).toStringAsFixed(1)}%'; // simple projection increase
        });
      }
    }
  }

  double maxY = 0;

  double _getMaxYValue() {
    if (currentMonthData.isEmpty && nextMonthData.isEmpty) return 3000;
    return [...currentMonthData, ...nextMonthData]
        .reduce((a, b) => a > b ? a : b);
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(monthLabels.length, (i) {
      final currVal = (currentMonthData.length > i) ? currentMonthData[i] : 0;
      final nextVal = (nextMonthData.length > i) ? nextMonthData[i] : 0;

      return BarChartGroupData(
        x: i,
        // barRods: [
        //   BarChartRodData(
        //       toY: currentMonthData.isNotEmpty ? currentMonthData[index] : 0,
        //       width: 16,
        //       color: const Color(0xFF95A5A6),
        //       borderRadius: BorderRadius.zero),
        //   BarChartRodData(
        //       toY: nextMonthData.isNotEmpty ? nextMonthData[index] : 0,
        //       width: 16,
        //       color: Scolor.secondry,
        //       borderRadius: BorderRadius.zero),
        // ],
        barsSpace: 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;

    return Scaffold(
        backgroundColor: Scolor.primary,
        appBar: PreferredSize(
          
          preferredSize: const Size.fromHeight(56),
          child: LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;

            double titleFont;
            double iconSize;
            double horizontalPad;

            if (width < 600) {
              titleFont = screenHeight * 0.033;
              iconSize = 26;
              horizontalPad = 0;
            } else if (width < 1000) {
              titleFont = 22;
              iconSize = 30;
              horizontalPad = 10;
            } else {
              titleFont = 26;
              iconSize = 36;
              horizontalPad = 30;
            }

            return AppBar(
              leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Scolor.secondry),
          onPressed: () => Navigator.pop(context),
        ),
              automaticallyImplyLeading: false,
              backgroundColor: Scolor.primary,
              elevation: 0,
              titleSpacing: 0,
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPad),
                child: Text(
                  'Hi, Entrepreneur!',
                  style: TextStyle(
                      fontSize: titleFont,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      overflow: TextOverflow.ellipsis),
                  maxLines: 1,
                ),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: horizontalPad + 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const ComparativeTrackerScreen()));
                    },
                    child: SizedBox(
                      height: iconSize,
                      width: iconSize,
                      child: Image.asset('assets/images/newwallet.png'),
                    ),
                  ),
                )
              ],
            );
          }),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Scolor.secondry))
            : Center(
                child: SingleChildScrollView(
                  child: LayoutBuilder(builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    double maxContentWidth;
                    if (width < 600) {
                      maxContentWidth = width; // full width mobile
                    } else if (width < 1000) {
                      maxContentWidth = 700;
                    } else {
                      maxContentWidth = 900;
                    }

                    // Dynamic paddings and font sizes for section content
                    double greetingFont;
                    double scoreFont;
                    double sectionPadding;

                    if (width < 600) {
                      greetingFont = screenHeight * 0.032;
                      scoreFont = screenHeight * 0.02;
                      sectionPadding = 0;
                    } else if (width < 1000) {
                      greetingFont = 24;
                      scoreFont = 15;
                      sectionPadding = 5;
                    } else {
                      greetingFont = 28;
                      scoreFont = 17;
                      sectionPadding = 10;
                    }

                    double suggestionWidth;
                    if (width < 600) {
                      suggestionWidth = maxContentWidth * 0.9;
                    } else if (width < 1000) {
                      suggestionWidth = 280;
                    } else {
                      suggestionWidth = 300;
                    }

                    return Container(
                      width: maxContentWidth,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Greeting Section
                          Padding(
                            padding: EdgeInsets.only(top: sectionPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  businessType,
                                  style: TextStyle(
                                    fontSize: greetingFont,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: sectionPadding),
                                Text(
                                  'Current Month Profit: $currentMonthValue',
                                  style: TextStyle(
                                    fontSize: scoreFont,
                                    color: Scolor.secondry,
                                  ),
                                ),
                                SizedBox(height: sectionPadding),
                                Text(
                                  'Growth This Month: $currentMonthGrowth',
                                  style: TextStyle(
                                    fontSize: scoreFont,
                                    color: Scolor.secondry,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.03),
                              ],
                            ),
                          ),

                          // Chart Container (fixed height for smooth display)
                          Container(
                            height: 320,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF34495E).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFF34495E), width: 1),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                     _buildLegend('Previous Month', const Color(0xFF95A5A6)),
              const SizedBox(width: 20),
              _buildLegend('Current Month', Scolor.secondry),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: _getMaxYValue() * 1.2,
                                      minY: 0,
                                      barTouchData: BarTouchData(
                                        enabled: true,
                                        touchTooltipData: BarTouchTooltipData(
                                          getTooltipItem: (group, groupIndex,
                                              rod, rodIndex) {
                                            final label =
                                                monthLabels[group.x.toInt()];
                                            final period = rodIndex == 0
                                                ? 'Current'
                                                : 'Projected';
                                            return BarTooltipItem(
                                              '$period Month\n$label: ${rod.toY.round()}',
                                              const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            );
                                          },
                                        ),
                                      ),
                                      titlesData: FlTitlesData(
                                        show: true,
                                        rightTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                        topTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 30,
                                            interval: 1,
                                            getTitlesWidget: (value, meta) {
                                              final idx = value.toInt();
                                              if (idx >= 0 &&
                                                  idx < monthLabels.length) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0),
                                                  child: Text(
                                                    monthLabels[idx],
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                );
                                              }
                                              return const SizedBox.shrink();
                                            },
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 30,
                                            interval: _getMaxYValue() / 5,
                                            getTitlesWidget: (value, meta) {
                                              double val = value;
                                              String text;
                                              if (val >= 1000000) {
                                                text =
                                                    '${(val / 1000000).toStringAsFixed(1)}M';
                                              } else if (val >= 1000) {
                                                text =
                                                    '${(val / 1000).toStringAsFixed(0)}K';
                                              } else {
                                                text = val.toInt().toString();
                                              }
                                              return Text(
                                                text,
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 11,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        drawHorizontalLine: true,
                                        horizontalInterval: _getMaxYValue() / 5,
                                        getDrawingHorizontalLine: (_) => FlLine(
                                          color: const Color(0xFF34495E)
                                              .withOpacity(0.5),
                                          strokeWidth: 1,
                                        ),
                                      ),
                                      barGroups: _buildBarGroups(),
                                      groupsSpace: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Metrics Container
                          _buildMetricsSection(greetingFont, scoreFont),

                          const SizedBox(height: 24),

                          // Profit input section
                          _buildProfitInput(),

                          const SizedBox(height: 24),

                          // Insights section - tapping leads to Budget Insights screen
                          _buildInsightsSection(context),

                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  }),
                ),
              ));
  }

  Widget _buildMetricsSection(double greetingFont, double scoreFont) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          businessType,
          style: TextStyle(
            fontSize: greetingFont,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Current Month Profit: $currentMonthValue',
          style: TextStyle(
            fontSize: scoreFont,
            color: Scolor.secondry,
          ),
        ),
        Text(
          'Growth This Month: $currentMonthGrowth',
          style: TextStyle(
            fontSize: scoreFont,
            color: Scolor.secondry,
          ),
        ),
      ],
    );
  }

  Widget _buildProfitInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF34495E).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF34495E), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Budget Prediction',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _profitController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF34495E).withOpacity(0.5),
              hintText: 'Enter current month profit',
              hintStyle: const TextStyle(color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Scolor.secondry),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isPredictingBudget ? null : _predictBudget,
              style: ElevatedButton.styleFrom(
                backgroundColor: Scolor.secondry,
                foregroundColor: Scolor.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isPredictingBudget
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Scolor.primary,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Predict Budget',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(BuildContext context) {
    final values = insights?.values.toList() ?? [];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BudgetInsights(
                budgetData: values
                    .map((e) => {'title': '', 'description': e.toString()})
                    .toList()),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (values.isNotEmpty) ...[
            _buildFeatureItem(Icons.info_outline, values[0]),
            const SizedBox(height: 12),
            if (values.length > 1)
              _buildFeatureItem(Icons.trending_up, values[1]),
            if (values.length > 2) ...[
              const SizedBox(height: 12),
              _buildFeatureItem(Icons.school_outlined, values[2]),
            ],
          ] else
            const Text('Loading insights...',
                style: TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF34495E).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF34495E), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Scolor.secondry,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: Scolor.primary, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}

// Model classes

class ExpenditureData {
  final double cogs;
  final double salaries;
  final double maintenance;
  final double marketing;
  final double investment;

  ExpenditureData({
    required this.cogs,
    required this.salaries,
    required this.maintenance,
    required this.marketing,
    required this.investment,
  });

  factory ExpenditureData.fromJson(Map<String, dynamic> json) {
    return ExpenditureData(
      cogs: (json['COGs'] as num).toDouble(),
      salaries: (json['Salaries'] as num).toDouble(),
      maintenance: (json['Maintenance'] as num).toDouble(),
      marketing: (json['Marketing'] as num).toDouble(),
      investment: (json['Investment'] as num).toDouble(),
    );
  }

  double get total => cogs + salaries + maintenance + marketing + investment;
}

class BusinessExpenditure {
  final String businessType;
  final List<ExpenditureData> lastTwoExpenditures;

  BusinessExpenditure(
      {required this.businessType, required this.lastTwoExpenditures});

  factory BusinessExpenditure.fromJson(Map<String, dynamic> json) {
    var list = (json['lastTwoExpenditures'] as List)
        .map((e) => ExpenditureData.fromJson(e))
        .toList();
    return BusinessExpenditure(
        businessType: json['businessType'], lastTwoExpenditures: list);
  }
}

class ApiResponse {
  final List<BusinessExpenditure> expenditures;

  ApiResponse({required this.expenditures});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    var list = (json['expenditures'] as List)
        .map((e) => BusinessExpenditure.fromJson(e))
        .toList();
    return ApiResponse(expenditures: list);
  }
}
  Widget _buildLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }