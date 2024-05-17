import 'package:flutter/material.dart';
import 'package:order_processing_app/components/card_invoice.dart';
import 'package:order_processing_app/models/client.dart';
import 'package:order_processing_app/models/invoice_mod.dart';
import 'package:order_processing_app/services/invoice_api_service.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/utils/app_components.dart';

class InvoiceList extends StatefulWidget {
  const InvoiceList({Key? key}) : super(key: key);

  @override
  _InvoiceListState createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {
  late Future<List<Invoice>> _invoicesFuture;
  final int employeeId = 1; // Hardcoded employee ID for filtering
  late String _status = 'All'; // Initialize with 'All' status
  late String _sortBy =
      'Created Date'; // Initialize with 'Created Date' as default sorting

  @override
  void initState() {
    super.initState();
    _invoicesFuture = _fetchInvoices();
  }

  Future<List<Invoice>> _fetchInvoices() async {
    List<Invoice> invoices = await InvoiceApiService.getInvoices();
    // Filter invoices based on employee ID
    List<Invoice> filteredInvoices =
        invoices.where((invoice) => invoice.employeeId == employeeId).toList();
    return filteredInvoices;
  }

  Future<String> _getClientOrganizationName(int clientId) async {
    Client? client = await InvoiceApiService.getClientById(clientId);
    return client.organizationName ?? 'Client details not found';
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded), // Set the icon here
            onSelected: _onSortBySelected,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Total Amount',
                child: Text('Total Amount'),
              ),
              const PopupMenuItem<String>(
                value: 'Paid Amount',
                child: Text('Paid Amount'),
              ),
              const PopupMenuItem<String>(
                value: 'Organization Name',
                child: Text('Organization Name'),
              ),
              const PopupMenuItem<String>(
                value: 'Created Date',
                child: Text('Created Date'),
              ),
              const PopupMenuItem<String>(
                value: 'Reference Number',
                child: Text('Reference Number'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusHeader("Paid"), // Display status header
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
    );
  }

  Widget _buildInvoicesContainer(List<Invoice> invoices) {
    // Sort invoices based on selected sorting option
    if (_sortBy == 'Total Amount') {
      invoices.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
    } else if (_sortBy == 'Paid Amount') {
      invoices.sort((a, b) => a.paidAmount.compareTo(b.paidAmount));
    } else if (_sortBy == 'Organization Name') {
      invoices.sort((a, b) => a.organizationName.compareTo(b.organizationName));
    } else if (_sortBy == 'Created Date') {
      invoices.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (_sortBy == 'Reference Number') {
      invoices.sort((a, b) => a.referenceNumber.compareTo(b.referenceNumber));
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

    // Build the UI with filtered invoices
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.primaryTextColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListView.builder(
        itemCount: filteredInvoices.length,
        itemBuilder: (context, index) {
          final invoice = filteredInvoices[index];
          return FutureBuilder<String>(
            future: _getClientOrganizationName(invoice.clientId),
            builder: (context, clientSnapshot) {
              if (clientSnapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              } else if (clientSnapshot.hasError) {
                return Text('Error: ${clientSnapshot.error}');
              } else {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: InvoiceCard(
                    referenceNumber: invoice.referenceNumber,
                    totalAmount: invoice.totalAmount,
                    paidAmount: invoice.paidAmount,
                    creditPeriodEndDate: invoice.creditPeriodEndDate.toString(),
                    createdAt: invoice.createdAt.toString(),
                    organizationName: clientSnapshot.data!,
                  ),
                );
              }
            },
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
        // Pass the selected status back to the parent widget
        _handleStatusOptionTap(status);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          color: _status == status ? Colors.grey[200] : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _status == status ? AppColor.primaryTextColor : Colors.black,
            fontFamily: AppComponents.fontSFProTextSemibold,
          ),
        ),
      ),
    );
  }

  void _handleStatusOptionTap(String status) {
    setState(() {
      // Update the status based on the tapped option
      _status = status;
    });
  }

  void _onSortBySelected(String sortBy) {
    setState(() {
      _sortBy = sortBy;
    });
  }
}
