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
import '../../services/token_manager.dart';
import '../../utils/app_colors.dart';
import '../../utils/invoice_logic.dart';
import '../../utils/util_functions.dart';
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
  final TextEditingController bankController = TextEditingController();
  final TextEditingController chequeNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  String? selectedBank;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool showPaymentFields = false;

  int empId = TokenManager.empId ?? 1;

  @override
  void initState() {
    super.initState();
    fetchProductsAndUpdateUI();
  }

  Future<void> fetchProductsAndUpdateUI() async {
    await invoiceLogic.fetchClients(context);
    // Assuming empId and currentDate are correctly set
    await invoiceLogic.fetchProductDetails(
        empId, UtilFunctions.getCurrentDateTime(), context);
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
                        const SizedBox(height: 20),
                        _buildClientDropdown(width, 200),
                        const SizedBox(height: 20),
                        _buildPaymentMethodDropdown(width),
                        const SizedBox(height: 20),
                        _buildProductDropdown(width),
                        const SizedBox(height: 20),
                        _buildProductList(),
                        //const SizedBox(height: 10),
                        _buildTotalSection(),
                        const SizedBox(height: 20),
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
                    if (product.measurementUnit == 'pcs') {
                      // Check if the entered value is a decimal
                      if (quantity % 1 != 0) {
                        // Increment the decimal entry attempts counter
                        invoiceLogic.decimalEntryAttempts++;

                        // Show warning message if more than one decimal entry attempt
                        if (invoiceLogic.decimalEntryAttempts >= 3) {
                          AleartBox.showAleart(
                            context,
                            DialogType.warning,
                            'Invalid Input',
                            'Decimal values are not allowed for pieces (pcs)',
                          );
                        }

                        // Round to the nearest integer
                        int roundedQuantity = quantity.round();
                        controller.text = roundedQuantity.toString();
                        quantity = roundedQuantity.toDouble();
                      }
                    }

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
          width: 1.3, // Choose the width of the border
        ),
        color: AppColor.backgroundColor,
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
        expandedColor: AppColor.backgroundColor,
        //expandedColor: Colors.grey[300],
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
                      Text(
                        'Add Payment Details',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Spacer(),
                      CustomAddButton(
                        onPressed: () async {},
                        buttonText:
                            invoiceLogic.selectedPaymentMethod?.paymentName ==
                                    'Credit'
                                ? 'Fully Credit'
                                : 'Full Paid Now',
                        backgroundColor: AppColor.accentColor,
                        textColor: Colors.white,
                        strokeColor: AppColor.accentStrokeColor,
                        borderRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                if (showPaymentFields) ...[
                  if (invoiceLogic.selectedPaymentMethod?.paymentName ==
                      'Cheque')
                    ..._buildChequeDetailsInputs(),
                  if (invoiceLogic.selectedPaymentMethod?.paymentName ==
                          'Cash' ||
                      invoiceLogic.selectedPaymentMethod?.paymentName ==
                          'Credit')
                    ..._buildOtherPaymentInputs(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChequeDetailsInputs() {
    return [
      _buildBankDropdown(200), //326
      const SizedBox(height: 10), // Dropdown for bank selection
      _buildChequeNumberInput(),
      const SizedBox(height: 10), // Input for cheque number
      _buildAmountInput(),
      const SizedBox(height: 10), // Input for amount
      _buildDateInput(),
      const SizedBox(height: 10), // Input for date
      _buildActionButtons(), // "Cancel" and "Add" buttons
    ];
  }

  List<Widget> _buildOtherPaymentInputs() {
    return [
      _buildAmountInput(),
      const SizedBox(height: 10), // Input for amount
      _buildDateInput(),
      const SizedBox(height: 10), // Input for date
      _buildActionButtons(),
    ];
  }

  Widget _buildBankDropdown(double height) {
    double screenWidth = MediaQuery.of(context).size.width;
    double dropdownWidth = screenWidth * 0.905;
    return DropdownMenu<String>(
      controller: bankController,
      width: dropdownWidth,
      menuHeight: height,
      hintText: "Select Bank",
      requestFocusOnTap: true,
      enableFilter: true,
      menuStyle: MenuStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          invoiceLogic.selectedClient != null
              ? Colors.lightBlue.shade50
              : Colors.grey.shade300,
        ),
      ),
      label: const Text('Select Bank'),
      onSelected: (String? selectedBank) {
        setState(() {
          this.selectedBank = selectedBank;
        });
      },
      dropdownMenuEntries: [
        'Bank of Ceylon (BOC)', // Standardized naming convention
        'Commercial Bank of Ceylon PLC', // This might typically refer to Commercial Bank of Ceylon PLC
        'DFCC Bank',
        'Hatton National Bank (HNB)',
        'National Development Bank PLC (NDB)',
        'Pan Asia Banking Corporation PLC',
        'People’s Bank',
        'Sampath Bank PLC',
        'Seylan Bank PLC',
        'Union Bank of Colombo PLC' // Placeholder bank options
      ].map<DropdownMenuEntry<String>>(
        (String bank) {
          return DropdownMenuEntry<String>(
            value: bank,
            label: bank,
            leadingIcon: Icon(Icons.account_balance), // Just a placeholder icon
          );
        },
      ).toList(),
    );
  }

  Widget _buildChequeNumberInput() {
    return CustomTextFormField(
      labelText: 'Cheque Number',
      hintText: 'Cheque Number',
      textAlign: TextAlign.left,
      controller: chequeNumberController,
      keyboardType: TextInputType.number,
      onSaved: (value) {},
    );
  }

  Widget _buildAmountInput() {
    return CustomTextFormField(
      labelText: 'Amount',
      hintText: 'Amount',
      textAlign: TextAlign.left,
      controller: amountController,
      keyboardType: TextInputType.number,
      onSaved: (value) {},
    );
  }

  Widget _buildDateInput() {
    return CustomTextFormField(
      controller: dateController,
      labelText: 'Date',
      hintText: 'Select Date',
      textAlign: TextAlign.left,
      suffixIcon: const Icon(Icons.calendar_today),
      onSuffixIconTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          setState(() {
            dateController.text = formattedDate;
          });
        }
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          flex: 1, // Adjust flex to change the proportion
          child: CustomAddButton(
            onPressed: () {
              setState(() {
                bankController.clear();
                chequeNumberController.clear();
                amountController.clear();
                dateController.clear();
                showPaymentFields = false;
              });
            },
            buttonText: 'Cancel',
            backgroundColor: AppColor.accentColor,
            textColor: Colors.white,
            strokeColor: AppColor.accentStrokeColor,
            borderRadius: 10,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1, // Adjust flex to change the proportion
          child: CustomAddButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                print('Cheque details added');
              }
            },
            buttonText: 'Add',
            backgroundColor: AppColor.accentColor,
            textColor: Colors.white,
            strokeColor: AppColor.accentStrokeColor,
            borderRadius: 10,
          ),
        ),
      ],
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
          : AppColor.disableBtnColor,
      isLoading: false,
    );
  }
}
