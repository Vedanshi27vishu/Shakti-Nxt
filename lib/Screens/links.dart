import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shakti/Widgets/AppWidgets/ScreenHeadings.dart' show ScreenHeadings;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class FinancialLinkInsights extends StatefulWidget {
  const FinancialLinkInsights({super.key});

  @override
  State<FinancialLinkInsights> createState() => _FinancialInsightsScreenState();
}

class _FinancialInsightsScreenState extends State<FinancialLinkInsights> {
  late Future<List<LinkInsight>> _insightsFuture;

  @override
  void initState() {
    super.initState();
    _insightsFuture = fetchLinks();
  }

  Future<List<LinkInsight>> fetchLinks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('http://65.2.82.85:5000/search'),
      headers: {'Authorization': 'Bearer ${token ?? ''}'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> results = jsonData['results'];
      final String businessSector = jsonData['businessSector'] ?? 'Finance';

      return results
          .map((item) => LinkInsight.fromJson(item, businessSector))
          .toList();
    } else {
      throw Exception('Failed to load insights');
    }
  }

  void _launchUrl(String url) async {
    if (!url.startsWith('http')) url = 'https://$url';
    final uri = Uri.parse(url);

    try {
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // Fallback to in-app browser view
        launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }

      if (!launched) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open the link: $url'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Scolor.primary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Scolor.secondry),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Scolor.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // Responsive body container
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;

          // Define max container width based on the breakpoint
          double maxWidth;
          if (screenWidth < 600) {
            maxWidth = double.infinity; // mobile
          } else if (screenWidth < 1000) {
            maxWidth = 700; // tablet
          } else {
            maxWidth = 900; // desktop
          }

          // Adaptive paddings and font sizes
          double horizontalPadding = maxWidth == double.infinity ? 16 : 24;
          double cardPadding = maxWidth == double.infinity ? 12 : 16;
          double titleFontSize;
          double snippetFontSize;
          double linkFontSize;
          if (screenWidth < 600) {
            titleFontSize = 16;
            linkFontSize = 13;
            snippetFontSize = 13;
          } else if (screenWidth < 1000) {
            titleFontSize = 18;
            linkFontSize = 14;
            snippetFontSize = 14;
          } else {
            titleFontSize = 20;
            linkFontSize = 15;
            snippetFontSize = 15;
          }

          return Center(
            child: Container(
              width: maxWidth,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
              child: FutureBuilder<List<LinkInsight>>(
                future: _insightsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red))
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No insights available.', style: TextStyle(color: Colors.white)));
                  }

                  final insights = snapshot.data!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ScreenHeadings(text: "Experts insights for financial business-"),
                      Divider(color: Colors.amber),
                      Expanded(
                        child: ListView.builder(
                          itemCount: insights.length,
                          itemBuilder: (context, index) {
                            final item = insights[index];
                            return GestureDetector(
                              onTap: () => _launchUrl(item.link),
                              child: Card(
                                color: Scolor.primary,
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(color: Colors.amber),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(cardPadding),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: titleFontSize,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        item.link,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: linkFontSize,
                                          color: Colors.amberAccent,
                                          decoration: TextDecoration.underline,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        item.snippet,
                                        style: TextStyle(
                                          fontSize: snippetFontSize,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class LinkInsight {
  final String title;
  final String link;
  final String snippet;
  final String businessSector;

  LinkInsight({
    required this.title,
    required this.link,
    required this.snippet,
    required this.businessSector,
  });

  factory LinkInsight.fromJson(Map<String, dynamic> json, String sector) {
    return LinkInsight(
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      snippet: json['snippet'] ?? '',
      businessSector: sector,
    );
  }
}
