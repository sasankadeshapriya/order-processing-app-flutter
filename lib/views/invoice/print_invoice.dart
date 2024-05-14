import 'dart:async';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../../components/custom_button.dart';
import '../../utils/invoice_logic.dart';
import '../../utils/util_functions.dart';
import '../../models/print_setting_modle.dart';

class PrintInvoice extends StatefulWidget {
  final InvoiceLogic invoiceLogic;

  const PrintInvoice({Key? key, required this.invoiceLogic}) : super(key: key);

  @override
  _PrintInvoiceState createState() => _PrintInvoiceState();
}

class _PrintInvoiceState extends State<PrintInvoice> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  late String invoiceNumber;
  bool _connected = false;
  BluetoothDevice? _device;
  String tips = 'No device connected';
  String formattedDateTime = '';
  late printSettings settings; // Ensure settings class name matches your model
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    logger.w('Initializing state.');
    formattedDateTime = UtilFunctions.getCurrentDateTime();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logger.w('Post frame callback triggered.');
      initBluetooth();
    });
  }

  Future<void> initBluetooth() async {
    logger.w('Fetching settings.');
    settings = await printSettings.fetchSettings();
    invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch}';
    logger.w('Generated invoice number: $invoiceNumber');

    bool isEnabled = await bluetoothPrint.isOn;
    logger.w('Bluetooth enabled status: $isEnabled');

    if (!isEnabled) {
      tips = 'Bluetooth is off. Please turn on Bluetooth and try again.';
      logger.w(tips);
      setState(() {});
      return;
    }

    logger.w('Starting Bluetooth scan.');
    bluetoothPrint.startScan(timeout: const Duration(seconds: 4));
    bool isConnected = await bluetoothPrint.isConnected ?? false;

    bluetoothPrint.state.listen((state) {
      logger.w('Current device status: $state');
      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'Connect success';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'Disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;
    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.w('Building widget.');
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Print Receipt'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              logger.w('Navigating back.');
              Navigator.of(context).pop();
            },
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () {
            logger.w('Refreshing and starting scan.');
            return bluetoothPrint.startScan(
                timeout: const Duration(seconds: 4));
          },
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: Text(tips),
                    ),
                  ],
                ),
                const Divider(),
                StreamBuilder<List<BluetoothDevice>>(
                  stream: bluetoothPrint.scanResults,
                  initialData: const [],
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      logger.w('Received Bluetooth scan results.');
                    }
                    return Column(
                      children: snapshot.data!
                          .map((d) => ListTile(
                                title: Text(d.name ?? 'Unknown device'),
                                subtitle: Text(d.address ?? 'Unknown address'),
                                onTap: () {
                                  setState(() {
                                    _device = d;
                                    logger.w('Device selected: ${d.name}');
                                  });
                                },
                                trailing: _device != null &&
                                        _device!.address == d.address
                                    ? const Icon(Icons.check,
                                        color: Colors.green)
                                    : null,
                              ))
                          .toList(),
                    );
                  },
                ),
                const Divider(),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          OutlinedButton(
                            onPressed: _connected
                                ? null
                                : () async {
                                    if (_device != null &&
                                        _device!.address != null) {
                                      logger.w('Attempting to connect.');
                                      setState(() {
                                        tips = 'Connecting...';
                                      });
                                      await bluetoothPrint.connect(_device!);
                                    } else {
                                      setState(() {
                                        tips = 'Please select device';
                                        logger.w(tips);
                                      });
                                    }
                                  },
                            child: const Text('Connect'),
                          ),
                          const SizedBox(width: 10.0),
                          OutlinedButton(
                            onPressed: _connected
                                ? () async {
                                    logger.w('Disconnecting.');
                                    setState(() {
                                      tips = 'Disconnecting...';
                                    });
                                    await bluetoothPrint.disconnect();
                                  }
                                : null,
                            child: const Text('Disconnect'),
                          ),
                          const SizedBox(width: 10.0),
                          StreamBuilder<bool>(
                            stream: bluetoothPrint.isScanning,
                            initialData: false,
                            builder: (context, snapshot) {
                              logger.w('Scanning status: ${snapshot.data}');
                              if (snapshot.data!) {
                                return FloatingActionButton(
                                  onPressed: () {
                                    logger.w('Stopping scan.');
                                    bluetoothPrint.stopScan();
                                  },
                                  backgroundColor: Colors.red,
                                  child: const Icon(Icons.stop),
                                );
                              } else {
                                return FloatingActionButton(
                                  child: const Icon(Icons.search),
                                  onPressed: () {
                                    logger.w('Starting scan.');
                                    bluetoothPrint.startScan(
                                        timeout: const Duration(seconds: 4));
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      CustomButton(
                        svgIcon: null, // Adjust your button styling as needed
                        buttonText: 'Print Receipt',
                        onTap: () async {
                          if (_connected) {
                            setState(() {
                              tips = 'Printing...';
                              logger.w(tips);
                            });
                             await _printReceipt();
                            setState(() {
                              tips = 'Print success';
                              logger.w(tips);
                            });
                          }
                        },
                        buttonColor:
                            Colors.blue, // Adjust button color as needed
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _printReceipt() async {
    Logger().w('Executing print receipt logic.');
    Logger().w('inside _printReceipt function');
    var selectedClient = widget.invoiceLogic.selectedClient;
    var selectedProduct = widget.invoiceLogic.selectedProduct;
    var quantity = widget.invoiceLogic.productQuantities[selectedProduct];
    var clientName = selectedClient != null ? selectedClient.name : '';
    var employeeName = selectedProduct != null
        ? selectedProduct.employeeName
        : ''; // Assuming such a field exists
    var paymentMethod = widget.invoiceLogic.selectedPaymentMethod?.paymentName;
    int selectedProductCount = widget.invoiceLogic.getSelectedProductCount();

    Logger().f('$clientName');
    Logger().f('$selectedProduct');
    Logger().f('$quantity');
    Logger().f('$employeeName');
    Logger().i('$paymentMethod');

    Map<String, dynamic> config = {};
    List<LineText> list = [];
    const maxWidth = 32;
    const int AmountStart = 23;

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: settings.organizationName,
      weight: 1,
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: settings.addressLine01,
        weight: 1,
        align: LineText.ALIGN_CENTER,
        //fontZoom: 2,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: settings.addressLine02,
        weight: 1,
        align: LineText.ALIGN_CENTER,
        //fontZoom: 2,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Invoice No :$invoiceNumber',
        weight: 1,
        align: LineText.ALIGN_LEFT,
        x: 0,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Client Name: $clientName',
        weight: 1,
        align: LineText.ALIGN_LEFT,
        x: 0,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Ref Name   : $employeeName',
        weight: 1,
        align: LineText.ALIGN_LEFT,
        x: 0,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Payment    : $paymentMethod',
        weight: 1,
        align: LineText.ALIGN_LEFT,
        x: 0,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Date/Time  : $formattedDateTime',
        weight: 1,
        align: LineText.ALIGN_LEFT,
        x: 0,
        relativeX: 0,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: '_______________________________',
        weight: 1,
        align: LineText.ALIGN_LEFT,
        x: 0,
        linefeed: 1));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Item',
        weight: 1,
        align: LineText.ALIGN_LEFT,
        x: 0,
        relativeX: 0,
        linefeed: 0));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Price',
        weight: 1,
        align: LineText.ALIGN_LEFT,
        x: 80,
        relativeX: 0,
        linefeed: 0));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Qty',
        weight: 1,
        align: LineText.ALIGN_LEFT,
        x: 190,
        relativeX: 0,
        linefeed: 0));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Amount',
        weight: 1,
        align: LineText.ALIGN_LEFT,
        x: 310,
        relativeX: 0,
        linefeed: 0));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: '-------------------------------',
        weight: 1,
        align: LineText.ALIGN_LEFT,
        relativeX: 0,
        linefeed: 0));

    // Fallback to first if none selected
    var productDetails = widget.invoiceLogic.getFormattedProductDetails();

    for (var detail in productDetails) {
      // Add each line to print buffer
      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content:
            "${detail['title']} ${detail['price']} x${detail['quantity']} = ${detail['amount']}",
        weight: 1,
        align: LineText.ALIGN_LEFT,
        linefeed: 1,
      ));
    }
    widget.invoiceLogic.productQuantities.forEach((product, quantity) {
      final String title = product.name;
      final double price = widget.invoiceLogic
          .getPrice(product, widget.invoiceLogic.selectedPaymentMethod!);
      final double qty = quantity;
      final String qtyString = 'X$qty';
      final double amount = (price * qty);

      final String amountString = amount.toStringAsFixed(2);
      final int amountLength = amountString.length;
      final int spacesNeeded = maxWidth - (AmountStart + amountLength);
      final String AmountWithSpace = ' ' * spacesNeeded + amountString;

      // Adjust title to fit within the maximum width
      String adjustedTitle;
      if (title.length > maxWidth) {
        final spacesNeeded = title.length - maxWidth;
        adjustedTitle = title.substring(0, maxWidth) + ' ' * spacesNeeded;
      } else {
        adjustedTitle = title.padRight(maxWidth);
      }

      // Add LineText for title
      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: adjustedTitle,
        weight: 1,
        align: LineText.ALIGN_LEFT,
        x: 0,
        relativeX: 0,
        linefeed: 0,
      ));

      // Add LineText for price
      final String priceString = 'Rs.$price';
      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: priceString,
        weight: 1,
        align: LineText.ALIGN_LEFT,
        x: 80,
        relativeX: 0,
        linefeed: 0,
      ));

      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: qtyString,
        weight: 1,
        align: LineText.ALIGN_LEFT,
        x: 190,
        relativeX: 0,
        linefeed: 0,
      ));

      // Add LineText for amount aligned to the maximum right corner
      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: AmountWithSpace,
        weight: 1,
        align: LineText.ALIGN_LEFT,
        x: 270,
        relativeX: 0,
        linefeed: 1,
      ));
    });

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: '_______________________________',
        weight: 1,
        align: LineText.ALIGN_LEFT,
        x: 0,
        linefeed: 1));

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Items :  $selectedProductCount',
      weight: 1,
      align: LineText.ALIGN_LEFT,
      relativeX: 0,
      linefeed: 1, // Move to the next line after printing amount
    ));

    final labelsAndValues = [
      {
        'label': 'Total Bill:',
        'value': widget.invoiceLogic.getTotalBillAmount().toStringAsFixed(2)
      },
      {
        'label': 'Outstanding Balance:',
        'value': widget.invoiceLogic.outstandingBalance.toStringAsFixed(2)
      },
      {
        'label': 'Discount:',
        'value': widget.invoiceLogic.getDiscountAmount().toStringAsFixed(2)
      },
      {
        'label': 'Payable Total:',
        'value': widget.invoiceLogic.paidAmount.toStringAsFixed(2)
      },
    ];

    // Add LineText elements
    for (final item in labelsAndValues) {
      final label = item['label'];
      final value = item['value'];

      // Calculate the spaces needed for alignment
      final spacesNeeded = maxWidth - label!.length - value!.length;

      // Create the line with proper alignment
      final line = '$label${' ' * spacesNeeded}$value';

      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: line,
        weight: 1,
        align: LineText.ALIGN_LEFT,
        linefeed: 1,
      ));
    }

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: '_______________________________',
        weight: 1,
        align: LineText.ALIGN_LEFT,
        x: 0,
        linefeed: 1));
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: settings.softwareCompany,
      weight: 1,
      align: LineText.ALIGN_CENTER,
      //x: 0,
      relativeX: 0,
      linefeed: 1, // Move to the next line after printing amount
    ));
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: settings.companyPhoneNumber,
      weight: 1,
      align: LineText.ALIGN_CENTER,
      //x: 0,
      relativeX: 0,
      linefeed: 1, // Move to the next line after printing amount
    ));
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: ' ',
      weight: 1,
      align: LineText.ALIGN_CENTER,
      //x: 0,
      relativeX: 0,
      linefeed: 1, // Move to the next line after printing amount
    ));
    await bluetoothPrint.printReceipt(config, list);
  }
}
