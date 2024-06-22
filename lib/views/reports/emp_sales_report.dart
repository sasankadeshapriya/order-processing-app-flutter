import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:order_processing_app/models/clients_modle.dart';
import 'package:order_processing_app/models/sales_invoice.dart';
import 'package:order_processing_app/services/client_api_service.dart';
import 'package:order_processing_app/services/invoice_api_service.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/widgets/line_chart_widget.dart';

class EmpSalesReport extends StatefulWidget {
  const EmpSalesReport({super.key});

  @override
  _EmpSalesReportState createState() => _EmpSalesReportState();
}

class _EmpSalesReportState extends State<EmpSalesReport> {
  List<SalesInvoice> invoices = [];
  String viewType = 'Weekly'; // Can be 'weekly' or 'Monthly'
  String selectedPaymentOption = 'cash'; // Can be 'cash' or 'credit'
  List<Client> clients = []; // List to hold clients data

  @override
  void initState() {
    super.initState();
    fetchInvoices();
    fetchClients();
  }

  Future<void> fetchInvoices() async {
    try {
      // Replace 1 with the actual employee ID
      List<SalesInvoice> fetchedInvoices =
          await InvoiceService.fetchInvoicesByEmployeeId(1);
      setState(() {
        invoices = fetchedInvoices;
      });
    } catch (e) {
      print('Error fetching invoices: $e');
    }
  }

  Future<void> fetchClients() async {
    try {
      List<Client> fetchedClients = await ClientService.getClients();
      setState(() {
        clients = fetchedClients;
      });
    } catch (e) {
      print('Error fetching clients: $e');
    }
  }

  DateTime _startOfWeek(DateTime date) {
    final day = date.weekday;
    return date.subtract(
        Duration(days: day - 1)); // Get the Monday of the current week
  }

  DateTime _endOfWeek(DateTime date) {
    return _startOfWeek(date)
        .add(const Duration(days: 6)); // Get the Sunday of the current week
  }

  List<SalesInvoice> _filterInvoicesForCurrentWeek(
      List<SalesInvoice> allInvoices) {
    DateTime now = DateTime.now();
    DateTime startOfWeek = _startOfWeek(now);
    DateTime endOfWeek = _endOfWeek(now);

    return allInvoices.where((invoice) {
      return invoice.createdAt
              .isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          invoice.createdAt.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  List<SalesInvoice> _filterInvoicesByPaymentOption(
      List<SalesInvoice> allInvoices, String paymentOption) {
    return allInvoices
        .where((invoice) => invoice.paymentOption == paymentOption)
        .toList();
  }

  Map<String, double> _calculateSalesData(
      List<SalesInvoice> invoices, List<String> periods) {
    Map<String, double> sales = {for (var period in periods) period: 0.0};

    for (var invoice in invoices) {
      String period = periods.firstWhere(
          (p) => DateFormat('EEEE').format(invoice.createdAt) == p,
          orElse: () => '');
      sales[period] = sales[period]! + invoice.totalAmount;
    }

    return sales;
  }

  Map<String, double> getWeeklySales(String paymentOption) {
    List<SalesInvoice> filteredInvoices = _filterInvoicesByPaymentOption(
        _filterInvoicesForCurrentWeek(invoices), paymentOption);

    return _calculateSalesData(filteredInvoices, [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ]);
  }

  Map<String, double> getMonthlySales(String paymentOption) {
    Map<String, double> sales = {
      'January': 0,
      'February': 0,
      'March': 0,
      'April': 0,
      'May': 0,
      'June': 0,
      'July': 0,
      'August': 0,
      'September': 0,
      'October': 0,
      'November': 0,
      'December': 0,
    };

    for (var invoice in invoices) {
      if (invoice.paymentOption == paymentOption) {
        String month = DateFormat('MMMM').format(invoice.createdAt);
        sales[month] = sales[month]! + invoice.totalAmount;
      }
    }

    return sales;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> weeklyCashSalesData = getWeeklySales('cash');
    Map<String, double> weeklyCreditSalesData = getWeeklySales('credit');
    Map<String, double> monthlyCashSalesData = getMonthlySales('cash');
    Map<String, double> monthlyCreditSalesData = getMonthlySales('credit');

    List<double> cashData;
    List<double> creditData;
    List<String> xUserLabels;

    if (viewType == 'Weekly') {
      cashData = weeklyCashSalesData.values.toList();
      creditData = weeklyCreditSalesData.values.toList();
      xUserLabels = weeklyCashSalesData.keys.toList();
    } else {
      cashData = monthlyCashSalesData.values.toList();
      creditData = monthlyCreditSalesData.values.toList();
      xUserLabels = monthlyCashSalesData.keys.toList();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Cash / Credit Sales Report',
          style: TextStyle(
            color: Color(0xFF464949),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            fontFamily: 'SF Pro Text',
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
              size: 15,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: invoices.isEmpty && clients.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColor.accentColor)))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                color: Colors.grey.withOpacity(0.5),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 0),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: viewType,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      viewType = newValue!;
                                    });
                                  },
                                  items: <String>['Weekly', 'Monthly']
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: ChartWidget(
                      cashData: cashData,
                      creditData: creditData,
                      xUserLabels: xUserLabels,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildPaymentOptionButton('cash'),
                        const SizedBox(width: 8),
                        _buildPaymentOptionButton('credit'),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: viewType == 'Weekly'
                          ? List.generate(
                              selectedPaymentOption == 'cash'
                                  ? weeklyCashSalesData.length
                                  : weeklyCreditSalesData.length,
                              (index) {
                                String day = selectedPaymentOption == 'cash'
                                    ? weeklyCashSalesData.keys.elementAt(index)
                                    : weeklyCreditSalesData.keys
                                        .elementAt(index);
                                double amount = selectedPaymentOption == 'cash'
                                    ? weeklyCashSalesData[day]!
                                    : weeklyCreditSalesData[day]!;
                                return GestureDetector(
                                  onTap: () {
                                    _showInvoiceDetailsDialog(
                                        context, day, selectedPaymentOption);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 25.0),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            width: 1.0,
                                            color:
                                                Colors.grey.withOpacity(0.2)),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          day,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                            fontFamily: 'SF Pro Text',
                                          ),
                                        ),
                                        Text(
                                          '\$${amount.toStringAsFixed(2)}',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : List.generate(
                              selectedPaymentOption == 'cash'
                                  ? monthlyCashSalesData.length
                                  : monthlyCreditSalesData.length,
                              (index) {
                                String item = selectedPaymentOption == 'cash'
                                    ? monthlyCashSalesData.keys.elementAt(index)
                                    : monthlyCreditSalesData.keys
                                        .elementAt(index);
                                double amount = selectedPaymentOption == 'cash'
                                    ? monthlyCashSalesData[item]!
                                    : monthlyCreditSalesData[item]!;
                                return GestureDetector(
                                  onTap: () {
                                    _showInvoiceDetailsDialog(
                                        context, item, selectedPaymentOption);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 25.0),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            width: 1.0,
                                            color:
                                                Colors.grey.withOpacity(0.2)),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                            fontFamily: 'SF Pro Text',
                                          ),
                                        ),
                                        Text(
                                          '\$${amount.toStringAsFixed(2)}',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPaymentOptionButton(String option) {
    bool isSelected = selectedPaymentOption == option;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentOption = option;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(17, 200, 180, 0)
              : const Color.fromRGBO(200, 180, 0, 0),
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Text(
          option,
          style: TextStyle(
            color: isSelected ? AppColor.accentColor : AppColor.primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.normal,
            letterSpacing: 1,
            fontFamily: 'SF Pro Text',
          ),
        ),
      ),
    );
  }

  void _showInvoiceDetailsDialog(
      BuildContext context, String item, String paymentOption) {
    List<SalesInvoice> filteredInvoices;
    String searchQuery = '';
    bool showSearchBar = false;

    if (viewType == 'Weekly') {
      // Filter invoices for the selected day (item) and payment option
      filteredInvoices = invoices
          .where((invoice) =>
              DateFormat('EEEE').format(invoice.createdAt) == item &&
              invoice.paymentOption == paymentOption)
          .toList();
    } else {
      // For monthly view, filter invoices for the selected month and payment option
      filteredInvoices = invoices
          .where((invoice) =>
              DateFormat('MMMM').format(invoice.createdAt) == item &&
              invoice.paymentOption == paymentOption)
          .toList();
    }

    // Sort filtered invoices by createdAt date in ascending order
    filteredInvoices.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Calculate the total amount for the selected period
    double totalAmount = filteredInvoices.fold(
      0,
      (previousValue, invoice) => previousValue + invoice.totalAmount,
    );

    // Only show the dialog if the total amount is greater than $0
    if (totalAmount > 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              // Function to filter invoices based on search query
              List<SalesInvoice> filterInvoices(String query) {
                return filteredInvoices.where((invoice) {
                  Client? client = clients.firstWhere(
                    (client) => client.clientId == invoice.clientId,
                    orElse: () => Client(),
                  );
                  return invoice.referenceNumber
                          .toLowerCase()
                          .contains(query.toLowerCase()) ||
                      DateFormat('yyyy-MM-dd')
                          .format(invoice.createdAt)
                          .contains(query.toLowerCase()) ||
                      (paymentOption == 'credit' &&
                          DateFormat('yyyy-MM-dd')
                              .format(invoice.creditPeriodEndDate)
                              .contains(query.toLowerCase())) ||
                      client.organizationName!
                          .toLowerCase()
                          .contains(query.toLowerCase());
                }).toList();
              }

              // Filter invoices based on search query
              List<SalesInvoice> displayedInvoices =
                  filterInvoices(searchQuery);

              return AlertDialog(
                backgroundColor:
                    Colors.white, // Set the background color of the dialog
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8.0), // Set border radius here
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (showSearchBar)
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                              displayedInvoices = filterInvoices(searchQuery);
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search Invoices...',
                            border: InputBorder.none,
                          ),
                        ),
                      )
                    else
                      const Text(
                        'Invoice Details',
                        style: TextStyle(
                          color: Color(0xFF464949),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          fontFamily: 'SF Pro Text',
                        ), // Title text color
                      ),
                    IconButton(
                      icon: Icon(showSearchBar ? Icons.close : Icons.search),
                      onPressed: () {
                        setState(() {
                          showSearchBar = !showSearchBar;
                          if (!showSearchBar) {
                            searchQuery = '';
                            displayedInvoices = filteredInvoices;
                          }
                        });
                      },
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (displayedInvoices.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No invoices to display.',
                          style: TextStyle(
                            color: AppColor.primaryTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 1,
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: displayedInvoices.map((invoice) {
                              Client? client = clients.firstWhere(
                                (client) => client.clientId == invoice.clientId,
                                orElse: () => Client(),
                              );

                              return Container(
                                width: 400,
                                margin: const EdgeInsets.only(bottom: 8.0),
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border:
                                      Border.all(color: AppColor.widgetStroke),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x0F000000),
                                      spreadRadius: 0,
                                      offset: Offset(0, 4),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      invoice.referenceNumber,
                                      style: GoogleFonts.poppins(
                                        color: AppColor.idTextColorDark,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          'Client: ',
                                          style: TextStyle(
                                            color: AppColor.primaryTextColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            letterSpacing: 1,
                                            fontFamily: 'SF Pro Text',
                                          ),
                                        ),
                                        Text(
                                          client.organizationName ?? 'Unknown',
                                          style: GoogleFonts.poppins(
                                            color: AppColor.primaryTextColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          'Total Amount: ',
                                          style: TextStyle(
                                            color: AppColor.primaryTextColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            letterSpacing: 1,
                                            fontFamily: 'SF Pro Text',
                                          ),
                                        ),
                                        Text(
                                          '\$${invoice.totalAmount.toStringAsFixed(2)}',
                                          style: GoogleFonts.poppins(
                                            color: AppColor.primaryTextColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          'Paid Amount: ',
                                          style: TextStyle(
                                            color: AppColor.primaryTextColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            letterSpacing: 1,
                                            fontFamily: 'SF Pro Text',
                                          ),
                                        ),
                                        Text(
                                          '\$${invoice.paidAmount.toStringAsFixed(2)}',
                                          style: GoogleFonts.poppins(
                                            color: AppColor.primaryTextColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          'Balance: ',
                                          style: TextStyle(
                                            color: AppColor.primaryTextColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            letterSpacing: 1,
                                            fontFamily: 'SF Pro Text',
                                          ),
                                        ),
                                        Text(
                                          '\$${invoice.balance.toStringAsFixed(2)}',
                                          style: GoogleFonts.poppins(
                                            color: AppColor.primaryTextColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          'Created At: ',
                                          style: TextStyle(
                                            color: AppColor.primaryTextColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            letterSpacing: 1,
                                            fontFamily: 'SF Pro Text',
                                          ),
                                        ),
                                        Text(
                                          DateFormat('yyyy-MM-dd')
                                              .format(invoice.createdAt),
                                          style: GoogleFonts.poppins(
                                            color: AppColor.primaryTextColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (paymentOption == 'credit')
                                      Row(
                                        children: [
                                          const Text(
                                            'End Date: ',
                                            style: TextStyle(
                                              color: AppColor.primaryTextColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                              letterSpacing: 1,
                                              fontFamily: 'SF Pro Text',
                                            ),
                                          ),
                                          Text(
                                            DateFormat('yyyy-MM-dd').format(
                                                invoice.creditPeriodEndDate),
                                            style: GoogleFonts.poppins(
                                              color: AppColor.primaryTextColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: AppColor.primaryTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 1,
                        fontFamily: 'SF Pro Text',
                      ), // Button text color
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
