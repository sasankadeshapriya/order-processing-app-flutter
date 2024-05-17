import 'package:flutter/material.dart';
import 'package:order_processing_app/components/card_invoice.dart';
import 'package:order_processing_app/models/client.dart';
import 'package:order_processing_app/models/invoice_mod.dart';
import 'package:order_processing_app/services/invoice_api_service.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/utils/app_components.dart';
import 'package:order_processing_app/views/invoice/invoicePage.dart';

class InvoiceList extends StatefulWidget {
  const InvoiceList({Key? key}) : super(key: key);

  @override
  _InvoiceListState createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {
  late Future<List<Invoice>> _invoicesFuture;
  final int employeeId = 1; // Hardcoded employee ID for filtering
  String _status = 'All'; // Initialize with 'All' status
  String _sortBy =
      'Created Date'; // Initialize with 'Created Date' as default sorting
  bool _isAscending = false; // Initialize with descending order

  @override
  void initState() {
    super.initState();
    _invoicesFuture = _fetchInvoices();
  }

  Future<List<Invoice>> _fetchInvoices() async {
    try {
      List<Invoice> invoices = await InvoiceService.getInvoices();
      return invoices
          .where((invoice) => invoice.employeeId == employeeId)
          .toList();
    } catch (e) {
      throw Exception('Failed to load invoices');
    }
  }

  Future<String> _getClientOrganizationName(int clientId) async {
    try {
      Client client = await InvoiceService.getClientById(clientId);
      String organizationName =
          client.organizationName ?? 'Client details not found';
      print(
          'Fetched organization name for client $clientId: $organizationName');
      return organizationName;
    } catch (e) {
      print('Error fetching organization name for client $clientId: $e');
      return 'Client details not found';
    }
  }

  void _onSortBySelected(String sortBy) {
    setState(() {
      _sortBy = sortBy;
    });
  }

  void _onSortOrderChanged() {
    setState(() {
      _isAscending = !_isAscending;
    });
  }

  void _handleStatusOptionTap(String status) {
    setState(() {
      _status = status;
    });
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
          "Invoices",
          style: TextStyle(
            color: Color(0xFF464949),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            fontFamily: 'SF Pro Text',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
              color: AppColor.primaryTextColor,
              size: 24,
            ),
            onPressed: _onSortOrderChanged,
          ),
          PopupMenuTheme(
            data: const PopupMenuThemeData(
              color: Colors.white,
              textStyle: TextStyle(color: AppColor.primaryTextColor),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.sort_rounded),
              onSelected: _onSortBySelected,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                _buildRadioMenuItem('Total Amount'),
                _buildRadioMenuItem('Paid Amount'),
                _buildRadioMenuItem('Organization Name'),
                _buildRadioMenuItem('Created Date'),
                _buildRadioMenuItem('Reference Number'),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusHeader(_status),
          const SizedBox(height: 14),
          Expanded(
            child: FutureBuilder<List<Invoice>>(
              future: _invoicesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColor.accentColor),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return const Center(child: Text('No invoices available.'));
                  }
                  return _buildInvoicesContainer(snapshot.data!);
                } else {
                  return const Center(child: Text('No invoices available.'));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FloatingActionButton(
          backgroundColor: AppColor.accentColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InvoicePage()),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildRadioMenuItem(String value) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _sortBy,
            onChanged: (String? newValue) {
              if (newValue != null) {
                _onSortBySelected(newValue);
                Navigator.pop(context); // Close the popup menu after selection
              }
            },
            activeColor: AppColor.accentColor,
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildInvoicesContainer(List<Invoice> invoices) {
    // Sort invoices based on selected sorting option and order
    if (_sortBy == 'Total Amount') {
      invoices.sort((a, b) => _isAscending
          ? a.totalAmount.compareTo(b.totalAmount)
          : b.totalAmount.compareTo(a.totalAmount));
    } else if (_sortBy == 'Paid Amount') {
      invoices.sort((a, b) => _isAscending
          ? a.paidAmount.compareTo(b.paidAmount)
          : b.paidAmount.compareTo(a.paidAmount));
    } else if (_sortBy == 'Organization Name') {
      invoices.sort((a, b) => _isAscending
          ? (a.organizationName ?? '').compareTo(b.organizationName ?? '')
          : (b.organizationName ?? '').compareTo(a.organizationName ?? ''));
    } else if (_sortBy == 'Created Date') {
      invoices.sort((a, b) => _isAscending
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt));
    } else if (_sortBy == 'Reference Number') {
      invoices.sort((a, b) => _isAscending
          ? a.referenceNumber.compareTo(b.referenceNumber)
          : b.referenceNumber.compareTo(a.referenceNumber));
    }

    // Filter invoices based on status
    List<Invoice> filteredInvoices;
    if (_status == 'Paid') {
      filteredInvoices = invoices
          .where((invoice) => invoice.totalAmount == invoice.paidAmount)
          .toList();
    } else if (_status == 'Unpaid') {
      filteredInvoices = invoices
          .where((invoice) => invoice.totalAmount != invoice.paidAmount)
          .toList();
    } else {
      filteredInvoices = invoices; // Show all invoices
    }

    // Fetch organization names for each invoice
    return FutureBuilder<List<Invoice>>(
      future: Future.wait(filteredInvoices.map((invoice) async {
        print(
            'Fetching organization name for invoice with client ID: ${invoice.clientId}');
        invoice.organizationName =
            await _getClientOrganizationName(invoice.clientId);
        print(
            'Invoice ${invoice.referenceNumber} - Organization: ${invoice.organizationName}');
        return invoice;
      }).toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColor.accentColor),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return _buildInvoiceList(snapshot.data!);
        } else {
          return const Center(child: Text('No invoices available.'));
        }
      },
    );
  }

  Widget _buildInvoiceList(List<Invoice> invoices) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.primaryTextColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListView.builder(
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: InvoiceCard(
              referenceNumber: invoice.referenceNumber,
              totalAmount: invoice.totalAmount,
              paidAmount: invoice.paidAmount,
              creditPeriodEndDate: invoice.creditPeriodEndDate.toString(),
              createdAt: invoice.createdAt.toString(),
              organizationName: invoice.organizationName ?? 'Unknown',
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusHeader(String status) {
    return Container(
      padding: const EdgeInsets.all(5),
      width: 350,
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.primaryTextColor, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatusOption('All', status == 'All', 'All'),
          _buildStatusOption('Paid', status == 'Paid', 'Paid'),
          _buildStatusOption('Unpaid', status == 'Unpaid', 'Unpaid'),
        ],
      ),
    );
  }

  Widget _buildStatusOption(String text, bool isSelected, String status) {
    return InkWell(
      onTap: () {
        _handleStatusOptionTap(status);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(17, 200, 180, 0) : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color:
                isSelected ? AppColor.accentColor : AppColor.primaryTextColor,
            fontFamily: AppComponents.fontSFProTextSemibold,
          ),
        ),
      ),
    );
  }
}
