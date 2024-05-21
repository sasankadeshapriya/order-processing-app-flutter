import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product_modle.dart';
import '../models/product_response.dart'; // Ensure you have the correct import path

class ProductService {
  static const String baseUrl = 'https://api.gsutil.xyz';

  static Future<ProductResponse> fetchProducts(
      int empId, String currentDate) async {
    Logger().w('Fetching products for empId: $empId on date: $currentDate');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fetchdata/$empId/$currentDate'),
      );

      Logger().w('Received response with status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        Logger().w('Response data decoded successfully');

        final employeeName = responseData['employee_name'];
        Logger().w('Employee name: $employeeName');

        final vehicleInventory = responseData['vehicle_inventory'];
        if (vehicleInventory != null) {
          Logger().w('Vehicle inventory data found, processing products');

          List<Product> products = vehicleInventory.map<Product>((vehicle) {
            final productData = vehicle['Product'];
            final batches = productData['Batches'];
            final firstBatch = batches.isNotEmpty ? batches.first : {};

            final quantityString = vehicle['quantity'] as String? ?? '0.0';
            final quantity = double.tryParse(quantityString) ?? 0.0;

            Logger().w('Processing product: ${productData['name']}');

            return Product(
              employeeName: employeeName,
              id: productData['id'],
              name: productData['name'],
              sku: vehicle['sku'],
              productCode: productData['product_code'],
              measurementUnit: productData['measurement_unit'],
              description: productData['description'],
              productImage: productData['product_image'],
              cashPrice:
                  double.tryParse(firstBatch['cash_price'].toString()) ?? 0.0,
              checkPrice:
                  double.tryParse(firstBatch['check_price'].toString()) ?? 0.0,
              creditPrice:
                  double.tryParse(firstBatch['credit_price'].toString()) ?? 0.0,
              assignmentId: vehicle['assignment_id'],
              quantity: quantity,
              vehicleInventoryId: vehicle['id'],
            );
          }).toList();

          // Store the opening stock value for each product using shared preferences
          for (var product in products) {
            await storeOpeningStock(product, currentDate);
          }

          Logger().w('Successfully processed ${products.length} products');
          return ProductResponse(
              employeeName: employeeName, products: products);
        } else {
          Logger().w('No vehicle inventories found');
          return ProductResponse(employeeName: employeeName, products: []);
        }
      } else {
        Logger().e('Failed to fetch products: ${response.statusCode}');
        throw Exception('Failed to fetch products: ${response.statusCode}');
      }
    } catch (error) {
      Logger().e('Error fetching products: $error');
      rethrow;
    }
  }

  static Future<void> storeOpeningStock(
      Product product, String currentDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'opening_stock_${product.id}_$currentDate';

    if (!prefs.containsKey(key)) {
      await prefs.setDouble(key, product.quantity);
      Logger().w(
          'Opening stock value stored successfully for product ${product.name}');
    } else {
      Logger().w(
          'Opening stock value already exists for product ${product.name} on date $currentDate');
    }
  }

  static Future<double> getOpeningStock(
      int productId, String currentDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'opening_stock_${productId}_$currentDate';

    return prefs.getDouble(key) ?? 0.0;
  }
}
