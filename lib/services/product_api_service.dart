import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

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
                    double.tryParse(firstBatch['check_price'].toString()) ??
                        0.0,
                creditPrice:
                    double.tryParse(firstBatch['credit_price'].toString()) ??
                        0.0,
                assignmentId: vehicle['assignment_id'],
                quantity:
                    double.tryParse(vehicle['quantity'].toString()) ?? 0.0,
                vehicleInventoryId: vehicle['id'],
                intialqty: double.tryParse(vehicle['intialqty'].toString()) ??
                    0.0 // New column added here
                );
          }).toList();

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
}
