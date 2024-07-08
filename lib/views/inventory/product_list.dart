import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import '../../components/custom_button.dart';
import '../../models/product_modle.dart';
import '../../models/product_response.dart';
import '../../services/product_api_service.dart';
import '../../services/vehicle_inventory_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/util_functions.dart';
import 'product_card.dart';

class ProductList extends StatefulWidget {
  const ProductList({Key? key}) : super(key: key);

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  late Future<ProductResponse> futureProducts;
  bool _isAscending = true;
  bool isLoading = false;
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  late VehicleInventoryService vehicleInventoryService;

  @override
  void initState() {
    super.initState();
    int empId = 1; // This could be dynamically assigned as needed
    String currentDate = UtilFunctions.getCurrentDateTime();
    futureProducts = ProductService.fetchProducts(empId, currentDate);
    vehicleInventoryService = VehicleInventoryService();
  }

  void _onSortOrderChanged() {
    setState(() {
      _isAscending = !_isAscending;
      _filteredProducts.sort((a, b) {
        return _isAscending
            ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
            : b.name.toLowerCase().compareTo(a.name.toLowerCase());
      });
    });
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _filterProducts('');
    });
  }

  void _updateSearch(String value) {
    setState(() {
      _filterProducts(value);
    });
  }

  void _filterProducts(String value) {
    _filteredProducts = _products.where((product) {
      return product.name.toLowerCase().contains(value.toLowerCase()) ||
          product.productCode.toLowerCase().contains(value.toLowerCase());
    }).toList();
    if (!_isAscending) {
      _filteredProducts = _filteredProducts.reversed.toList();
    }
  }

  Future<void> deleteAllVehicleInventories() async {
    var response = await futureProducts; // Ensure future completes
    List<Product> products = response.products;
    bool allDeleted = true;

    for (var product in products) {
      var result = await vehicleInventoryService
          .deleteVehicleInventory(product.vehicleInventoryId);
      if (!result['success']) {
        allDeleted = false;
        break; // Stop further deletion if one fails
      }
    }

    if (allDeleted) {
      setState(() {
        _products.clear(); // Assuming you want to clear the list after deletion
        isLoading = false;
      });
      showSuccessMessage();
    } else {
      setState(() {
        isLoading = false;
      });
      showErrorSnackbar();
    }
  }

  void showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("All vehicle inventories successfully returned."),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to return some vehicle inventories."),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColor.primaryTextColor,
            size: 15,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search products...',
                  border: InputBorder.none,
                ),
                onChanged: _updateSearch,
              )
            : const Text(
                'Inventory List',
                style: TextStyle(
                  color: Color(0xFF464949),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontFamily: 'SF Pro Text',
                ),
              ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: Icon(
                _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                color: AppColor.primaryTextColor,
              ),
              onPressed: _onSortOrderChanged,
            ),
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: AppColor.primaryTextColor,
            ),
            onPressed: () {
              if (_isSearching) {
                _stopSearch();
              } else {
                _startSearch();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                bottom: 80), // Add padding to avoid the button overlap
            child: FutureBuilder<ProductResponse>(
              future: futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColor.accentColor),
                  ));
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load products'));
                }
                if (!snapshot.hasData || snapshot.data!.products.isEmpty) {
                  return const Center(child: Text('No products available'));
                }

                _products = snapshot.data!.products;
                _filterProducts(_searchController.text);

                return Container(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  margin: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.primaryTextColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: ProductCard(
                          product: product,
                          onPressed: () {
                            // Handle the card press action
                            print('Product pressed: ${product.name}');
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: CustomButton(
              buttonText: 'Return Stock',
              onTap: () {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.warning,
                  animType: AnimType.bottomSlide,
                  title: 'Return Stock',
                  desc: 'Are you sure you want to return all stock?',
                  btnCancelOnPress: () {},
                  btnOkOnPress: () {
                    setState(() {
                      isLoading = true;
                    });

                    deleteAllVehicleInventories();
                  },
                )..show();
              },
              buttonColor: AppColor.accentColor,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
