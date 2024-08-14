import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:order_processing_app/components/invoice_details_dialog.dart';
import 'package:order_processing_app/models/clients_modle.dart';
import 'package:order_processing_app/models/sales_invoice.dart';
import 'package:order_processing_app/services/client_api_service.dart';
import 'package:order_processing_app/services/invoice_api_service.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/widgets/line_chart_widget.dart';
import '../../services/token_manager.dart';

class EmpSalesReport extends StatefulWidget {
  const EmpSalesReport({super.key});

  @override
  _EmpSalesReportState createState() => _EmpSalesReportState();
}

class _EmpSalesReportState extends State<EmpSalesReport> {
  List<SalesInvoice> invoices = [];
  List<Client> clients = [];
  String viewType = 'Weekly'; // Weekly or Monthly view
  String selectedPaymentOption = 'cash'; // Cash or Credit
  String selectedDay = ''; // Selected day for the list view
  int empId = TokenManager.empId ?? 0;
  Map<int, String> clientMap = {};

  @override
  void initState() {
    super.initState();
    fetchInvoices();
    fetchClients();
  }

  Future<void> fetchInvoices() async {
    try {
      List<SalesInvoice> fetchedInvoices =
          await InvoiceService.fetchInvoicesByEmployeeId(empId);
      Logger().i(
          'Fetched Invoices: ${fetchedInvoices.map((invoice) => invoice.toString()).join(', ')}');
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
        // Initialize clientMap after clients are fetched
        clientMap = {
          for (var client in clients)
            client.clientId: client.organizationName ?? 'Unknown'
        };
      });
    } catch (e) {
      print('Error fetching clients: $e');
    }
  }

  Map<String, double> getWeeklySales(String paymentOption) {
    final filteredInvoices = _filterInvoicesByPaymentOption(
      _filterInvoicesForCurrentWeek(invoices),
      paymentOption,
    );
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
    final filteredInvoices =
        _filterInvoicesByPaymentOption(invoices, paymentOption);
    return _calculateSalesData(filteredInvoices, [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ]);
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
    return allInvoices.where((invoice) {
      if (paymentOption == 'credit') {
        return invoice.paymentOption == 'credit' ||
            invoice.paymentOption == 'cheque';
      }
      return invoice.paymentOption == paymentOption;
    }).toList();
  }

  Map<String, double> _calculateSalesData(
      List<SalesInvoice> invoices, List<String> periods) {
    Map<String, double> sales = {for (var period in periods) period: 0.0};
    for (var invoice in invoices) {
      String period = DateFormat(viewType == 'Weekly' ? 'EEEE' : 'MMMM')
          .format(invoice.createdAt);
      sales[period] = sales[period]! + invoice.totalAmount;
    }
    return sales;
  }

  DateTime _startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  DateTime _endOfWeek(DateTime date) {
    return _startOfWeek(date).add(const Duration(days: 6));
  }

  @override
  Widget build(BuildContext context) {
    final cashData =
        viewType == 'Weekly' ? getWeeklySales('cash') : getMonthlySales('cash');
    final creditData = viewType == 'Weekly'
        ? getWeeklySales('credit')
        : getMonthlySales('credit');
    final xUserLabels = cashData.keys.toList();

    return Scaffold(
      appBar: _buildAppBar(),
      body: invoices.isEmpty && clients.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColor.accentColor)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildViewTypeDropdown(),
                _buildChart(
                  cashData.values.toList(),
                  creditData.values.toList(),
                  xUserLabels,
                ),
                _buildPaymentOptionButtons(),
                Expanded(
                  child: _buildSalesList(cashData, creditData),
                ),
              ],
            ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.backgroundColor,
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
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.black, size: 15),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildViewTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(right: 150, top: 20, left: 15, bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.grey.withOpacity(0.5), width: 1.0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: viewType,
                    onChanged: (String? newValue) {
                      setState(() {
                        viewType = newValue!;
                      });
                    },
                    items: <String>['Weekly', 'Monthly'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black87)),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<double> cashData, List<double> creditData,
      List<String> xUserLabels) {
    return ChartWidget(
      cashData: cashData,
      creditData: creditData,
      xUserLabels: xUserLabels,
    );
  }

  Widget _buildPaymentOptionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _buildPaymentOptionButton('Cash Sales', 'cash'),
          SizedBox(width: 10),
          _buildPaymentOptionButton('Credit Sales', 'credit'),
        ],
      ),
    );
  }

  Widget _buildPaymentOptionButton(String label, String option) {
    return TextButton(
      onPressed: () {
        setState(() {
          selectedPaymentOption = option;
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: selectedPaymentOption == option
            ? Color.fromARGB(17, 200, 180, 0)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selectedPaymentOption == option
              ? AppColor.accentColor
              : AppColor.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSalesList(
      Map<String, double> cashData, Map<String, double> creditData) {
    final Map<String, double> dataToShow =
        selectedPaymentOption == 'cash' ? cashData : creditData;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: dataToShow.length,
      itemBuilder: (context, index) {
        String period = dataToShow.keys.elementAt(index);
        double sales = dataToShow[period]!;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Icon(
              Icons.attach_money,
              color: selectedPaymentOption == 'cash'
                  ? AppColor.accentColor
                  : Colors.green,
              size: 30,
            ),
            title: Text(
              period,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.primaryTextColor,
              ),
            ),
            subtitle: Text(
              'LKR ${sales.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                color: AppColor.secondaryColor,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey[600],
              size: 20,
            ),
            onTap: () {
              // Determine the date range for filtering invoices
              DateTime startDate, endDate;
              if (viewType == 'Weekly') {
                startDate = _startOfWeek(DateTime.now());
                endDate = _endOfWeek(DateTime.now());
              } else {
                startDate =
                    DateTime(DateTime.now().year, DateTime.now().month, 1);
                endDate =
                    DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
              }

              // Filter invoices for the selected period and payment option
              List<SalesInvoice> filteredInvoices = invoices.where((invoice) {
                DateFormat dateFormat =
                    DateFormat(viewType == 'Weekly' ? 'EEEE' : 'MMMM');
                String invoicePeriod = dateFormat.format(invoice.createdAt);

                bool isInDateRange = invoice.createdAt
                        .isAfter(startDate.subtract(Duration(days: 1))) &&
                    invoice.createdAt.isBefore(endDate.add(Duration(days: 1)));
                bool matchesPaymentOption = selectedPaymentOption == 'credit'
                    ? (invoice.paymentOption == 'credit' ||
                        invoice.paymentOption == 'cheque')
                    : invoice.paymentOption == selectedPaymentOption;

                return isInDateRange &&
                    matchesPaymentOption &&
                    invoicePeriod == period;
              }).toList();

              // Show dialog with filtered invoices
              showInvoiceDetailsDialog(context, filteredInvoices, clientMap);
            },
          ),
        );
      },
    );
  }
}
