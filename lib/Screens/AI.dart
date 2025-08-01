import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shakti/Utils/constants/colors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Advice AI',
      home: BusinessAdvicePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BusinessAdvicePage extends StatefulWidget {
  @override
  _BusinessAdvicePageState createState() => _BusinessAdvicePageState();
}

class _BusinessAdvicePageState extends State<BusinessAdvicePage> {
  TextEditingController queryController = TextEditingController();
  String responseText = '';
  bool isLoading = false;

  // Replace with your real Gemini API key
  final String apiKey = 'AIzaSyC8rJwNfHjl_PJEcf0cjrSvoa8yR6gb2lE'; // Your actual API key

  Future<void> getBusinessAdvice(String query, String language) async {
    setState(() {
      isLoading = true;
      responseText = '';
    });

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
    );

    final headers = {'Content-Type': 'application/json'};

    final prompt = "Give business advice on: \"$query\" in $language language.";

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    });

    try {
      final res = await http.post(url, headers: headers, body: body);

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final reply = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];

        setState(() {
          responseText = reply ?? "No response found.";
          isLoading = false;
        });
      } else {
        setState(() {
          responseText = "❌ Error: ${res.statusCode}\n${res.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        responseText = "⚠️ Failed to fetch response: $e";
        isLoading = false;
      });
    }
  }

  String selectedLang = 'English';
  List<String> languages = ['English', 'Hindi', 'Gujarati', 'Tamil', 'Bengali'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Business AI Advisor', style: TextStyle(color: Colors.white)),
        backgroundColor: Scolor.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = MediaQuery.of(context).size.height;

          // Define max content width based on breakpoints
          double maxWidth;
          if (screenWidth < 600) {
            maxWidth = double.infinity; // mobile - full width
          } else if (screenWidth < 1000) {
            maxWidth = 600; // tablet
          } else {
            maxWidth = 700; // desktop/laptop
          }

          // Dynamic paddings and font sizes per device
          final horizontalPadding = maxWidth == double.infinity ? 16.0 : 24.0;
          final buttonFontSize = screenWidth < 600 ? 16.0 : 18.0;
          final responseFontSize = screenWidth < 600 ? 14.0 : 16.0;
          final inputFontSize = screenWidth < 600 ? 14.0 : 16.0;
          final spacing = screenHeight * 0.02;

          return Center(
            child: Container(
              color: Color.fromARGB(255, 172, 214, 244),
              width: maxWidth,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedLang,
                    items: languages.map((lang) {
                      return DropdownMenuItem<String>(
                        value: lang,
                        child: Text(lang),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedLang = val!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Choose Language',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    style: TextStyle(fontSize: inputFontSize, color: Colors.black87),
                  ),
                  SizedBox(height: spacing),
                  TextField(
                    controller: queryController,
                    decoration: InputDecoration(
                      labelText: 'Enter your business problem or question',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    maxLines: null,
                    style: TextStyle(fontSize: inputFontSize),
                  ),
                  SizedBox(height: spacing),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (queryController.text.isNotEmpty) {
                          getBusinessAdvice(queryController.text, selectedLang);
                        }
                      },
                      child: Text('Get Advice',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: buttonFontSize,
                          )),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Scolor.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing),

                  // Result area: display loading or response text

                  Expanded(
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : responseText.isNotEmpty
                            ? SingleChildScrollView(
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    responseText,
                                    style: TextStyle(
                                      fontSize: responseFontSize,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                'Enter a query and tap Get Advice to see results.',
                                style: TextStyle(fontSize: responseFontSize, color: Colors.grey),
                                textAlign: TextAlign.center,
                              )),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
