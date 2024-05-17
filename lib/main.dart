import 'package:flutter/material.dart';
import 'package:order_processing_app/components/card_invoice.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/views/assignment/assignment_list.dart';
import 'package:order_processing_app/views/invoice/invoice_list_page.dart';
import 'package:order_processing_app/views/main/dashboard.dart';
import 'package:order_processing_app/views/map/map_page.dart';
import 'package:order_processing_app/views/splash/splashscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColor.backgroundColor,
      ),
      home: const UserDashboard(),
    );
  }
}
