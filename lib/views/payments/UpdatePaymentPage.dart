import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Necessary for formatting dates

import '../../components/custom_button.dart';
import '../../components/custom_widget.dart';
import '../../models/payments_modle.dart';
import '../../utils/app_colors.dart';
import '../../utils/invoice_logic.dart';

class UpdatePaymentPage extends StatefulWidget {
  final String referenceNumber;
  final double totalAmount;
  final double paidAmount;

  const UpdatePaymentPage({
    Key? key,
    required this.referenceNumber,
    required this.totalAmount,
    required this.paidAmount,
  }) : super(key: key);

  @override
  _UpdatePaymentPageState createState() => _UpdatePaymentPageState();
}

class _UpdatePaymentPageState extends State<UpdatePaymentPage> {
  final InvoiceLogic invoiceLogic = InvoiceLogic();
  bool showPaymentFields =
      false; // State variable to manage payment fields visibility
  TextEditingController _amountController = TextEditingController();
  final TextEditingController paymentController =
      TextEditingController(); // Controller for amount input

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 16.0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Payment'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildReferenceNumberSection(),
            const SizedBox(height: 20),
            _buildOutstandingBalanceSection(),
            const SizedBox(height: 20),
            _buildPaymentMethodDropdown(width),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildAddPaymentSection(),
            ),
            const SizedBox(height: 20),
            _buildPrintInvoiceButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceNumberSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text('Reference Number: ${widget.referenceNumber}'),
    );
  }

  Widget _buildOutstandingBalanceSection() {
    double outstandingBalance = widget.totalAmount - widget.paidAmount;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Outstanding Balance: \$${outstandingBalance.toStringAsFixed(2)}',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPaymentMethodDropdown(double width) {
    return GestureDetector(
      child: DropdownMenu<PaymentMethod>(
        controller: paymentController,
        width: width,
        hintText: "Select Payment Method",
        requestFocusOnTap: true,
        enableFilter: true,
        menuStyle: MenuStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            invoiceLogic.selectedClient != null
                ? Colors.lightBlue.shade50
                : Colors.grey.shade300,
          ),
        ),
        label: const Text('Select Payment Method'),
        onSelected: (PaymentMethod? paymentMethod) {
          setState(() {
            invoiceLogic.selectedPaymentMethod = paymentMethod;
          });
        },
        dropdownMenuEntries:
            invoiceLogic.paymentMethods.map<DropdownMenuEntry<PaymentMethod>>(
          (PaymentMethod paymentMethod) {
            return DropdownMenuEntry<PaymentMethod>(
              value: paymentMethod,
              label: paymentMethod.paymentName,
              leadingIcon: Icon(paymentMethod.paymentIcon),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _buildAddPaymentSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ExpansionTile(
        initiallyExpanded: showPaymentFields,
        title: const Text('Add Payments'),
        children: <Widget>[
          const Divider(thickness: 1.0, height: 1.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      showPaymentFields = !showPaymentFields;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.add),
                      const SizedBox(width: 4),
                      const Text(
                        'Add payment',
                        style: TextStyle(fontSize: 14),
                      ),
                      const Spacer(),
                      CustomAddButton(
                        onPressed: () async {
                          // Add payment logic implementation needed
                        },
                        buttonText: 'Full Paid Now',
                        backgroundColor: Colors.blue, // Example color
                        textColor: Colors.white,
                        strokeColor: Colors.blueGrey, // Example stroke color
                        borderRadius: 10,
                      ),
                    ],
                  ),
                ),
                if (showPaymentFields) ...[
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TextFormField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: DateFormat('yyyy-MM-dd')
                                  .format(DateTime.now()),
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Select Date',
                              border: InputBorder.none,
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _amountController,
                            decoration: const InputDecoration(
                              labelText: 'Amount For Payments',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomAddButton(
                          onPressed: () {
                            setState(() {
                              _amountController.clear();
                              showPaymentFields = false;
                            });
                          },
                          buttonText: 'Cancel',
                          backgroundColor: Colors.red, // Example color
                          textColor: Colors.white,
                          strokeColor: Colors.redAccent, // Example stroke color
                          borderRadius: 10,
                        ),
                        const SizedBox(width: 8),
                        CustomAddButton(
                          onPressed: () {
                            // Add more payment logic here
                          },
                          buttonText: 'Add',
                          backgroundColor: Colors.green, // Example color
                          textColor: Colors.white,
                          strokeColor:
                              Colors.greenAccent, // Example stroke color
                          borderRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrintInvoiceButton() {
    return CustomButton(
      buttonText: 'Add Payment',
      onTap: () async {},
      buttonColor: invoiceLogic.canPrintInvoice()
          ? AppColor.accentColor
          : AppColor.disableBtnColor, // Enable or disable the button visually
      isLoading: false,
    );
  }
}
