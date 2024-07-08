import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../components/custom_button.dart';
import '../../models/print_setting_modle.dart';
import '../../services/invoice_api_service.dart';
import '../../services/vehicle_inventory_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/invoice_logic.dart';
import '../../utils/util_functions.dart';

class PrintInvoice extends StatefulWidget {
  final InvoiceLogic invoiceLogic;

  const PrintInvoice({super.key, required this.invoiceLogic});

  @override
  _PrintInvoiceState createState() => _PrintInvoiceState();
}

class _PrintInvoiceState extends State<PrintInvoice> {
  final InvoiceLogic invoiceLogic = InvoiceLogic();
  final InvoiceService invoiceService = InvoiceService();
  final VehicleInventoryService vehicleInventoryService =
      VehicleInventoryService();
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  bool _connected = false;
  BluetoothDevice? _device;
  String tips = 'No device connected';
  String formattedDateTime = '';
  late PrintSettings settings; // Ensure settings class name matches your model
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Logger().w('Initializing state.');
    formattedDateTime = UtilFunctions.getCurrentDateTime();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Logger().w('Post frame callback triggered.');
      initBluetooth();
    });
  }

  Future<void> initBluetooth() async {
    Logger().w('Fetching settings.');
    settings = await PrintSettings.fetchSettings();
    widget.invoiceLogic
        .generateInvoiceNumber(); // Generate invoice number inside InvoiceLogic
    Logger().w(
        'Generated invoice number: ${widget.invoiceLogic.generateInvoiceNumber()}');

    bool isEnabled = await bluetoothPrint.isOn;
    if (!isEnabled) {
      tips = 'Please turn on Bluetooth and try again.';
      Logger().w(tips);
      setState(() {});
      return;
    }

    bluetoothPrint.startScan(timeout: const Duration(seconds: 4));
    bool isConnected = await bluetoothPrint.isConnected ?? false;

    bluetoothPrint.state.listen((state) {
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
    final deviceWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.backgroundColor,
          title: const Text(
            'Print Receipt',
            style: TextStyle(
              color: Color(0xFF464949),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontFamily: 'SF Pro Text',
            ),
          ),
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
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: [
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
                                if (snapshot.connectionState ==
                                    ConnectionState.active) {
                                  // Logger().w('Received Bluetooth scan results.');
                                }
                                return Column(
                                  children: snapshot.data!
                                      .map((d) => ListTile(
                                            title: Text(
                                                d.name ?? 'Unknown device'),
                                            subtitle: Text(
                                                d.address ?? 'Unknown address'),
                                            onTap: () {
                                              setState(() {
                                                _device = d;
                                                Logger().w(
                                                    'Device selected: ${d.name}');
                                              });
                                            },
                                            trailing: _device != null &&
                                                    _device!.address ==
                                                        d.address
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
                              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Spacer(),
                                      OutlinedButton(
                                        onPressed: _connected
                                            ? null
                                            : () async {
                                                if (_device != null &&
                                                    _device!.address != null) {
                                                  Logger().w(
                                                      'Attempting to connect.');
                                                  setState(() {
                                                    tips = 'Connecting...';
                                                  });
                                                  await bluetoothPrint
                                                      .connect(_device!);
                                                } else {
                                                  setState(() {
                                                    tips =
                                                        'Please select device';
                                                    Logger().w(tips);
                                                  });
                                                }
                                              },
                                        child: const Text('Connect'),
                                      ),
                                      const SizedBox(width: 10.0),
                                      OutlinedButton(
                                        onPressed: _connected
                                            ? () async {
                                                Logger().w('Disconnecting.');
                                                setState(() {
                                                  tips = 'Disconnecting...';
                                                });
                                                await bluetoothPrint
                                                    .disconnect();
                                              }
                                            : null,
                                        child: const Text('Disconnect'),
                                      ),
                                      const SizedBox(width: 10.0),
                                      const Spacer(),
                                      StreamBuilder<bool>(
                                        stream: bluetoothPrint.isScanning,
                                        initialData: false,
                                        builder: (context, snapshot) {
                                          // Logger().w('Scanning status: ${snapshot.data}');
                                          if (snapshot.data!) {
                                            return FloatingActionButton(
                                              onPressed: () {
                                                // Logger().w('Stopping scan.');
                                                bluetoothPrint.stopScan();
                                              },
                                              backgroundColor: Colors.red,
                                              child: const Icon(Icons.stop),
                                            );
                                          } else {
                                            return FloatingActionButton(
                                              backgroundColor:
                                                  AppColor.primaryColorLighter,
                                              onPressed: () {
                                                Logger().w('Starting scan.');
                                                bluetoothPrint.startScan(
                                                    timeout: const Duration(
                                                        seconds: 4));
                                              },
                                              child: const Icon(Icons.search),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: deviceWidth,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columnSpacing:
                                            28, // Adjust column spacing
                                        dataRowHeight:
                                            40, // Adjust row height if needed
                                        columns: const [
                                          DataColumn(
                                              label: Text('Product Name')),
                                          DataColumn(label: Text('Item Price')),
                                          DataColumn(label: Text('Qty')),
                                          DataColumn(label: Text('Total')),
                                        ],
                                        rows: widget.invoiceLogic
                                            .productQuantities.entries
                                            .map((entry) {
                                          final product = entry.key;
                                          final quantity = entry.value;
                                          final price = widget.invoiceLogic
                                              .getPrice(
                                                  product,
                                                  widget.invoiceLogic
                                                      .selectedPaymentMethod!);
                                          final total = price * quantity;
                                          return DataRow(cells: [
                                            DataCell(
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                    1.0), // Adjust cell padding
                                                child: Text(product.name),
                                              ),
                                            ),
                                            DataCell(
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                    2.0), // Adjust cell padding
                                                child: Text(
                                                    price.toStringAsFixed(2)),
                                              ),
                                            ),
                                            DataCell(
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                    2.0), // Adjust cell padding
                                                child:
                                                    Text(quantity.toString()),
                                              ),
                                            ),
                                            DataCell(
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                    2.0), // Adjust cell padding
                                                child: Text(
                                                    total.toStringAsFixed(2)),
                                              ),
                                            ),
                                          ]);
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: CustomButton(
                          buttonText: 'Print Receipt',
                          onTap: () async {
                            setState(() {
                              // Set isLoading to true when the button is tapped
                              isLoading = true;
                            });
                            if (_connected) {
                              try {
                                _printReceipt();
                                invoiceLogic.AddCommission();
                                await widget.invoiceLogic.processInvoiceData(
                                  vehicleInventoryService,
                                  invoiceService,
                                  context,
                                );

                                setState(() {
                                  isLoading = false;
                                });
                              } catch (e) {
                                Logger().e('Error printing receipt: $e');
                                setState(() {
                                  isLoading = false;
                                });
                                if (mounted) {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.error,
                                    headerAnimationLoop: false,
                                    animType: AnimType.bottomSlide,
                                    title: 'Print Error',
                                    desc:
                                        'An error occurred while printing the receipt. Please try again.',
                                    buttonsTextStyle:
                                        const TextStyle(color: Colors.black),
                                    btnOkOnPress: () {},
                                  ).show();
                                }
                              }
                            } else {
                              if (mounted) {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.error,
                                  headerAnimationLoop: false,
                                  animType: AnimType.bottomSlide,
                                  title: 'Connection Error',
                                  desc:
                                      'No device connected. Please connect a device and try again.',
                                  buttonsTextStyle:
                                      const TextStyle(color: Colors.black),
                                  btnOkOnPress: () {},
                                ).show();
                              }
                            }
                          },
                          buttonColor: AppColor
                              .accentColor, // Use your accent color here
                          isLoading: isLoading,
                        ),
                      )

                      //const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _printReceipt() async {
    Logger().w('Executing print receipt logic.');
    var selectedClient = widget.invoiceLogic.selectedClient;
    var selectedProduct = widget.invoiceLogic.selectedProduct;
    var quantity = widget.invoiceLogic.productQuantities[selectedProduct];
    var clientName = selectedClient != null ? selectedClient.name : '';
    var employeeName = selectedProduct != null
        ? selectedProduct.employeeName
        : ''; // Assuming such a field exists
    var paymentMethod = widget.invoiceLogic.selectedPaymentMethod?.paymentName;
    int selectedProductCount = widget.invoiceLogic.getSelectedProductCount();
    bool isPartiallyPaid = widget.invoiceLogic.isPartiallyPaid;
    bool isFullyPaid = widget.invoiceLogic.isFullyPaid;

    Logger().f(clientName);
    Logger().f('$selectedProduct');
    Logger().f('$quantity');
    Logger().f(employeeName);
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
      linefeed: 1,
    ));
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: settings.addressLine02,
      weight: 1,
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Invoice No :${widget.invoiceLogic.generateInvoiceNumber()}',
      weight: 1,
      align: LineText.ALIGN_LEFT,
      x: 0,
      linefeed: 1,
    ));
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Client Name: $clientName',
      weight: 1,
      align: LineText.ALIGN_LEFT,
      x: 0,
      linefeed: 1,
    ));
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Ref Name   : $employeeName',
      weight: 1,
      align: LineText.ALIGN_LEFT,
      x: 0,
      linefeed: 1,
    ));
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Payment    : $paymentMethod',
      weight: 1,
      align: LineText.ALIGN_LEFT,
      x: 0,
      linefeed: 1,
    ));
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Date/Time  : $formattedDateTime',
      weight: 1,
      align: LineText.ALIGN_LEFT,
      x: 0,
      relativeX: 0,
      linefeed: 1,
    ));
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '_______________________________',
      weight: 1,
      align: LineText.ALIGN_LEFT,
      x: 0,
      linefeed: 1,
    ));

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Item',
      weight: 1,
      align: LineText.ALIGN_LEFT,
      x: 0,
      relativeX: 0,
      linefeed: 0,
    ));

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Price',
      weight: 1,
      align: LineText.ALIGN_LEFT,
      x: 80,
      relativeX: 0,
      linefeed: 0,
    ));

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Qty',
      weight: 1,
      align: LineText.ALIGN_LEFT,
      x: 190,
      relativeX: 0,
      linefeed: 0,
    ));

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Amount',
      weight: 1,
      align: LineText.ALIGN_LEFT,
      x: 310,
      relativeX: 0,
      linefeed: 0,
    ));

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '-------------------------------',
      weight: 1,
      align: LineText.ALIGN_LEFT,
      relativeX: 0,
      linefeed: 0,
    ));

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

      String adjustedTitle;
      if (title.length > maxWidth) {
        final spacesNeeded = title.length - maxWidth;
        adjustedTitle = title.substring(0, maxWidth) + ' ' * spacesNeeded;
      } else {
        adjustedTitle = title.padRight(maxWidth);
      }

      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: adjustedTitle,
        weight: 1,
        align: LineText.ALIGN_LEFT,
        x: 0,
        relativeX: 0,
        linefeed: 0,
      ));

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
      linefeed: 1,
    ));

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Items :  $selectedProductCount',
      weight: 1,
      align: LineText.ALIGN_LEFT,
      relativeX: 0,
      linefeed: 1,
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
        'value': isPartiallyPaid
            ? '0.00'
            : widget.invoiceLogic.paidAmount.toStringAsFixed(2)
      },
    ];

    for (final item in labelsAndValues) {
      final label = item['label'];
      final value = item['value'];

      final spacesNeeded = maxWidth - label!.length - value!.length;
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
      linefeed: 1,
    ));
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: settings.softwareCompany,
      weight: 1,
      align: LineText.ALIGN_CENTER,
      relativeX: 0,
      linefeed: 1,
    ));
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: settings.companyPhoneNumber,
      weight: 1,
      align: LineText.ALIGN_CENTER,
      relativeX: 0,
      linefeed: 1,
    ));
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: ' ',
      weight: 1,
      align: LineText.ALIGN_CENTER,
      relativeX: 0,
      linefeed: 1,
    ));
    await bluetoothPrint.printReceipt(config, list);
  }
}
