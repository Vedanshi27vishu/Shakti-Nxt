import 'package:flutter/material.dart';
import 'package:get/get.dart';

class THelperFunctions {
  /// Get color based on string value
  static Color? getColor(String value) {
    switch (value.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'pink':
        return Colors.pink;
      case 'grey':
        return Colors.grey;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'indigo':
        return Colors.indigo;
      default:
        return null;
    }
  }

  /// Show a snack bar message
  static void showSnackBar(String message) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  /// Show an alert dialog
  static void showAlert(String title, String message) {
    if (Get.context != null) {
      showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  /// Navigate to a new screen
  static void navigateToScreen(Widget screen) {
    if (Get.context != null) {
      Navigator.push(
        Get.context!,
        MaterialPageRoute(builder: (_) => screen),
      );
    }
  }

  /// Truncate text if it exceeds a given length
  static String truncateText(String text, int maxLength) {
    return text.length <= maxLength
        ? text
        : '${text.substring(0, maxLength)}...';
  }

  /// Check if the current theme mode is dark
  static bool isDarkMode() {
    return Get.context != null &&
        Theme.of(Get.context!).brightness == Brightness.dark;
  }

  /// Get screen size using BuildContext
  static Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Get screen width using BuildContext
  static double screenWidth(BuildContext context) {
    return screenSize(context).width;
  }

  /// Get screen height using BuildContext
  static double screenHeight(BuildContext context) {
    return screenSize(context).height;
  }

  /// Remove duplicates from a list
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }
}
