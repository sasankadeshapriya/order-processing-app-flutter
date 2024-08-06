import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:order_processing_app/models/invoice_modle.dart';

import '../components/alert_dialog.dart';
import '../models/clients_modle.dart';
import '../models/payments_modle.dart';
import '../models/processed_product.dart'; // Import the existing ProcessedProduct model
import '../models/product_modle.dart';
import '../models/product_response.dart';
import '../models/vehicle_inventory_modle.dart';
import '../services/client_api_service.dart';
import '../services/invoice_api_service.dart';
import '../services/product_api_service.dart';
import '../services/token_manager.dart';
import '../services/vehicle_inventory_service.dart';
import '../views/main/dashboard.dart';

class InvoiceLogic extends ChangeNotifier {
  late List<Client> clients;
  late List<Product> productList;
  late Map<Product, double> productQuantities;
  List<PaymentMethod> paymentMethods = [];
  PaymentMethod? selectedPaymentMethod;
  Product? selectedProduct;
  Client? selectedClient;
  late int? empId = TokenManager.empId;
  String employeeName = '';
  String invoiceErrorMessage = '';
  double? _outstandingBalance = 0.0;
  double _tempOutstandingBalance = 0.0;
  //double? totalPrice = 0.0;
  double _totalPriceWithDiscount = 0.0;
  double _tempTotalPriceWithDiscount = 0.0;
  bool isFullyPaid = false;
  bool isPartiallyPaid = false;
  double paidAmount = 0.0;
  double totalPayableAmount = 0.0;
  int decimalEntryAttempts = 0;
  bool showPaymentFields = false;
  bool isFullCreditApplied = false;
  bool isFullPaidApplied = false;
  bool _isOutstandingBalancePaid = false;
  final Map<int, TextEditingController> _quantityControllers = {};

  InvoiceLogic() {
    clients = [];
    productList = [];
    productQuantities = {};
    selectedPaymentMethod = null;
    selectedProduct = null;
    paymentMethods = PaymentMethod.getListFromHardCodedData();
  }

  bool get isOutstandingBalancePaid => _isOutstandingBalancePaid;

  set isOutstandingBalancePaid(bool value) {
    if (_isOutstandingBalancePaid != value) {
      _isOutstandingBalancePaid = value;
      applyOutstandingBalanceChanges();
      notifyListeners();
      calculateTotalPriceWithDiscount(); // Recalculate whenever the balance status changes
      notifyListeners();
    }
  }

  double get outstandingBalance => _outstandingBalance ?? 0.0;
  double get tempOutstandingBalance => _tempOutstandingBalance;
  double get totalPriceWithDiscount => _totalPriceWithDiscount;
  double get tempTotalPriceWithDiscount => _tempTotalPriceWithDiscount;

  set outstandingBalance(double value) {
    _outstandingBalance = value;
    notifyListeners();
  }

  void updateTempOutstandingBalance(double value) {
    _tempOutstandingBalance = value;
    notifyListeners();
  }

  void resetTempBalanceToOriginal() {
    _tempOutstandingBalance = _outstandingBalance!;
    notifyListeners();
  }

  void applyOutstandingBalanceChanges() {
    _outstandingBalance = _tempOutstandingBalance;
    notifyListeners();
  }

  void resetTempTotalPriceToOriginal() {
    _tempTotalPriceWithDiscount = _totalPriceWithDiscount;
    notifyListeners();
  }

  void updateTempTotalPriceWithDiscount(double value) {
    _tempTotalPriceWithDiscount = double.parse(value.toStringAsFixed(2));
    notifyListeners();
  }

  void applyPriceChanges() {
    _totalPriceWithDiscount =
        double.parse(_tempTotalPriceWithDiscount.toStringAsFixed(2));
    notifyListeners();
  }

  void updateSelectedPaymentMethod(String paymentMethodName) {
    selectedPaymentMethod = paymentMethods.firstWhere(
      (paymentMethod) => paymentMethod.paymentName == paymentMethodName,
      orElse: () => selectedPaymentMethod as PaymentMethod,
    );
  }

  bool canPrintInvoice() {
    if (selectedClient == null ||
        selectedPaymentMethod == null ||
        productQuantities.isEmpty) {
      invoiceErrorMessage =
          'You must select a client, a payment method, and at least one product before you can print the invoice.';
      return false;
    } else if (!isFullyPaid && !isPartiallyPaid) {
      invoiceErrorMessage =
          'You must add a payment before you can print the invoice.';
      return false;
    }
    invoiceErrorMessage = '';
    return true;
  }

  List<Map<String, dynamic>> getFormattedProductDetails() {
    return productQuantities.entries.map((entry) {
      final product = entry.key;
      final quantity = entry.value;
      final double price = getPrice(product, selectedPaymentMethod!);
      final double amount = price * quantity;
      return {
        'title': product.name,
        'price': price.toStringAsFixed(2),
        'quantity': quantity,
        'amount': amount.toStringAsFixed(2),
      };
    }).toList();
  }

  void disposeControllers() {
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    _quantityControllers.clear();
  }

  TextEditingController getControllerForProduct(Product product) {
    return _quantityControllers.putIfAbsent(
      product.id,
      () => TextEditingController(
        text: productQuantities[product]?.toStringAsFixed(1) ?? '0.0',
      ),
    );
  }

  Future<void> getOutstandingBalance(int clientId) async {
    try {
      _outstandingBalance = await InvoiceService.getClientBalance(clientId);
      _tempOutstandingBalance =
          _outstandingBalance ?? 0.0; // Initialize temp with fetched value
      notifyListeners();
      Logger().i('Outstanding balance updated: $_outstandingBalance');
    } catch (e) {
      Logger().e('Error fetching client balance: $e');
      _outstandingBalance = 0;
      _tempOutstandingBalance = 0;
      notifyListeners();
    }
  }

  Future<void> fetchClients(BuildContext context) async {
    try {
      final clientData = await ClientService.getClients();
      // Filter clients to include only those with a 'verified' status
      clients =
          clientData.where((client) => client.status == 'verified').toList();
    } catch (error) {
      Logger().e('Error fetching clients: $error');
      // Error handling remains the same as you have already implemented
      String userFriendlyMessage =
          "We're having trouble loading client information right now.";
      if (error.toString().contains('TimeoutException')) {
        userFriendlyMessage =
            "Connection timed out. Please check your internet connection and try again.";
      } else if (error.toString().contains('SocketException')) {
        userFriendlyMessage =
            "Unable to connect. Please check your network settings.";
      } else if (error.toString().contains('HttpException')) {
        userFriendlyMessage =
            "Trouble connecting to the server. Please try again later.";
      } else {
        userFriendlyMessage =
            "An unexpected error occurred. Please try again later.";
      }

      if (context != null) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error'),
            content: Text(userFriendlyMessage),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> fetchProductDetails(
      int empId, String currentDate, BuildContext context) async {
    try {
      ProductResponse productResponse =
          await ProductService.fetchProducts(empId, currentDate);
      productList = productResponse.products;
      employeeName = productResponse.employeeName;
      // Now you can use productList and employeeName in your logic
    } catch (error) {
      Logger().e('Error fetching product details: $error');

      // Determine a user-friendly message based on the type of error
      String userFriendlyMessage =
          "We're unable to load the products at this moment.";
      if (error.toString().contains('TimeoutException')) {
        userFriendlyMessage =
            "Connection timed out. Please check your internet connection and try again.";
      } else if (error.toString().contains('SocketException')) {
        userFriendlyMessage =
            "Unable to connect. Please check your network settings.";
      } else if (error.toString().contains('HttpException')) {
        userFriendlyMessage =
            "Trouble connecting to the server. Please try again later.";
      }

      // Show Awesome Dialog with a user-friendly error message
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Failed to Load Products',
        desc: userFriendlyMessage,
        btnOkOnPress: () {},
      ).show();
    }
  }

  String generateInvoiceNumber() {
    final now = DateTime.now();
    final formattedDateTime = DateFormat('yyyyMMddHHmmss').format(now);
    return 'INV-${empId ?? 'UNKNOWN'}-$formattedDateTime';
  }

  void resetPaymentStatus() {
    isFullyPaid = false;
    isPartiallyPaid = false;
  }

  int getSelectedProductCount() {
    return productQuantities.values.where((quantity) => quantity > 0).length;
  }

  void selectPaymentMethod(PaymentMethod? paymentMethod) {
    selectedPaymentMethod = paymentMethod;
  }

  void increaseQuantity(Product product) {
    productQuantities[product] = (productQuantities[product] ?? 0) + 1;
    calculateTotalPriceWithDiscount();
    notifyListeners();
  }

  void decreaseQuantity(Product product, {double decrement = 1.0}) {
    final currentQuantity = productQuantities[product] ?? 0.0;
    productQuantities[product] =
        currentQuantity > decrement ? currentQuantity - decrement : 0.0;
    calculateTotalPriceWithDiscount();
    notifyListeners();
  }

  void updateProductQuantity(Product product, double newQuantity) {
    productQuantities[product] = newQuantity;
    calculateTotalPriceWithDiscount();
    notifyListeners();
  }

  void addSelectedProduct(Product product) {
    selectedProduct = product;
    productQuantities.putIfAbsent(product, () => 1);
  }

  void removeSelectedProduct(Product product) {
    selectedProduct = null;
    productQuantities.remove(product);
    calculateTotalPriceWithDiscount();
    notifyListeners();
    resetTempBalanceToOriginal();
    notifyListeners();
  }

  double getPrice(Product product, PaymentMethod paymentMethod) {
    switch (paymentMethod.paymentName) {
      case 'Cash':
        return product.cashPrice;
      case 'Credit':
        return product.creditPrice;
      case 'Cheque':
        return product.checkPrice;
      default:
        return 0.0;
    }
  }

  double getTotalBillAmount() {
    double total = productQuantities.entries.fold(0.0, (total, entry) {
      final product = entry.key;
      final quantity = entry.value;
      final price = getPrice(product, selectedPaymentMethod!);
      return total + (price * quantity);
    });
    return double.parse(
        total.toStringAsFixed(2)); // Round the total to two decimal places
  }

  double getDiscountAmount() {
    if (selectedClient != null && selectedClient!.discount > 0) {
      final totalBill = getTotalBillAmount();
      double discount = totalBill * (selectedClient!.discount / 100);
      return double.parse(discount
          .toStringAsFixed(2)); // Round the discount to two decimal places
    }
    return 0.0;
  }

  Future<void> calculateTotalPriceWithDiscount() async {
    final totalBill = getTotalBillAmount();
    final discount = getDiscountAmount();
    final outstanding = isOutstandingBalancePaid ? outstandingBalance : 0.0;
    _totalPriceWithDiscount = totalBill - discount + outstanding;
    _tempTotalPriceWithDiscount = _totalPriceWithDiscount;
    notifyListeners();
  }

  Future<void> processInvoiceData(
    VehicleInventoryService vehicleInventoryService,
    InvoiceService invoiceService,
    BuildContext context,
  ) async {
    final processedProducts = processProducts();

    await updateVehicleInventory(
        processedProducts, vehicleInventoryService, context);
    await postInvoiceData(processedProducts, invoiceService, context);
  }

  List<ProcessedProduct> processProducts() {
    return productQuantities.entries.map((entry) {
      final product = entry.key;
      final quantity = entry.value;
      final price = getPrice(product, selectedPaymentMethod!);
      return ProcessedProduct(
        product: product,
        quantity: quantity,
        price: price,
        sum: price * quantity,
      );
    }).toList();
  }

  String calculateCreditPeriodEndDate(int creditPeriod) {
    final endDate = DateTime.now().add(Duration(days: creditPeriod));
    return DateFormat('yyyy-MM-dd').format(endDate);
  }

  Future<void> updateVehicleInventory(
    List<ProcessedProduct> processedProducts,
    VehicleInventoryService vehicleInventoryService,
    BuildContext context,
  ) async {
    // Function to validate and parse quantity input
    double parseQuantity(String input) {
      // Add a leading zero if the input starts with a decimal point
      if (input.startsWith('.')) {
        input = '0$input';
      }

      // Try to parse the input as a double
      try {
        return double.parse(input);
      } catch (e) {
        Logger().e('Invalid quantity input: $input');
        return 0.0;
      }
    }

    // Flag to track if any product update was successful
    bool updateSuccessful = false;

    for (final processedProduct in processedProducts) {
      // Validate and parse the quantity input
      final inputQuantity = processedProduct.quantity;
      final validQuantity = parseQuantity(inputQuantity.toString());

      // Use the quantity from the Product class to get the current available stock
      final currentAvailableStock = processedProduct.product.quantity;

      // Calculate new available stock
      final newAvailableStock = currentAvailableStock - validQuantity;
      if (newAvailableStock < 0) {
        Logger().e(
            'Not enough stock for product ID: ${processedProduct.product.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Not enough stock for product ID: ${processedProduct.product.id}'),
            duration: const Duration(seconds: 2),
          ),
        );
        continue;
      }

      // Update vehicle inventory with new available stock
      final vehicleInventory = VehicleInventory(
        quantity: newAvailableStock,
        sku: processedProduct.product.sku,
        productId: processedProduct.product.id,
        addedByAdminId: empId!,
        assignmentId: processedProduct.product.assignmentId,
      );

      // Send updated inventory to the database
      final success = await vehicleInventoryService.updateVehicleInventory(
        processedProduct.product.vehicleInventoryId,
        vehicleInventory,
      );

      if (success) {
        updateSuccessful = true; // Set flag to true if update is successful
        Logger().i(
            'Vehicle inventory updated for product ID: ${processedProduct.product.id}');
      } else {
        Logger().e(
            'Failed to update vehicle inventory for product ID: ${processedProduct.product.id}');
      }
    }

    // Show a single SnackBar after updating all products
    if (updateSuccessful) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle inventory updated successfully'),
          duration: Duration(seconds: 2), // Adjust the duration as needed
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update vehicle inventory for some products'),
          duration: Duration(seconds: 2), // Adjust the duration as needed
        ),
      );
    }
  }

  Future<void> postInvoiceData(
    List<ProcessedProduct> processedProducts,
    InvoiceService invoiceService,
    BuildContext context,
  ) async {
    try {
      final totalAmount = tempTotalPriceWithDiscount;
      ();

      final invoiceProducts = processedProducts.map((processedProduct) {
        return InvoiceProduct(
          productId: processedProduct.product.id,
          batchId: processedProduct.product.sku,
          quantity: processedProduct.quantity,
          sum: processedProduct.sum,
        );
      }).toList();

      // Ensure creditPeriod is not null before using it
      final creditPeriod =
          selectedClient!.creditPeriod ?? 0; // Provide a default value if null
      final creditPeriodEndDate = calculateCreditPeriodEndDate(creditPeriod);

      final invoice = InvoiceModle(
        referenceNumber: generateInvoiceNumber(),
        clientId: selectedClient!.clientId,
        employeeId: empId!,
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        balance: outstandingBalance,
        discount: getDiscountAmount(),
        creditPeriodEndDate: creditPeriodEndDate,
        paymentOption: selectedPaymentMethod!.paymentName.toLowerCase(),
        products: invoiceProducts,
      );

      Logger().w('Posting invoice data...');

      final postResult = await invoiceService.postInvoiceData(invoice);

      Logger().w('Invoice data post result: $postResult');

      if (postResult['success']) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          headerAnimationLoop: false,
          animType: AnimType.bottomSlide,
          title: 'Success',
          desc: 'Invoice data has been successfully saved.',
          btnOkOnPress: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const UserDashboard()));
          },
          // Customize the OK button text if needed
          btnOkText: 'OK',
          // Customize the OK button's text color if needed
          btnOkColor: Colors.green,
        ).show();
      } else {
        AleartBox.showAleart(context, DialogType.error, 'Error',
            postResult['message'] ?? 'Unknown error occurred.');
      }
    } catch (e) {
      Logger().e('Error posting invoice data: $e');
      AleartBox.showAleart(context, DialogType.error, 'Error',
          'An error occurred while posting invoice data: $e');
    }
  }

  //================================================================================================

  Future<void> markInvoiceAsFullyPaid(
      BuildContext context,
      TextEditingController bankController,
      TextEditingController chequeNumberController,
      TextEditingController amountController,
      TextEditingController dateController,
      [String customMessage =
          "The invoice has been fully paid."] // Optional with default value
      ) async {
    isFullyPaid = true;
    isPartiallyPaid = false;
    paidAmount = getTotalBillAmount() - getDiscountAmount();
    totalPayableAmount = paidAmount;
    showPaymentFields = true;

    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: 'Invoice Fully Paid',
      desc: customMessage, // Use the passed or default message here
      btnOkOnPress: () {},
    ).show();
  }

  void clearPaymentFields(
      TextEditingController bankController,
      TextEditingController chequeNumberController,
      TextEditingController amountController,
      TextEditingController dateController) {
    bankController.clear();
    chequeNumberController.clear();
    amountController.clear();
    dateController.clear();
    showPaymentFields = false;
  }

  Future<bool> validateAmount(double amount) async {
    double totalPriceWithDiscount =
        double.parse(tempTotalPriceWithDiscount.toStringAsFixed(2));
    Logger().w(
        '${totalPriceWithDiscount.toStringAsFixed(2)}'); // Logging the price formatted to two decimals
    Logger().f(
        '${amount.toStringAsFixed(2)}'); // Logging the amount formatted to two decimals
    return amount <= totalPriceWithDiscount;
  }

  //await getTotalPriceWithDiscount();
  bool validateDate(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  // New method to handle logic based on payment method
  Future<void> handleFullPayment(
      BuildContext context,
      String paymentMethod,
      TextEditingController bankController,
      TextEditingController chequeNumberController,
      TextEditingController amountController,
      TextEditingController dateController) async {
    switch (paymentMethod) {
      case 'Cash':
        if (isOutstandingBalancePaid) {
          Logger().f("inside fullpaid cash switch");

          updateTempOutstandingBalance(0.0);
        } else {
          resetTempBalanceToOriginal();
        }
        markInvoiceAsFullyPaid(context, bankController, chequeNumberController,
            amountController, dateController);
        showPaymentFields = false; // Allow to add partial payment
        break;

      case 'Credit':
        if (isOutstandingBalancePaid) {
          Logger().f("inside fullpaid credit switch");
          isFullyPaid = true;
          updateTempOutstandingBalance(tempTotalPriceWithDiscount);
          updateTempTotalPriceWithDiscount(0.0);

          Logger().f("isoutbalnce paid true $outstandingBalance, $paidAmount");
        } else {
          updateTempOutstandingBalance(
              outstandingBalance + tempTotalPriceWithDiscount);
          updateTempTotalPriceWithDiscount(0.0);
          Logger()
              .f("isoutbalnce paid false :$outstandingBalance, $paidAmount");
        }
        markInvoiceAsFullyPaid(
            context,
            bankController,
            chequeNumberController,
            amountController,
            dateController,
            "The invoice has been set as fully credit ");
        showPaymentFields = false; // Allow to add partial payment
        break;

      case 'Cheque':
        if (isOutstandingBalancePaid) {
          Logger().f("inside fullpaid cheque switch");

          updateTempOutstandingBalance(0.0);
          tempTotalPriceWithDiscount;
        } else {
          tempOutstandingBalance;
          tempTotalPriceWithDiscount;
        }
        amountController.text = tempTotalPriceWithDiscount.toStringAsFixed(2);
        showPaymentFields = true;
        break;

      default:
        break;
    }
    FocusScope.of(context).requestFocus(FocusNode()); // Hide keyboard
  }

  Future<void> handlePartialPayment(
      BuildContext context, TextEditingController amountController) async {
    double enteredAmount = double.tryParse(amountController.text) ?? 0.0;
    double payableTotal = tempTotalPriceWithDiscount;

    Logger().i(
        'Entered Amount: $enteredAmount, Payable Total: $payableTotal, Payment Method: ${selectedPaymentMethod?.paymentName}, ispaidoutbalance: $isOutstandingBalancePaid');

    switch (selectedPaymentMethod?.paymentName) {
      case 'Cash':
        if (enteredAmount != payableTotal) {
          AleartBox.showAleart(
            context,
            DialogType.error,
            'Invalid Payment',
            'Full payment is required when paying with cash. Partial payments are not allowed.',
          );
          return; // Prevent further processing
        }
        showPaymentFields = false;
        break;

      case 'Credit':
        if (isOutstandingBalancePaid) {
          if (enteredAmount == payableTotal) {
            isFullyPaid = true;
            isPartiallyPaid = false;
            updateTempOutstandingBalance(0.0);
          } else {
            isFullyPaid = false;
            isPartiallyPaid = true;
            _tempOutstandingBalance = payableTotal - enteredAmount;
            updateTempTotalPriceWithDiscount(enteredAmount);
          }
        } else {
          if (enteredAmount == payableTotal) {
            isFullyPaid = true;
            isPartiallyPaid = false;
            _tempOutstandingBalance = payableTotal - enteredAmount;
          } else if (enteredAmount < payableTotal) {
            isFullyPaid = false;
            isPartiallyPaid = true;
            updateTempOutstandingBalance(
                (payableTotal - enteredAmount) + outstandingBalance);
            updateTempTotalPriceWithDiscount(enteredAmount);
          }
        }
        break;

      case 'Cheque':
        if (isOutstandingBalancePaid) {
          if (enteredAmount < payableTotal) {
            isFullyPaid = false;
            isPartiallyPaid = true;
            updateTempOutstandingBalance(enteredAmount);
            updateTempTotalPriceWithDiscount(payableTotal - enteredAmount);
          } else if (enteredAmount == payableTotal) {
            isFullyPaid = true;
            isPartiallyPaid = false;
            updateTempOutstandingBalance(0.0);
          }
        } else if (enteredAmount < payableTotal) {
          isFullyPaid = false;
          isPartiallyPaid = true;
          updateTempOutstandingBalance(
              (payableTotal - enteredAmount) + outstandingBalance);
          updateTempTotalPriceWithDiscount(enteredAmount);
        } else if (enteredAmount == payableTotal) {
          isFullyPaid = true;
          isPartiallyPaid = false;
          updateTempOutstandingBalance(0.0);
        }
        break;

      default:
        // Handle unknown or unspecified payment method
        AleartBox.showAleart(
          context,
          DialogType.error,
          'Payment Method Error',
          'The selected payment method is not supported.',
        );
        break;
    }

    // Logic to handle the new balance and update the database can go here...
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: 'Payment Added',
      desc: 'The partial payment has been recorded.',
      btnOkOnPress: () {},
    ).show();
    FocusScope.of(context).requestFocus(FocusNode()); // Hide keyboard
  }

  // off if onece click full paid now or full credit button
  void applyFullCredit() {
    if (!isFullCreditApplied) {
      // Logic to apply full credit
      isFullCreditApplied = true;
      notifyListeners();
    }
  }

  void applyFullPaid() {
    if (!isFullPaidApplied) {
      // Logic to apply full payment
      isFullPaidApplied = true;
      notifyListeners();
    }
  }

  void cancelActions() {
    isFullCreditApplied = false;
    isFullPaidApplied = false; // Reset both flags
    notifyListeners();
  }
}
