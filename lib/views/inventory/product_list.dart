import 'package:flutter/material.dart';

import '../../components/custom_button.dart';
import '../../models/product_modle.dart';
import '../../models/product_response.dart';
import '../../services/product_api_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/util_functions.dart';
import 'product_card.dart'; // Make sure the path is correct for ProductCard

class ProductList extends StatefulWidget {
  const ProductList({Key? key}) : super(key: key);

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  late Future<ProductResponse> futureProducts;
  bool _isAscending = true;
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<Product> _searchSuggestions = [];
  late int empId = 1;
  String currentDate = UtilFunctions.getCurrentDateTime();

  @override
  void initState() {
    super.initState();
    futureProducts = ProductService.fetchProducts(empId, currentDate);
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
      _searchSuggestions.clear();
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
    _filteredProducts.sort((a, b) {
      return _isAscending
          ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
          : b.name.toLowerCase().compareTo(a.name.toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
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
                size: 24,
                color: AppColor.primaryTextColor,
              ),
              onPressed: _onSortOrderChanged,
            ),
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              size: 24,
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
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load products'));
                } else if (!snapshot.hasData ||
                    snapshot.data!.products.isEmpty) {
                  return const Center(child: Text('No products available'));
                }

                _products = snapshot.data!.products;
                _filterProducts(_searchController.text);

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColor
                          .primaryTextColor, // Adjust the color as needed
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListView.builder(
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return FutureBuilder<double>(
                          future: ProductService.getOpeningStock(
                              product.id, currentDate),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return const Center(
                                  child: Text('Failed to load opening stock'));
                            } else {
                              final openingStock = snapshot.data ?? 0.0;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: ProductCard(
                                  product: product,
                                  openingStock: openingStock,
                                  onPressed: () {
                                    // Handle the card press action
                                  },
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
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
                // Implement your logic here
                print('Return Stock button pressed');
              },
              buttonColor: AppColor.accentColor,
              isLoading: false,
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
