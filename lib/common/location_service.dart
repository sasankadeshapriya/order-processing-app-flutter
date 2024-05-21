import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:order_processing_app/services/assignment_api_service.dart';
import 'package:order_processing_app/utils/logger.dart';

class GlobalLocationService with WidgetsBindingObserver {
  late final Location _locationController;
  late StreamSubscription<LocationData> _locationSubscription;
  late Function(LatLng) _onLocationUpdate;
  bool _isServiceRunning = false;

  GlobalLocationService() : _locationController = Location() {
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> startLocationService(Function(LatLng) onLocationUpdate) async {
    _onLocationUpdate = onLocationUpdate;
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) {
        AppLogger.logError("Location service is disabled.");
        return;
      }
    }

    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        AppLogger.logError("Location permissions are denied.");
        return;
      }
    }

    _locationSubscription =
        _locationController.onLocationChanged.listen((LocationData location) {
      _onLocationUpdate(LatLng(location.latitude!, location.longitude!));
    });

    _isServiceRunning = true;
    _startLocationUpdateTimer();
  }

  void stopLocationService() {
    _locationSubscription.cancel();
    _isServiceRunning = false;
  }

  void _startLocationUpdateTimer() {
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (!_isServiceRunning) {
        timer.cancel();
        return;
      }
      final location = await _locationController.getLocation();
      _onLocationUpdate(LatLng(location.latitude!, location.longitude!));
      _updateLocationInDatabase(location);
    });
  }

  void _updateLocationInDatabase(LocationData location) {
    String employeeId = '1';
    Map<String, dynamic> locationData = {
      'latitude': location.latitude,
      'longitude': location.longitude,
    };

    AssignmentApiService.updateEmployeeLocation(employeeId, locationData)
        .then((_) {
      // AppLogger.logInfo('Location updated in the database successfully');
    }).catchError((error) {
      AppLogger.logError('Failed to update location in the database: $error');
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      stopLocationService();
    } else if (state == AppLifecycleState.resumed) {
      startLocationService(_onLocationUpdate);
    }
  }
}
