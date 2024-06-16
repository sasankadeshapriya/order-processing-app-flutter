import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:order_processing_app/models/sales_invoice.dart';
import 'package:order_processing_app/services/invoice_api_service.dart';
import 'package:intl/intl.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/widgets/bar_chart_widget.dart';
import 'package:order_processing_app/widgets/pie_chart_widget.dart';

class SalesReport extends StatefulWidget {
  const SalesReport({super.key});

  @override
  State<SalesReport> createState() => _SalesReportState();
}

class _SalesReportState extends State<SalesReport> {
  String selectedPeriod = 'Today';
  List<SalesInvoice> allInvoices = [];
  Map<String, Map<String, dynamic>> productData = {};
  bool isLoading = true;
  bool showQuantity = true; // Toggle between quantity and total sales

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      allInvoices = await InvoiceService.fetchInvoicesByEmployeeId(1);
      filterInvoices();
      isLoading = false;
    } catch (error) {
      print('Error fetching data: $error');
      isLoading = false;
    } finally {
      setState(() {});
    }
  }

  void filterInvoices() {
    DateTime now = DateTime.now();
    DateTime startOfPeriod;
    DateTime endOfPeriod;

    switch (selectedPeriod) {
      case 'Today':
        startOfPeriod = DateTime(now.year, now.month, now.day);
        endOfPeriod = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'Last 7 Days':
        startOfPeriod = now.subtract(const Duration(days: 6));
        endOfPeriod = now;
        break;
      case 'Last 30 Days':
        startOfPeriod = now.subtract(const Duration(days: 29));
        endOfPeriod = now;
        break;
      default:
        startOfPeriod = now;
        endOfPeriod = now;
        break;
    }

    productData.clear();
    for (var invoice in allInvoices) {
      DateTime invoiceDate = invoice.createdAt;
      if (invoiceDate.isAfter(startOfPeriod) &&
          invoiceDate.isBefore(endOfPeriod)) {
        for (var detail in invoice.invoiceDetails) {
          String key =
              "${detail.product.name} (${detail.product.measurementUnit})";
          if (!productData.containsKey(key)) {
            productData[key] = {'quantity': 0.0, 'total': 0.0};
          }
          productData[key]!['quantity'] += detail.quantity;
          productData[key]!['total'] += detail.sum;
        }
      }
    }
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
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Sales Report for $selectedPeriod',
          style: const TextStyle(
            color: Color(0xFF464949),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            fontFamily: 'SF Pro Text',
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 150, top: 20, left: 15, bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColor
                                    .widgetStroke, // Adjust color as needed
                                width: 1.0, // Adjust border width as needed
                              ),
                              borderRadius: BorderRadius.circular(
                                  8), // Border radius is 8
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 0), // Padding inside the container
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedPeriod,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      selectedPeriod = newValue;
                                      filterInvoices();
                                    });
                                  }
                                },
                                items: <String>[
                                  'Today',
                                  'Last 7 Days',
                                  'Last 30 Days'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: AppColor.primaryTextColor,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showQuantity = true;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: showQuantity
                                      ? const Color.fromARGB(17, 200, 180, 0)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                      14), // Set border radius to 14
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12), // Adjust padding as needed
                                child: Text(
                                  'Quantity',
                                  style: TextStyle(
                                    color: showQuantity
                                        ? AppColor.accentColor
                                        : AppColor.primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    letterSpacing: 1,
                                    fontFamily: 'SF Pro Text',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showQuantity = false;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !showQuantity
                                      ? const Color.fromARGB(17, 200, 180, 0)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                      14), // Adding a border radius of 14 for rounded corners
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal:
                                        12), // Adjusting padding to wrap the text better
                                child: Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    color: !showQuantity
                                        ? AppColor.accentColor
                                        : AppColor.primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    letterSpacing: 1,
                                    fontFamily: 'SF Pro Text',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    height: 200,
                    child: productData.isNotEmpty
                        ? BarChartWidget(
                            dataMap: productData.map((key, value) => MapEntry(
                                key,
                                showQuantity
                                    ? value['quantity']
                                    : value['total'])),
                            colorList: _colors)
                        : const Text(
                            'No data available for this period',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, top: 20),
                    child: productData.isNotEmpty
                        ? SizedBox(
                            height: 200,
                            child: PieChartWidget(
                              dataMap: productData.map((key, value) => MapEntry(
                                  key,
                                  showQuantity
                                      ? value['quantity']
                                      : value['total'])),
                              colorList: _colors,
                            ),
                          )
                        : const SizedBox(
                            height: 200,
                            child: Center(
                              child: Text(
                                'No data available for this period',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: buildDataTable(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildDataTable() {
    final columns = ['Product Name', 'Units Sold', 'Total Sales Amount'];
    return DataTable(
      columns: columns
          .map((String column) => DataColumn(
                  label: Text(
                column,
                style: const TextStyle(
                  color: AppColor.primaryTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontFamily: 'SF Pro Text',
                ),
              )))
          .toList(),
      rows: productData.entries.map((entry) {
        return DataRow(
          cells: [
            DataCell(Text(
              entry.key,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: AppColor.primaryTextColor,
              ),
            )),
            DataCell(Text(
              entry.value['quantity'].toStringAsFixed(2),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.normal,
                fontSize: 13,
                color: AppColor.placeholderTextColor,
              ),
            )),
            DataCell(Text(
              'LKR ${entry.value['total'].toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.normal,
                fontSize: 13,
                color: AppColor.placeholderTextColor,
              ),
            )),
          ],
        );
      }).toList(),
    );
  }

  final List<Color> _colors = [
    const Color.fromARGB(255, 255, 204, 0), // Bright sunflower yellow
    const Color.fromARGB(255, 255, 255, 102), // Light yellow
    const Color.fromARGB(255, 255, 140, 0), // Darker orange-yellow
    const Color.fromARGB(255, 255, 222, 173), // Light peach
    const Color.fromARGB(255, 255, 165, 0), // Orange
    const Color.fromARGB(255, 255, 215, 0), // Gold
    const Color.fromARGB(255, 255, 255, 224), // Light pale yellow
    const Color.fromARGB(255, 255, 69, 0), // Red-orange
    const Color.fromARGB(255, 255, 239, 213), // Papaya whip
    const Color.fromARGB(255, 255, 228, 181), // Moccasin
  ];
}
