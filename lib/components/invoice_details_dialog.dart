import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:order_processing_app/models/sales_invoice.dart';
import 'package:order_processing_app/utils/app_colors.dart';

void showInvoiceDetailsDialog(BuildContext context, List<SalesInvoice> invoices,
    Map<int, String> clientMap) {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          List<SalesInvoice> filteredInvoices = invoices.where((invoice) {
            final query = _searchQuery.toLowerCase();

            // Fetch the organization name from the clientMap
            String organizationName = clientMap[invoice.clientId] ?? 'Unknown';

            return invoice.referenceNumber.toLowerCase().contains(query) ||
                invoice.totalAmount.toString().contains(query) ||
                invoice.paymentOption.toLowerCase().contains(query) ||
                DateFormat('yyyy-MM-dd')
                    .format(invoice.createdAt)
                    .contains(query) ||
                organizationName.toLowerCase().contains(query);
          }).toList();

          return AlertDialog(
            backgroundColor: AppColor.backgroundColor,
            title: Row(
              children: [
                Expanded(
                  child: _isSearching
                      ? TextField(
                          controller: _searchController,
                          onChanged: (query) {
                            setState(() {
                              _searchQuery = query;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search invoices...',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            border: InputBorder.none,
                          ),
                          style: GoogleFonts.poppins(
                            color: AppColor.primaryTextColor,
                          ),
                        )
                      : const Text(
                          'Invoice Details',
                          style: TextStyle(
                            color: AppColor.primaryTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                IconButton(
                  icon: Icon(
                    _isSearching ? Icons.close : Icons.search,
                    color: AppColor.primaryTextColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) {
                        _searchController.clear();
                        _searchQuery = '';
                      }
                    });
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (filteredInvoices.isEmpty)
                    const Text(
                      'No invoices found for the selected criteria.',
                      style: TextStyle(
                        color: AppColor.primaryTextColor,
                        fontSize: 16,
                      ),
                    )
                  else
                    ...filteredInvoices
                        .map((invoice) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
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
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Reference Number: ${invoice.referenceNumber}',
                                      style: GoogleFonts.poppins(
                                        color: AppColor.primaryTextColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Total Amount: LKR.${invoice.totalAmount}',
                                      style: GoogleFonts.poppins(
                                        color: AppColor.primaryTextColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          invoice.paymentOption == 'credit'
                                              ? Icons.credit_card
                                              : invoice.paymentOption ==
                                                      'cheque'
                                                  ? Icons.account_balance
                                                  : Icons.monetization_on,
                                          color: AppColor.primaryColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Payment Option: ${invoice.paymentOption.capitalize()}',
                                          style: GoogleFonts.poppins(
                                            color: AppColor.primaryTextColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Created At: ${DateFormat('yyyy-MM-dd hh:mm').format(invoice.createdAt)}',
                                      style: GoogleFonts.poppins(
                                        color: AppColor.primaryTextColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Organization: ${clientMap[invoice.clientId] ?? 'Unknown'}',
                                      style: GoogleFonts.poppins(
                                        color: AppColor.primaryTextColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (invoice.paymentOption == 'credit') ...[
                                      const Divider(),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Paid Amount: LKR.${invoice.paidAmount ?? '0.00'}',
                                        style: GoogleFonts.poppins(
                                          color: AppColor.primaryTextColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Balance: LKR.${invoice.balance ?? '0.00'}',
                                        style: GoogleFonts.poppins(
                                          color: AppColor.primaryTextColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Credit Period End Date: ${invoice.creditPeriodEndDate != null ? DateFormat('yyyy-MM-dd').format(invoice.creditPeriodEndDate!) : 'N/A'}',
                                        style: GoogleFonts.poppins(
                                          color: AppColor.primaryTextColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                ],
              ),
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
                  ),
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

extension StringCasingExtension on String {
  String capitalize() {
    return this.isEmpty
        ? this
        : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
