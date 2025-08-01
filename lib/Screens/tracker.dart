import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfitData {
  final String month;
  final String monthName;
  final double profit;

  ProfitData({
    required this.month,
    required this.monthName,
    required this.profit,
  });

  factory ProfitData.fromJson(Map<String, dynamic> json) {
    return ProfitData(
      month: json['month'],
      monthName: json['monthName'],
      profit: json['profit'].toDouble(),
    );
  }
}

class ApiResponse {
  final List<ProfitData> last6MonthsProfits;

  ApiResponse({required this.last6MonthsProfits});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    var list = json['last6MonthsProfits'] as List;
    List<ProfitData> profitsList =
        list.map((i) => ProfitData.fromJson(i)).toList();
    return ApiResponse(last6MonthsProfits: profitsList);
  }
}

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  List<FlSpot> chartData = [];
  List<String> months = [];
  bool isLoading = true;
  double maxY = 3000;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://65.2.82.85:5000/api/profits/last-6-months'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(json.decode(response.body));
        processApiData(apiResponse.last6MonthsProfits);
      } else if (response.statusCode == 403) {
        print('403 Forbidden: Falling back to zero data...');
        useZeroFallbackData();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load data. Showing fallback.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      useFallbackData();
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> refreshData() async {
    setState(() {
      isLoading = true;
    });
    await loadData();
  }

  void processApiData(List<ProfitData> profitData) {
    chartData.clear();
    months.clear();

    double maxProfit = 0;
    for (var data in profitData) {
      if (data.profit > maxProfit) {
        maxProfit = data.profit;
      }
    }

    maxY = maxProfit * 1.2;

    for (int i = 0; i < profitData.length; i++) {
      chartData.add(FlSpot(i.toDouble(), profitData[i].profit));
      months.add(profitData[i].monthName.substring(0, 3));
    }
  }

  void useFallbackData() {
    chartData = [
      const FlSpot(0, 650),
      const FlSpot(1, 1300),
      const FlSpot(2, 1550),
      const FlSpot(3, 1750),
      const FlSpot(4, 2100),
      const FlSpot(5, 2600),
    ];
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'June'];
    maxY = 3000;
  }

  void useZeroFallbackData() {
    chartData = [
      const FlSpot(0, 0),
      const FlSpot(1, 0),
      const FlSpot(2, 0),
      const FlSpot(3, 0),
      const FlSpot(4, 0),
      const FlSpot(5, 0),
    ];
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'June'];
    maxY = 100;
  }

  @override
  Widget build(BuildContext context) {
    // --- Only these lines make it responsive like login! ---
    double screenWidth = MediaQuery.of(context).size.width;
    double contentMaxWidth;
    if (screenWidth < 600) {
      contentMaxWidth = screenWidth;
    } else if (screenWidth < 1000) {
      contentMaxWidth = 700;
    } else {
      contentMaxWidth = 900;
    }
    //--------------------------------------------------------

    return Scaffold(
      backgroundColor: Scolor.primary,
      appBar: AppBar(
        backgroundColor: Scolor.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Scolor.secondry, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tracker-',
          style: TextStyle(
            color: Scolor.white,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Scolor.white),
            onPressed: refreshData,
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: contentMaxWidth,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                'Track Your Growth',
                style: TextStyle(
                  color: Scolor.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 3,
                width: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color.fromARGB(255, 245, 194, 7), Scolor.secondry],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34495E).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF34495E),
                      width: 1,
                    ),
                  ),
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Scolor.secondry,
                          ),
                        )
                      : LineChart(
                          LineChartData(
                            backgroundColor: Colors.transparent,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              drawHorizontalLine: true,
                              horizontalInterval: maxY / 5,
                              verticalInterval: 1,
                              getDrawingHorizontalLine: (_) => const FlLine(
                                color: Color(0xFF34495E),
                                strokeWidth: 1,
                              ),
                              getDrawingVerticalLine: (_) => const FlLine(
                                color: Color(0xFF34495E),
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 1,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    if (value.toInt() >= 0 &&
                                        value.toInt() < months.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          months[value.toInt()],
                                          style: const TextStyle(
                                            color: Scolor.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: maxY / 5,
                                  reservedSize: 80,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    String formattedValue;
                                    if (value >= 1000000) {
                                      formattedValue =
                                          '${(value / 1000000).toStringAsFixed(1)}M';
                                    } else if (value >= 1000) {
                                      formattedValue =
                                          '${(value / 1000).toStringAsFixed(0)}K';
                                    } else {
                                      formattedValue = value.toInt().toString();
                                    }

                                    return Text(
                                      formattedValue,
                                      style: const TextStyle(
                                        color: Scolor.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            minX: 0,
                            maxX: (chartData.length - 1).toDouble(),
                            minY: 0,
                            maxY: maxY,
                            lineBarsData: [
                              LineChartBarData(
                                spots: chartData,
                                isCurved: true,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 245, 194, 7),
                                    Scolor.secondry,
                                  ],
                                ),
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color: Scolor.secondry,
                                      strokeWidth: 2,
                                      strokeColor: Scolor.white,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      const Color.fromARGB(255, 245, 194, 7)
                                          .withOpacity(0.3),
                                      const Color.fromARGB(255, 245, 194, 7)
                                          .withOpacity(0.1),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
