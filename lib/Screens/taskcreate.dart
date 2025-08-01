import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shakti/Utils/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskCreateScreen extends StatefulWidget {
  const TaskCreateScreen({super.key});

  @override
  _TaskCreateScreenState createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends State<TaskCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _priority = 'Medium';

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? DateTime.now() : (_startDate ?? DateTime.now()),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Scolor.secondry,
              onPrimary: Scolor.dark,
              surface: Scolor.primary,
              onSurface: Scolor.white,
            ),
            dialogBackgroundColor: Scolor.primary,
            dialogTheme: const DialogTheme(shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            )),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Reset end date if it's before start date
          if (_endDate != null && _endDate!.isBefore(picked)) _endDate = null;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _createTask() async {
    if (_formKey.currentState!.validate() && _startDate != null && _endDate != null) {
      final url = Uri.parse('http://65.2.82.85:5000/tasks/create');

      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🔐 Token not found. Please login again.")),
        );
        return;
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'startDate': DateFormat('yyyy-MM-dd').format(_startDate!),
          'endDate': DateFormat('yyyy-MM-dd').format(_endDate!),
          'priority': _priority,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Task Created Successfully")),
        );
        Navigator.pop(context);
      } else {
        final res = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed: ${res['message']}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❗ Please fill all fields")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1125),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Create Task", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Scolor.secondry),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow.shade700,
        onPressed: _createTask,
        child: const Icon(Icons.check, color: Colors.black),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Set max width for tablet and desktop for better readability
            double maxWidth;
            if (constraints.maxWidth < 600) {
              maxWidth = constraints.maxWidth; // Full width on mobile
            } else if (constraints.maxWidth < 1000) {
              maxWidth = 600; // Max width for tablets
            } else {
              maxWidth = 700; // Max width for desktops
            }

            // Define dynamic paddings and font sizes
            final horizontalPadding = maxWidth < 600 ? 20.0 : 32.0;
            final inputFontSize = maxWidth < 600 ? 14.0 : 16.0;
            final labelFontSize = maxWidth < 600 ? 14.0 : 16.0;
            final buttonHeight = 48.0;

            return Container(
              width: maxWidth,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.12),
                  children: [
                    buildInput("Task Title", _titleController,
                        fontSize: inputFontSize, labelFontSize: labelFontSize),
                    const SizedBox(height: 16),
                    buildInput("Description", _descriptionController,
                        fontSize: inputFontSize,
                        labelFontSize: labelFontSize,
                        maxLines: 3),
                    const SizedBox(height: 16),
                    buildDatePicker("Start Date", _startDate, () => _pickDate(context, true),
                        fontSize: inputFontSize, labelFontSize: labelFontSize),
                    const SizedBox(height: 16),
                    buildDatePicker("End Date", _endDate, () => _pickDate(context, false),
                        fontSize: inputFontSize, labelFontSize: labelFontSize),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _priority,
                      dropdownColor: const Color(0xFF1E1E2F),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1E1E2F),
                        labelText: 'Priority',
                        labelStyle: TextStyle(color: Colors.white, fontSize: labelFontSize),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      style: TextStyle(color: Colors.white, fontSize: inputFontSize),
                      items: ['Low', 'Medium', 'High']
                          .map(
                            (level) => DropdownMenuItem(
                              value: level,
                              child: Text(level, style: const TextStyle(color: Colors.white)),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _priority = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: _createTask,
                        child: Text('Create Task',
                            style: TextStyle(fontSize: inputFontSize, color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildInput(String label, TextEditingController controller,
      {int maxLines = 1, double fontSize = 14, double labelFontSize = 14}) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white, fontSize: fontSize),
      maxLines: maxLines,
      validator: (val) => val == null || val.trim().isEmpty ? '$label is required' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white, fontSize: labelFontSize),
        filled: true,
        fillColor: const Color(0xFF1E1E2F),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
    );
  }

  Widget buildDatePicker(String label, DateTime? date, VoidCallback onTap,
      {double fontSize = 14, double labelFontSize = 14}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2F),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date != null ? DateFormat('yyyy-MM-dd').format(date) : label,
                style: TextStyle(color: Colors.white, fontSize: fontSize),
              ),
            ),
            Icon(Icons.calendar_today, color: Colors.yellow.shade700, size: fontSize + 6),
          ],
        ),
      ),
    );
  }
}
