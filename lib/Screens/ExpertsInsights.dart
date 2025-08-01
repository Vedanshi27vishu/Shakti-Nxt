import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shakti/Screens/videoplayer.dart';
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shakti/Widgets/AppWidgets/ScreenHeadings.dart';
import 'package:shakti/Widgets/AppWidgets/YellowLine.dart';
import 'package:shakti/helpers/helper_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinancialInsightsScreen extends StatefulWidget {
  const FinancialInsightsScreen({super.key});

  @override
  State<FinancialInsightsScreen> createState() => _FinancialInsightsScreenState();
}

class _FinancialInsightsScreenState extends State<FinancialInsightsScreen> {
  late Future<List<VideoInsight>> _insightsFuture;

  @override
  void initState() {
    super.initState();
    _insightsFuture = fetchInsights();
  }

  Future<List<VideoInsight>> fetchInsights() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('http://65.2.82.85:5000/videos'),
      headers: {'Authorization': 'Bearer ${token ?? ''}'},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => VideoInsight.fromJson(item)).toList();
    } else {
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      throw Exception('Failed to load insights');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder for adaptive max width & sizes
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
      body: LayoutBuilder(builder: (context, constraints) {
        double maxWidth;
        double screenWidth = constraints.maxWidth;
        double screenHeight = THelperFunctions.screenHeight(context);

        // Set max width breakpoints (you can adjust values)
        if (screenWidth < 600) {
          maxWidth = double.infinity; // mobile - full width
        } else if (screenWidth < 992) {
          maxWidth = 650; // tablet
        } else {
          maxWidth = 900; // desktop/laptop
        }

        // Sizes and paddings adapting with breakpoints
        double horizontalPadding = maxWidth == double.infinity ? 16 : 24;
        double thumbnailWidth = maxWidth == double.infinity
            ? screenWidth * 0.45
            : maxWidth * 0.3; // smaller on wider screens
        double thumbnailHeight = thumbnailWidth * 0.5; // retain aspect ratio

        double titleFontSize;
        double channelFontSize;
        double publishedAtFontSize;

        if (screenWidth < 600) {
          titleFontSize = 16;
          channelFontSize = 12;
          publishedAtFontSize = 10;
        } else if (screenWidth < 992) {
          titleFontSize = 18;
          channelFontSize = 14;
          publishedAtFontSize = 12;
        } else {
          titleFontSize = 20;
          channelFontSize = 16;
          publishedAtFontSize = 14;
        }

        return Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            width: maxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScreenHeadings(text: "Experts insights for financial business-"),
                SizedBox(height: screenHeight * 0.01),
                Yellowline(screenWidth: screenWidth),
                SizedBox(height: screenHeight * 0.01),
                Expanded(
                  child: FutureBuilder<List<VideoInsight>>(
                    future: _insightsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No insights available.'));
                      }

                      final insights = snapshot.data!;

                      return ListView.builder(
                        itemCount: insights.length,
                        itemBuilder: (context, index) {
                          final item = insights[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VideoWebViewScreen(url: item.link),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.amber, width: 1.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item.thumbnail,
                                        width: thumbnailWidth,
                                        height: thumbnailHeight,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            Image.asset('assets/default.png', width: thumbnailWidth, height: thumbnailHeight, fit: BoxFit.cover),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: titleFontSize,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            item.channel,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: channelFontSize,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            item.publishedAt,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: publishedAtFontSize,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// Model class
class VideoInsight {
  final String title;
  final String thumbnail;
  final String channel;
  final String link;
  final String publishedAt;

  VideoInsight(
      {required this.title,
      required this.thumbnail,
      required this.channel,
      required this.publishedAt,
      required this.link});
  factory VideoInsight.fromJson(Map<String, dynamic> json) {
    return VideoInsight(
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      channel: json['channelTitle'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      link: json['videoUrl'] ?? '',
    );
  }
}
