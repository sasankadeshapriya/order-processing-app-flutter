import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../components/alert_dialog.dart';
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
  late InvoiceLogic invoiceLogic;
  late final PrintInvoice printInvoice;
  final TextEditingController clientController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController paymentController = TextEditingController();
  final TextEditingController bankController = TextEditingController();
  final TextEditingController chequeNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  String? selectedBank;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int empId = TokenManager.empId ?? 1;
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  bool _connected = false;
  bool isLoading = false;
  BluetoothDevice? _device;
  String tips = 'No device connected';

  @override
  void initState() {
    super.initState();
    invoiceLogic = Provider.of<InvoiceLogic>(context, listen: false);
    printInvoice = PrintInvoice();
    printInvoice.setInvoiceLogic(invoiceLogic);
    fetchProductsAndUpdateUI();
  }

  Future<void> fetchProductsAndUpdateUI() async {
    await invoiceLogic.fetchClients(context);
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
                        _buildTotalSection(),
                        const SizedBox(height: 20),
                        _buildAddPaymentSection(),
                        const SizedBox(height: 20),
                        Expanded(child: Container()), // Pushes button to bottom
                        //Center(child: _buildPrintInvoiceButton()),
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
          AleartBox.showAleart(context, DialogType.error, 'Selection Required',
              'Please select a client first.');
        }
      },
      child: AbsorbPointer(
        absorbing: invoiceLogic.selectedClient == null,
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
              invoiceLogic.calculateTotalPriceWithDiscount();
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
                invoiceLogic.calculateTotalPriceWithDiscount();
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
                  if (newValue.startsWith('.')) {
                    newValue = '0$newValue';
                  }

                  double? quantity = double.tryParse(newValue);
                  if (quantity != null) {
                    if (product.measurementUnit == 'pcs') {
                      if (quantity % 1 != 0) {
                        invoiceLogic.decimalEntryAttempts++;
                        if (invoiceLogic.decimalEntryAttempts >= 3) {
                          AleartBox.showAleart(
                            context,
                            DialogType.warning,
                            'Invalid Input',
                            'Decimal values are not allowed for pieces (pcs)',
                          );
                        }
                        invoiceLogic.decimalEntryAttempts = 0;
                        int roundedQuantity = quantity.round();
                        controller.text = roundedQuantity.toString();
                        quantity = roundedQuantity.toDouble();
                      }
                    }

                    if (quantity > product.quantity) {
                      controller.text = product.quantity.toStringAsFixed(
                        product.quantity.truncateToDouble() == product.quantity
                            ? 0
                            : 1,
                      );
                      AleartBox.showAleart(
                        context,
                        DialogType.warning,
                        'Insufficient Stock',
                        'The entered quantity exceeds the available stock (${product.quantity})',
                      );
                    } else {
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
                  controller.text = newQuantity.toStringAsFixed(
                      newQuantity.truncateToDouble() == newQuantity ? 0 : 1);
                  invoiceLogic.updateProductQuantity(product, newQuantity);
                  setState(() {});
                } else {
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
    return Consumer<InvoiceLogic>(
      builder: (context, invoiceLogic, child) {
        double totalBillAmount = invoiceLogic.getTotalBillAmount();
        double discountAmount = invoiceLogic.getDiscountAmount();

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
              color: AppColor.primaryColor,
              width: 1.3,
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
                    const Text(
                      "Outstanding Balance",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 20,
                      child: ToggleSwitch(
                        minWidth: 36.0,
                        cornerRadius: 20.0,
                        activeBgColors: [
                          [Colors.red[800]!],
                          [AppColor.primaryColor]
                        ],
                        activeFgColor: Colors.white,
                        inactiveBgColor: Colors.grey,
                        inactiveFgColor: Colors.white,
                        initialLabelIndex:
                            invoiceLogic.isOutstandingBalancePaid ? 1 : 0,
                        totalSwitches: 2,
                        labels: ['Not', 'Paid'],
                        customTextStyles: [
                          TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold),
                          TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold),
                        ],
                        radiusStyle: true,
                        onToggle: (index) {
                          Provider.of<InvoiceLogic>(context, listen: false)
                              .calculateTotalPriceWithDiscount();
                          //invoiceLogic.calculateTotalPriceWithDiscount();
                          invoiceLogic.isOutstandingBalancePaid = index == 0;
                        },
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Rs.${invoiceLogic.tempOutstandingBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor,
                      ),
                    ),
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
                    const Text("Payable Total",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColor.primaryColor)),
                    Text(
                        'Rs.${invoiceLogic.tempTotalPriceWithDiscount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColor.primaryColor)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddPaymentSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ExpansionTileCard(
        expandedColor: AppColor.backgroundColor,
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
                      invoiceLogic.showPaymentFields =
                          !invoiceLogic.showPaymentFields;
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
                        onPressed: invoiceLogic.isFullCreditApplied ||
                                invoiceLogic.isFullPaidApplied
                            ? () {} // Provide an empty function to disable the button
                            : () {
                                if (invoiceLogic
                                        .selectedPaymentMethod?.paymentName ==
                                    'Credit') {
                                  invoiceLogic
                                      .applyFullCredit(); // Apply full credit
                                } else {
                                  invoiceLogic
                                      .applyFullPaid(); // Apply full payment
                                }
                                _handlePayment(context);
                                setState(
                                    () {}); // Your existing payment handling logic
                              },
                        buttonText:
                            invoiceLogic.selectedPaymentMethod?.paymentName ==
                                    'Credit'
                                ? 'Fully Credit'
                                : 'Fully Paid Now',
                        backgroundColor: AppColor.accentColor,
                        textColor: Colors.white,
                        strokeColor: AppColor.accentStrokeColor,
                        borderRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                if (invoiceLogic.showPaymentFields) ...[
                  if (invoiceLogic.selectedPaymentMethod?.paymentName ==
                      'Cheque')
                    ..._buildChequeDetailsInputs(),
                  if (invoiceLogic.selectedPaymentMethod?.paymentName ==
                          'Credit' ||
                      invoiceLogic.selectedPaymentMethod?.paymentName == 'Cash')
                    ..._buildOtherPaymentInputs(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePayment(BuildContext context) async {
    if (invoiceLogic.selectedPaymentMethod?.paymentName == 'Cheque') {
      await invoiceLogic.handleFullPayment(
        context,
        'Cheque',
        bankController,
        chequeNumberController,
        amountController,
        dateController,
      );
      setState(() {}); // Update state after handling full payment
    } else if (invoiceLogic.selectedPaymentMethod?.paymentName == 'Cash') {
      await invoiceLogic.handleFullPayment(
        context,
        'Cash',
        bankController,
        chequeNumberController,
        amountController,
        dateController,
      );
      setState(() {
        invoiceLogic.outstandingBalance = 0.0;
      });
    } else if (invoiceLogic.selectedPaymentMethod?.paymentName == 'Credit') {
      await invoiceLogic.handleFullPayment(
        context,
        'Credit',
        bankController,
        chequeNumberController,
        amountController,
        dateController,
      );
      setState(() {
        invoiceLogic.outstandingBalance += invoiceLogic.totalPayableAmount;
        invoiceLogic.totalPayableAmount = 0.0;
      });
    }
  }

  List<Widget> _buildChequeDetailsInputs() {
    return [
      _buildBankDropdown(200),
      const SizedBox(height: 10),
      _buildChequeNumberInput(),
      const SizedBox(height: 10),
      _buildAmountInput(),
      const SizedBox(height: 10),
      _buildDateInput(),
      const SizedBox(height: 10),
      _buildActionButtons(),
    ];
  }

  List<Widget> _buildOtherPaymentInputs() {
    return [
      _buildAmountInput(),
      const SizedBox(height: 10),
      const SizedBox(height: 10),
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
        'Bank of Ceylon (BOC)',
        'Commercial Bank of Ceylon PLC',
        'DFCC Bank',
        'Hatton National Bank (HNB)',
        'National Development Bank PLC (NDB)',
        'Pan Asia Banking Corporation PLC',
        'People’s Bank',
        'Sampath Bank PLC',
        'Seylan Bank PLC',
        'Union Bank of Colombo PLC'
      ].map<DropdownMenuEntry<String>>(
        (String bank) {
          return DropdownMenuEntry<String>(
            value: bank,
            label: bank,
            leadingIcon: Icon(Icons.account_balance),
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
      validator: (value) {
        // Synchronously validate the amount
        double? amount = double.tryParse(value ?? '0.0');
        if (amount == null || amount < 0) {
          // Immediate feedback for clearly invalid input
          return 'Please enter a valid amount';
        }
        // Since actual validation is asynchronous, it should be handled at submission
        return null; // Assuming further validation will occur on form submission
      },
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
          firstDate: DateTime.now(),
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
          flex: 1,
          child: CustomAddButton(
            onPressed: () {
              // Perform any necessary asynchronous operations first.

              // Then, update the UI synchronously within a setState call.
              setState(() {
                invoiceLogic.resetTempBalanceToOriginal();
                //invoiceLogic.applyOutstandingBalanceChanges();
                invoiceLogic.resetTempTotalPriceToOriginal();
                invoiceLogic.getOutstandingBalance(
                    invoiceLogic.selectedClient!.clientId);
                invoiceLogic.calculateTotalPriceWithDiscount();
                invoiceLogic.cancelActions();
                invoiceLogic.isFullyPaid = false;
                invoiceLogic.isPartiallyPaid = false;
                invoiceLogic.clearPaymentFields(
                  bankController,
                  chequeNumberController,
                  amountController,
                  dateController,
                );
                invoiceLogic.showPaymentFields = false;

                FocusScope.of(context)
                    .requestFocus(FocusNode()); // Hide keyboard
              });
            },
            buttonText: 'Cancel',
            backgroundColor: Colors.red,
            textColor: Colors.white,
            strokeColor: Colors.redAccent,
            borderRadius: 10,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: CustomAddButton(
            onPressed: () async {
              // Validate form data
              if (_formKey.currentState!.validate()) {
                double amount = double.tryParse(amountController.text) ?? 0.0;
                bool isValidAmount = await invoiceLogic.validateAmount(amount);
                Logger().w(
                    "Validate Amount: $isValidAmount, Temp Payable Total: ${invoiceLogic.tempTotalPriceWithDiscount.toStringAsFixed(2)}");

                // Check if the entered amount is valid
                if (!isValidAmount) {
                  AleartBox.showAleart(
                    context,
                    DialogType.warning,
                    'Invalid Amount',
                    'The amount entered cannot be greater than the payable total.',
                  );
                  return;
                }

                // Additional validation specific to the 'Cheque' payment method
                // if (invoiceLogic.selectedPaymentMethod?.paymentName ==
                //     'Cheque') {
                //   // Check if the date is valid
                //   DateTime? date = DateTime.tryParse(dateController.text);
                //   if (date == null || !invoiceLogic.validateDate(date)) {
                //     AleartBox.showAleart(
                //       context,
                //       DialogType.warning,
                //       'Invalid Date',
                //       'The date must be in the future.',
                //     );
                //     return;
                //   }
                //
                //   // Check if a bank is selected
                //   if (bankController.text.isEmpty) {
                //     AleartBox.showAleart(
                //       context,
                //       DialogType.warning,
                //       'Bank Required',
                //       'Please select a bank.',
                //     );
                //     return;
                //   }
                //
                //   // Validate the cheque number
                //   if (chequeNumberController.text.isEmpty ||
                //       chequeNumberController.text.length != 6) {
                //     AleartBox.showAleart(
                //       context,
                //       DialogType.warning,
                //       'Invalid Cheque Number',
                //       'Please enter a valid 6-digit cheque number.',
                //     );
                //     return;
                //   }
                // }
                if (amount == invoiceLogic.tempTotalPriceWithDiscount) {
                  await invoiceLogic.markInvoiceAsFullyPaid(
                      context,
                      bankController,
                      chequeNumberController,
                      amountController,
                      dateController);

                  // After marking as fully paid, no need to process partial payment
                  return;
                }

                // Proceed with partial payment handling if not a full payment
                await invoiceLogic.handlePartialPayment(
                    context, amountController);
                invoiceLogic.clearPaymentFields(
                  bankController,
                  chequeNumberController,
                  amountController,
                  dateController,
                );
                invoiceLogic.showPaymentFields = false;
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

  // Widget _buildPrintInvoiceButton() {
  //   return CustomButton(
  //     buttonText: 'Print Receipt',
  //     onTap: () async {
  //       // if (_connected) {
  //       //   try {
  //       //     setState(() {
  //       //       isLoading = true;
  //       //     });
  //       //     await printInvoice._printReceipt();
  //       //     setState(() {
  //       //       isLoading = false;
  //       //     });
  //       //   } catch (e) {
  //       //     Logger().e('Error printing receipt: $e');
  //       //     setState(() {
  //       //       isLoading = false;
  //       //     });
  //       //     if (mounted) {
  //       //       AwesomeDialog(
  //       //         context: context,
  //       //         dialogType: DialogType.error,
  //       //         headerAnimationLoop: false,
  //       //         animType: AnimType.bottomSlide,
  //       //         title: 'Print Error',
  //       //         desc:
  //       //         'An error occurred while printing the receipt. Please try again.',
  //       //         buttonsTextStyle: const TextStyle(color: Colors.black),
  //       //         btnOkOnPress: () {},
  //       //       ).show();
  //       //     }
  //       //   }
  //       // } else {
  //       //   if (mounted) {
  //       //     AwesomeDialog(
  //       //       context: context,
  //       //       dialogType: DialogType.error,
  //       //       headerAnimationLoop: false,
  //       //       animType: AnimType.bottomSlide,
  //       //       title: 'Connection Error',
  //       //       desc:
  //       //       'No device connected. Please connect a device and try again.',
  //       //       buttonsTextStyle: const TextStyle(color: Colors.black),
  //       //       btnOkOnPress: () {},
  //       //     ).show();
  //       //   }
  //       // }
  //     },
  //     buttonColor: AppColor.accentColor,
  //     isLoading: isLoading,
  //   );
  // }
}
