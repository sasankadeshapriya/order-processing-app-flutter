import 'package:flutter/material.dart';
import 'package:order_processing_app/components/custom_button.dart';
import 'package:order_processing_app/services/product_api_service.dart';
import 'package:order_processing_app/services/token_manager.dart';
import 'package:order_processing_app/utils/util_functions.dart';
import 'package:order_processing_app/views/auth/login.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  isLoading: isLoading,
                  buttonText: "Logout",
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });
                    await TokenManager.clearToken();
                    _navigateToLogin();
                    setState(() {
                      isLoading = false;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    try {
                      // Call ProductService to get data
                      List<dynamic> products =
                          await ProductService.fetchProducts();
                      // Print the data to the console
                      print(products);
                    } catch (error) {
                      // Handle any errors that occur during the API call
                      print('Error fetching products: $error');
                    }
                    setState(() {
                      isLoading = false;
                    });
                  },
                  child: const Text("CLICK THIS"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToLogin() {
    UtilFunctions.navigateTo(context, const Login());
  }
}
