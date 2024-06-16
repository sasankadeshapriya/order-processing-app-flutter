import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../../components/alert_dialog.dart';
import '../../components/custom_button.dart';
import '../../components/custom_widget.dart';
import '../../models/clients_modle.dart';
import '../../models/payments_modle.dart';
import '../../models/product_modle.dart';
import '../../utils/app_colors.dart';
import '../../utils/invoice_logic.dart';
import 'print_invoice.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({
    super.key,
  });

  @override
  _InvoicePageState createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final InvoiceLogic invoiceLogic = InvoiceLogic();
  final TextEditingController clientController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController paymentController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  //String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now()); // To store current date

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool showPaymentFields = false;
  int? empId;

  @override
  void initState() {
    super.initState();
    fetchProductsAndUpdateUI();
  }

  Future<void> fetchProductsAndUpdateUI() async {
    await invoiceLogic.fetchClients();
    // Assuming empId and currentDate are correctly set
    await invoiceLogic.fetchProductDetails(1, '2024-04-01', context);
    Logger()
        .f('Products loaded into dropdown: ${invoiceLogic.productList.length}');
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 16.0;
    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when tapped outside of the dropdown list
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
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
            'Add New Invoice',
            style: TextStyle(
              color: Color(0xFF464949),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontFamily: 'SF Pro Text',
            ),
          ),
          backgroundColor: AppColor.backgroundColor,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //_buildDateDisplay(),
                        const SizedBox(height: 20),
                        _buildClientDropdown(width, 200),
                        const SizedBox(height: 20),
                        _buildPaymentMethodDropdown(width),
                        const SizedBox(height: 20),
                        _buildProductDropdown(width),
                        const SizedBox(height: 20),
                        _buildProductList(),
                        const SizedBox(height: 10),
                        _buildTotalSection(),
                        const SizedBox(height: 10),
                        _buildAddPaymentSection(),
                        const SizedBox(height: 20),
                        Expanded(child: Container()), // Pushes button to bottom
                        Center(child: _buildPrintInvoiceButton()),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDateDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const Spacer(),
          Text(
            DateFormat('yyyy-MM-dd').format(DateTime.now()),
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildClientDropdown(double width, double height) {
    return DropdownMenu<Client>(
      controller: clientController,
      width: width,
      menuHeight: height,
      hintText: "Select Client",
      requestFocusOnTap: true,
      enableFilter: true,
      menuStyle: MenuStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          Colors.lightBlue.shade50,
        ),
      ),
      label: const Text('Select Client'),
      onSelected: (Client? client) async {
        setState(() {
          invoiceLogic.selectedClient = client;
        });
        await invoiceLogic
            .getOutstandingBalance(invoiceLogic.selectedClient!.clientId);
      },
      dropdownMenuEntries: invoiceLogic.clients.map<DropdownMenuEntry<Client>>(
        (Client client) {
          //Logger().w("Building dropdown entry for client: ${client.organizationName}");

          return DropdownMenuEntry<Client>(
            value: client,
            label: client.organizationName ?? 'Unknown',
            leadingIcon: Icon(client.icon),
          );
        },
      ).toList(),
    );
  }

  Widget _buildPaymentMethodDropdown(double width) {
    return GestureDetector(
      onTap: () {
        if (invoiceLogic.selectedClient == null) {
          // Show error alert if no client is selected
          AleartBox.showAleart(context, DialogType.error, 'Selection Required',
              'Please select a client first.');
        }
      },
      child: AbsorbPointer(
        absorbing: invoiceLogic.selectedClient ==
            null, // Prevent interaction if no client is selected
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
      ),
    );
  }

  Widget _buildProductDropdown(double width) {
    return GestureDetector(
      onTap: () {
        if (invoiceLogic.selectedClient == null ||
            invoiceLogic.selectedPaymentMethod == null) {
          // Use custom AleartBox to show error if client or payment method is not selected
          AleartBox.showAleart(context, DialogType.error, 'Selection Required',
              'Please select a client and a payment method first.');
        }
      },
      child: AbsorbPointer(
        absorbing: invoiceLogic.selectedClient == null ||
            invoiceLogic.selectedPaymentMethod == null,
        child: DropdownMenu<Product>(
          controller: productController,
          width: width,
          hintText: "Select product",
          requestFocusOnTap: true,
          enableFilter: true,
          menuStyle: MenuStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(Colors.lightBlue.shade50),
          ),
          label: const Text('Select product'),
          onSelected: (Product? product) {
            setState(() {
              invoiceLogic.selectedProduct = product;
              if (product != null) {
                invoiceLogic.addSelectedProduct(product);
              }
            });
          },
          dropdownMenuEntries: invoiceLogic.productList.map((Product product) {
            return DropdownMenuEntry<Product>(
              value: product,
              label: product.name,
              leadingIcon: CircleAvatar(
                backgroundImage:
                    NetworkImage(product.productImage), // Ensure URL is correct
                radius: 20,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: invoiceLogic.productQuantities.keys.map((product) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(product.name,
                    style: const TextStyle(
                        fontSize: 16)), // Product name with styling
                Container(
                  width: 25, // Define the size of the circle
                  height: 25, // Ensure the container is perfectly circular
                  decoration: const BoxDecoration(
                    color:
                        AppColor.primaryColor, // Background color of the circle

                    shape: BoxShape.circle, // Shape of the container
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        invoiceLogic.removeSelectedProduct(product);
                      });
                    },
                    icon: const Icon(Icons.close,
                        color: Colors.white,
                        size: 10), // Using a different icon
                    tooltip: 'Remove',
                    alignment: Alignment
                        .center, // Center the icon inside the container
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Price: Rs.${invoiceLogic.getPrice(product, invoiceLogic.selectedPaymentMethod ?? invoiceLogic.paymentMethods.first)} X ${invoiceLogic.productQuantities[product]} ${product.measurementUnit}",
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColor
                            .secondaryTextColorDark), // Styling for price
                  ),
                  Text(
                    "Total: Rs.${(invoiceLogic.getPrice(product, invoiceLogic.selectedPaymentMethod ?? invoiceLogic.paymentMethods.first) * (invoiceLogic.productQuantities[product] ?? 1)).toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColor
                            .secondaryTextColorDark), // Styling for total
                  ),
                ],
              ),
            ),
            _buildQuantityAdjustmentRow(product),
            const Divider(
              color: Color(0xFF565656),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildQuantityAdjustmentRow(Product product) {
    TextEditingController controller =
        invoiceLogic.getControllerForProduct(product);

    return Container(
      child: Align(
        alignment: Alignment.centerRight, // Align to the right
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                double currentQuantity = double.tryParse(controller.text) ?? 0;
                if (currentQuantity > 0.5) {
                  currentQuantity -= 1;
                  controller.text = currentQuantity.toStringAsFixed(
                      currentQuantity.truncateToDouble() == currentQuantity
                          ? 0
                          : 1);
                  invoiceLogic.updateProductQuantity(product, currentQuantity);

                  setState(() {});
                } else {
                  // Show alert when trying to decrease below 0.5
                  AleartBox.showAleart(
                    context,
                    DialogType.warning,
                    'Minimum Quantity Reached',
                    'The minimum quantity allowed is 0.1',
                  );
                }
              },
              icon: const Icon(Icons.remove_circle_outline,
                  color: Colors.redAccent),
              tooltip: 'Decrease',
            ),
            SizedBox(
              width: 50,
              height: 25,
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                ),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                onChanged: (newValue) {
                  // Add a leading zero if the input starts with a decimal point
                  if (newValue.startsWith('.')) {
                    newValue = '0$newValue';
                  }

                  // Validate input against available stock
                  double? quantity = double.tryParse(newValue);
                  if (quantity != null) {
                    if (quantity > product.quantity) {
                      // If entered quantity exceeds available stock, set it to maximum available
                      controller.text = product.quantity.toStringAsFixed(
                        product.quantity.truncateToDouble() == product.quantity
                            ? 0
                            : 1,
                      );
                      // Show alert for insufficient stock
                      AleartBox.showAleart(
                        context,
                        DialogType.warning,
                        'Insufficient Stock',
                        'The entered quantity exceeds the available stock (${product.quantity})',
                      );
                    } else {
                      // Update quantity if within available stock
                      invoiceLogic.updateProductQuantity(product, quantity);
                      setState(() {});
                    }
                  }
                },
              ),
            ),
            IconButton(
              onPressed: () {
                double currentQuantity = double.tryParse(controller.text) ?? 0;
                double increment = 1;
                double newQuantity = currentQuantity + increment;
                if (newQuantity <= product.quantity) {
                  // Only update the text field and quantity if the new quantity is within the available quantity
                  controller.text = newQuantity.toStringAsFixed(
                      newQuantity.truncateToDouble() == newQuantity ? 0 : 1);
                  invoiceLogic.updateProductQuantity(product, newQuantity);
                  setState(() {});
                } else {
                  // Show alert when trying to increase beyond available stock
                  controller.text = product.quantity.toStringAsFixed(
                      product.quantity.truncateToDouble() == product.quantity
                          ? 0
                          : 1);
                  invoiceLogic.updateProductQuantity(product, product.quantity);
                  setState(() {});

                  AleartBox.showAleart(
                    context,
                    DialogType.warning,
                    'Maximum Quantity Reached',
                    'The maximum quantity allowed is ${product.quantity}.',
                  );
                }
              },
              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
              tooltip: 'Increase',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection() {
    double totalBillAmount = invoiceLogic.getTotalBillAmount();
    double discountAmount = invoiceLogic.getDiscountAmount();

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          color: AppColor.primaryColor, // Choose your desired border color
          width: 1.0, // Choose the width of the border
        ),
        color: AppColor.accentColor.withOpacity(0.3),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.18,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Bill",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor)),
                Text("Rs.${totalBillAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Outstanding Balance",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor)),
                Text('Rs.${invoiceLogic.outstandingBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "Discount (${totalBillAmount == 0 ? '0.0' : (discountAmount / totalBillAmount * 100).toStringAsFixed(2)}%)",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor)),
                Text("Rs.${discountAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Always start with "Payable Total" as the initial label
                const Text("Payable Total",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor)),
                FutureBuilder<double>(
                  future: invoiceLogic.getTotalPriceWithDiscount(),
                  builder: (context, snapshot) {
                    String
                        rightSideText; // Variable to hold the dynamic right side text

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      rightSideText =
                          "Calculating..."; // Show while data is loading
                    } else if (snapshot.hasError) {
                      // Logger()
                      //     .e("Error fetching total price: ${snapshot.error}");
                      rightSideText =
                          "Error: ${snapshot.error}"; // Display errors distinctly
                    } else {
                      double totalDue =
                          snapshot.data ?? 0.0; // Fetched total amount due
                      // Logger().d("Fetched Total Due: $totalDue");

                      // Determine the right side text based on the payment status
                      if (invoiceLogic.isFullyPaid) {
                        rightSideText =
                            "Rs.${invoiceLogic.paidAmount.toStringAsFixed(2)}"; // Show paid amount if fully paid
                        // Logger().d(
                        //     "Invoice fully paid, displaying Paid Amount: ${invoiceLogic.paidAmount}");
                      } else if (invoiceLogic.isPartiallyPaid) {
                        rightSideText =
                            "Rs.0.00"; // Display '0.0' for partially paid invoices
                        //Logger().d("Invoice partially paid, displaying '0.0'");
                      } else {
                        rightSideText =
                            "Rs.${totalDue.toStringAsFixed(2)}"; // Otherwise, show the total due
                        // Logger().d(
                        //     "Invoice not fully or partially paid, showing Total Due: $totalDue");
                      }
                    }

                    return Text(rightSideText,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColor.primaryColor));
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPaymentSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey), // Border color
        borderRadius: BorderRadius.circular(6), // Border radius
      ),
      child: ExpansionTileCard(
        expandedColor: Colors.grey[300],
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
                          // Check if all required conditions are met before proceeding
                          if (invoiceLogic.selectedClient == null ||
                              invoiceLogic.selectedPaymentMethod == null ||
                              invoiceLogic.productQuantities.isEmpty) {
                            AleartBox.showAleart(
                              context,
                              DialogType.warning,
                              'Unable to Full Paid Invoice',
                              'You must select a client, a payment method, and at least one product before adding payment.',
                            );
                          } else {
                            double payableAmount =
                                await invoiceLogic.getTotalPriceWithDiscount();
                            String selectedPaymentMethod = invoiceLogic
                                    .selectedPaymentMethod?.paymentName ??
                                '';

                            Logger().d(
                                "Payment Method Selected: $selectedPaymentMethod");

                            if (selectedPaymentMethod != 'Cash' &&
                                selectedPaymentMethod != 'Cheque') {
                              AleartBox.showAleart(
                                context,
                                DialogType.error,
                                'Error',
                                'Full payment cannot be made using credit.',
                              );
                            } else {
                              setState(() {
                                invoiceLogic.isFullyPaid = true;
                                invoiceLogic.paidAmount = payableAmount;
                                invoiceLogic.outstandingBalance = 0.0;
                                Logger().f(
                                  "Invoice marked as fully paid. Total price: $payableAmount, Fully Paid Amount: ${invoiceLogic.paidAmount}, Outstanding Balance: ${invoiceLogic.outstandingBalance}",
                                );
                              });

                              AleartBox.showAleart(
                                context,
                                DialogType.success,
                                'Success',
                                'Invoice marked as fully paid.',
                              );
                            }
                          }
                        },
                        buttonText: 'Full Paid Now',
                        backgroundColor: AppColor.accentColor,
                        textColor: Colors.white,
                        strokeColor: AppColor.accentStrokeColor,
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
                            decoration: InputDecoration(
                              labelText: 'Select Date',
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  // Handle date selection
                                },
                                icon: const Icon(Icons.calendar_today),
                              ),
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
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter the amount';
                              }
                              return null; // Return null if the input is valid
                            },
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
                          onPressed: () async {
                            setState(() {
                              _amountController.clear();
                              invoiceLogic.paidAmount = 0.0;
                              showPaymentFields = false;
                              invoiceLogic.isPartiallyPaid = false;
                              invoiceLogic.isFullyPaid = false;
                              invoiceLogic.outstandingBalance;
                            });
                            await invoiceLogic.getOutstandingBalance(
                                invoiceLogic.selectedClient!.clientId);
                          },
                          buttonText: 'Cancel',
                          backgroundColor: AppColor.accentColor,
                          textColor: Colors.white,
                          strokeColor: AppColor.accentStrokeColor,
                          borderRadius: 10,
                        ),
                        const SizedBox(width: 8),
                        CustomAddButton(
                          onPressed: () async {
                            double payableTotal =
                                await invoiceLogic.getTotalPriceWithDiscount();
                            if (_amountController.text.isEmpty ||
                                _amountController.text.trim().isEmpty ||
                                (double.tryParse(_amountController.text) ??
                                        0) <=
                                    0) {
                              AleartBox.showAleart(
                                context,
                                DialogType.error,
                                'Error',
                                'Please enter a valid amount.',
                              );
                            } else {
                              double paymentAmount =
                                  double.parse(_amountController.text);
                              Logger().d('Entered Amount: $paymentAmount');

                              if (paymentController.text == 'Cash' ||
                                  paymentController.text == 'Cheque' ||
                                  paymentController.text == 'Credit') {
                                // Proceed to adjust the payment
                                double newBalance =
                                    payableTotal - paymentAmount;
                                bool isPartiallyPaid = newBalance > 0 &&
                                    paymentAmount < payableTotal;

                                setState(() {
                                  invoiceLogic.paidAmount += paymentAmount;
                                  invoiceLogic.outstandingBalance = newBalance;

                                  // Update the partially paid flag based on the new balance
                                  invoiceLogic.isPartiallyPaid =
                                      isPartiallyPaid;

                                  if (isPartiallyPaid &&
                                      paymentController.text != 'Credit') {
                                    // If the invoice is partially paid and the method was Cash or Cheque, change to Credit
                                    invoiceLogic
                                        .updateSelectedPaymentMethod('Credit');
                                    paymentController.text = 'Credit';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Payment method changed to Credit.'),
                                      ),
                                    );
                                    Logger().d(
                                        'Payment method changed to Credit due to partial payment.');
                                  }

                                  Logger().d(
                                      'New balance after payment: $newBalance');
                                  Logger().d(
                                      'Is partially paid: ${invoiceLogic.isPartiallyPaid}');
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Amount of Rs.${paymentAmount.toStringAsFixed(2)} added successfully! New balance: Rs.${newBalance.toStringAsFixed(2)}'),
                                  ),
                                );
                              } else {
                                AleartBox.showAleart(
                                  context,
                                  DialogType.error,
                                  'Error',
                                  'Invalid payment method for this action.',
                                );
                              }

                              // Clear the text field after processing
                              _amountController.clear();
                            }
                          },
                          buttonText: 'Add',
                          backgroundColor: AppColor.accentColor,
                          textColor: Colors.white,
                          strokeColor: AppColor.accentStrokeColor,
                          borderRadius: 10,
                        )
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
      buttonText: 'Print Invoice',
      onTap: () async {
        bool canPrint = invoiceLogic.canPrintInvoice();
        if (canPrint) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PrintInvoice(invoiceLogic: invoiceLogic)),
          );
        } else {
          // Show an error alert if the requirements are not met
          AleartBox.showAleart(
            context,
            DialogType.error,
            'Incomplete Information',
            invoiceLogic.invoiceErrorMessage,
          );
        }
      },
      buttonColor: invoiceLogic.canPrintInvoice()
          ? AppColor.accentColor
          : AppColor.disableBtnColor, // Enable or disable the button visually
      isLoading: false,
    );
  }
}
