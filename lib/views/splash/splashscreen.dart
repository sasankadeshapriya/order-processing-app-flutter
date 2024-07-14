import 'package:flutter/material.dart';
import 'package:jumping_dot/jumping_dot.dart';
import 'package:order_processing_app/services/token_manager.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/utils/util_functions.dart';
import 'package:order_processing_app/views/auth/login.dart';
import 'package:order_processing_app/views/main/dashboard.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final String? token = await TokenManager.getToken();
    if (token != null) {
      await TokenManager
          .retrieveEmpId(); // Retrieve empId from shared preferences
      print(
          'Employee ID vvvvvvvvvvvvv: ${TokenManager.empId}'); // Now it prints after retrieval
      _navigateToDashbord();
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToDashbord() {
    UtilFunctions.navigateTo(context, const UserDashboard());
  }

  void _navigateToLogin() {
    UtilFunctions.navigateTo(context, const Login());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            JumpingDots(
              color: AppColor.secondaryTextColorLight,
              radius: 8,
              numberOfDots: 4,
            ),
          ],
        ),
      ),
    );
  }
}
