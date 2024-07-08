import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import '../../models/payments_modle.dart';
import '../../services/payment_api_service.dart';
import '../../utils/app_colors.dart';
import 'payment_card.dart';

class PaymentList extends StatefulWidget {
  const PaymentList({super.key});

  @override
  _PaymentListState createState() => _PaymentListState();
}

class _PaymentListState extends State<PaymentList> {
  late Future<PaymentResponse> _paymentsFuture;
  bool _isAscending = true;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Payment> _payments = [];
  List<Payment> _filteredPayments = [];
  String _sortBy = 'Created Date';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _paymentsFuture = PaymentService.getAllPayments();
  }

  void _onSortOrderChanged() {
    setState(() {
      _isAscending = !_isAscending;
      _filteredPayments = List.from(_filteredPayments.reversed);
    });
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _filterPayments('');
    });
  }

  void _updateSearch(String value) {
    setState(() {
      _filterPayments(value);
    });
  }

  void _filterPayments(String value) {
    _filteredPayments = _payments.where((payment) {
      return payment.referenceNumber
              .toLowerCase()
              .contains(value.toLowerCase()) ||
          payment.paymentOption.toLowerCase().contains(value.toLowerCase()) ||
          payment.state.toLowerCase().contains(value.toLowerCase()) ||
          (payment.state == 'verified' &&
              'verified'.contains(value.toLowerCase())) ||
          (payment.state == 'not-verified' &&
              'not verified'.contains(value.toLowerCase()));
    }).toList();
  }

  void _onSortBySelected(String sortBy) {
    setState(() {
      _sortBy = sortBy;
    });
  }

  void _editPayment(Payment payment) {
    // Implement edit functionality
  }

  void _removePayment(Payment payment) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.bottomSlide,
      title: 'Confirm Removal',
      desc: 'Are you sure you want to remove this payment?',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        setState(() {
          _isLoading = true;
        });

        try {
          var result = await PaymentService.deletePayment(payment.id);
          if (result['success'] == true) {
            setState(() {
              _payments.removeWhere((item) => item.id == payment.id);
              _filterPayments(_searchController.text);
              _paymentsFuture = PaymentService.getAllPayments();
              _isLoading = false;
            });
            AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.scale,
              title: 'Success',
              desc: 'Payment successfully removed',
              btnOkOnPress: () {},
            ).show();
          } else {
            setState(() {
              _isLoading = false;
            });
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.scale,
              title: 'Error',
              desc: result['message'] ?? 'Failed to remove payment',
              btnOkOnPress: () {},
            ).show();
          }
        } catch (error) {
          setState(() {
            _isLoading = false;
          });
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.scale,
            title: 'Error',
            desc: 'Failed to remove payment: $error',
            btnOkOnPress: () {},
          ).show();
        }
      },
    ).show();
  }

  Widget _buildPaymentsContainer(List<Payment> payments) {
    if (_sortBy == 'Amount') {
      payments.sort((a, b) => _isAscending
          ? double.parse(a.amount).compareTo(double.parse(b.amount))
          : double.parse(b.amount).compareTo(double.parse(a.amount)));
    } else if (_sortBy == 'Payment Option') {
      payments.sort((a, b) => _isAscending
          ? a.paymentOption.compareTo(b.paymentOption)
          : b.paymentOption.compareTo(a.paymentOption));
    } else if (_sortBy == 'State') {
      payments.sort((a, b) => _isAscending
          ? a.state.compareTo(b.state)
          : b.state.compareTo(a.state));
    } else if (_sortBy == 'Created Date') {
      payments.sort((a, b) => _isAscending
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt));
    } else if (_sortBy == 'Reference Number') {
      payments.sort((a, b) => _isAscending
          ? a.referenceNumber.compareTo(b.referenceNumber)
          : b.referenceNumber.compareTo(a.referenceNumber));
    }

    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.primaryTextColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListView.builder(
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: PaymentCard(
              payment: payment,
              onEdit: () => _editPayment(payment),
              onRemove: () => _removePayment(payment),
            ),
          );
        },
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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search payments...',
                  border: InputBorder.none,
                ),
                onChanged: _updateSearch,
              )
            : const Text(
                'Payments',
                style: TextStyle(
                  color: Color(0xFF464949),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontFamily: 'SF Pro Text',
                ),
              ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: Icon(
                _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                color: AppColor.primaryTextColor,
                size: 24,
              ),
              onPressed: _onSortOrderChanged,
            ),
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              size: 24,
              color: AppColor.primaryTextColor,
            ),
            onPressed: () {
              if (_isSearching) {
                _stopSearch();
              } else {
                _startSearch();
              }
            },
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
                _buildRadioMenuItem('Amount'),
                _buildRadioMenuItem('Payment Option'),
                _buildRadioMenuItem('State'),
                _buildRadioMenuItem('Created Date'),
                _buildRadioMenuItem('Reference Number'),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.accentColor),
              ),
            )
          : _filteredPayments.isEmpty && _isSearching
              ? const Center(child: Text('No payments found'))
              : FutureBuilder<PaymentResponse>(
                  future: _paymentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColor.accentColor),
                      ));
                    } else if (snapshot.hasError) {
                      return const Center(
                          child: Text('Failed to load payments'));
                    } else if (!snapshot.hasData ||
                        snapshot.data!.payments.isEmpty) {
                      return const Center(child: Text('No payments available'));
                    }

                    _payments = snapshot.data!.payments;
                    _filterPayments(_searchController.text);

                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _buildPaymentsContainer(_filteredPayments),
                    );
                  },
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
}
