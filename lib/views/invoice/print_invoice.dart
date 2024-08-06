import 'dart:async';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:logger/logger.dart';

import '../../models/print_setting_modle.dart';
import '../../services/invoice_api_service.dart';
import '../../services/vehicle_inventory_service.dart';
import '../../utils/invoice_logic.dart';

class PrintInvoice {
  late InvoiceLogic invoiceLogic = InvoiceLogic();
  final InvoiceService invoiceService = InvoiceService();
  final VehicleInventoryService vehicleInventoryService =
      VehicleInventoryService();
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  bool _connected = false;
  BluetoothDevice? _device;
  String tips = 'No device connected';
  String formattedDateTime = '';
  late PrintSettings settings;

  bool get connected => _connected;
  BluetoothDevice? get device => _device;
  set device(BluetoothDevice? newDevice) {
    _device = newDevice;
  }

  void setInvoiceLogic(InvoiceLogic logic) {
    invoiceLogic = logic;
  }

  Future<void> initBluetooth(Function(String) updateTips) async {
    Logger().w('Initializing Bluetooth.');
    bool isEnabled = await bluetoothPrint.isOn;
    if (!isEnabled) {
      tips = 'Please turn on Bluetooth and try again.';
      Logger().w(tips);
      updateTips(tips);
      return;
    }

    bluetoothPrint.startScan(timeout: const Duration(seconds: 4));
    bool isConnected = await bluetoothPrint.isConnected ?? false;

    bluetoothPrint.state.listen((state) {
      switch (state) {
        case BluetoothPrint.CONNECTED:
          _connected = true;
          tips = 'Connect success';
          break;
        case BluetoothPrint.DISCONNECTED:
          _connected = false;
          tips = 'Disconnect success';
          break;
        default:
          break;
      }
      updateTips(tips);
    });

    if (isConnected) {
      _connected = true;
      updateTips('Already connected');
    }
  }

  Future<void> startBluetoothScan(Function(String) updateTips) async {
    bool isEnabled = await bluetoothPrint.isOn;
    if (!isEnabled) {
      tips = 'Please turn on Bluetooth and try again.';
      Logger().w(tips);
      updateTips(tips);
      return;
    }

    bluetoothPrint.startScan(timeout: const Duration(seconds: 4));
    bool isConnected = await bluetoothPrint.isConnected ?? false;

    bluetoothPrint.state.listen((state) {
      switch (state) {
        case BluetoothPrint.CONNECTED:
          _connected = true;
          tips = 'Connect success';
          break;
        case BluetoothPrint.DISCONNECTED:
          _connected = false;
          tips = 'Disconnect success';
          break;
        default:
          break;
      }
      updateTips(tips);
    });

    if (isConnected) {
      _connected = true;
      updateTips('Already connected');
    }
  }

  Future<void> connectDevice(
      BluetoothDevice device, Function(String) updateTips) async {
    if (device.address != null) {
      tips = 'Connecting...';
      updateTips(tips);
      await bluetoothPrint.connect(device);
    } else {
      tips = 'Please select device';
      updateTips(tips);
    }
  }

  Future<void> disconnectDevice(Function(String) updateTips) async {
    tips = 'Disconnecting...';
    updateTips(tips);
    await bluetoothPrint.disconnect();
  }

  Future<void> printReceipt(Function(bool) setLoading) async {
    Logger().w('Executing print receipt logic.');
    setLoading(true);

    try {
      var selectedClient = invoiceLogic.selectedClient;
      var selectedProduct = invoiceLogic.selectedProduct;
      var quantity = invoiceLogic.productQuantities[selectedProduct];
      var clientName = selectedClient != null ? selectedClient.name : '';
      var employeeName = selectedProduct != null
          ? selectedProduct.employeeName
          : ''; // Assuming such a field exists
      var paymentMethod = invoiceLogic.selectedPaymentMethod?.paymentName;
      int selectedProductCount = invoiceLogic.getSelectedProductCount();
      bool isPartiallyPaid = invoiceLogic.isPartiallyPaid;
      bool isFullyPaid = invoiceLogic.isFullyPaid;

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
        content: 'Invoice No :${invoiceLogic.generateInvoiceNumber()}',
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

      invoiceLogic.productQuantities.forEach((product, quantity) {
        final String title = product.name;
        final double price =
            invoiceLogic.getPrice(product, invoiceLogic.selectedPaymentMethod!);
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
          'value': invoiceLogic.getTotalBillAmount().toStringAsFixed(2)
        },
        {
          'label': 'Outstanding Balance:',
          'value': invoiceLogic.outstandingBalance.toStringAsFixed(2)
        },
        {
          'label': 'Discount:',
          'value': invoiceLogic.getDiscountAmount().toStringAsFixed(2)
        },
        {
          'label': 'Payable Total:',
          'value': isPartiallyPaid
              ? '0.00'
              : invoiceLogic.paidAmount.toStringAsFixed(2)
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
    } catch (e) {
      Logger().e('Error printing receipt: $e');
      throw e;
    } finally {
      setLoading(false);
    }
  }
}
