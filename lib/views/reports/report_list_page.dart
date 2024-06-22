import 'package:flutter/material.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/views/reports/emp_sales_report.dart';
import 'package:order_processing_app/views/reports/salesreport.dart';

class ReportList extends StatefulWidget {
  const ReportList({super.key});

  @override
  State<ReportList> createState() => _ReportListState();
}

class _ReportListState extends State<ReportList> {
  // Method to create a reusable interactive container widget with navigation functionality
  Widget _buildReportContainer(String reportName, VoidCallback onTap) {
    return Container(
      width: 325,
      height: 50,
      clipBehavior:
          Clip.antiAlias, // Ensuring proper clipping for ripple effect
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColor.widgetStroke,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: const Color(0xFF565656), // Move the color to Material
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
              14), // Match the border radius with the container
          child: Container(
            padding:
                const EdgeInsets.only(left: 18, top: 12, bottom: 12, right: 18),
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(28, 0, 0, 0),
                  spreadRadius: 10,
                  offset: Offset(10, 24),
                  blurRadius: 54,
                )
              ],
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                reportName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontFamily: 'SF Pro Text',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColor.primaryTextColor,
              size: 15,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: const Text(
          "Reports",
          style: TextStyle(
            color: Color(0xFF464949),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            fontFamily: 'SF Pro Text',
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              _buildReportContainer("Sales Report", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const SalesReport(), // Ensure this page exists
                  ),
                );
              }),
              const SizedBox(height: 10),
              _buildReportContainer("Cash / Credit Sales", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const EmpSalesReport(), // Ensure this page exists
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
