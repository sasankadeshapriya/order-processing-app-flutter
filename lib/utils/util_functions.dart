import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Ensure you have this import for DateFormat

class UtilFunctions {
  static void navigateTo(BuildContext context, Widget widget) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
  }

  static String getCurrentDateTime() {
    DateTime now = DateTime.now();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
  }
}
