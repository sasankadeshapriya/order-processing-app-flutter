import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Ensure you have this import for DateFormat

class UtilFunctions {
  static void navigateTo(BuildContext context, Widget widget) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
  }

  static String getCurrentDateTime({bool includeTime = false}) {
    DateTime now = DateTime.now();
    // Determine the format based on includeTime
    String formatString = includeTime ? 'yyyy-MM-dd HH:mm:ss' : 'yyyy-MM-dd';
    return DateFormat(formatString).format(now);
  }
}
