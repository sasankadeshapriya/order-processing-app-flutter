import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:order_processing_app/main.dart'; // Assuming this contains the globalScaffoldKey declaration

class ConnectivityChecker {
  static final ConnectivityChecker _instance = ConnectivityChecker._internal();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  // Public setter for connectivity changes
  void Function(bool isConnected)? onConnectivityChanged;

  static ConnectivityChecker get instance => _instance;

  ConnectivityChecker._internal() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_handleConnectivityChange);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    bool isConnected = !results.contains(ConnectivityResult.none);
    if (!isConnected) {
      _showSnackbar("No Internet connection. Internet connection is required!");
    }
    // Notify any listeners about the change
    onConnectivityChanged?.call(isConnected);
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 5),
    );
    // Use ScaffoldMessenger to show the snackbar
    ScaffoldMessenger.of(globalScaffoldKey.currentContext!)
        .showSnackBar(snackBar);
  }

  void dispose() {
    _connectivitySubscription.cancel();
  }
}
