import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:order_processing_app/services/assignment_api_service.dart';
import 'package:order_processing_app/utils/logger.dart';

class LocationService {
  late final Location _locationController;
  late StreamSubscription<LocationData> _locationSubscription;
  late Function(LatLng) _onLocationUpdate;
  late Timer _locationTimeoutTimer;
  late Timer _locationUpdateTimer;
  late BuildContext _context; // Store the BuildContext for sending alerts
  bool _isGpsSignalLost = false; // Flag to track GPS signal status

  LocationService() : _locationController = Location();

  Future<void> startLocationService(
      Function(LatLng) onLocationUpdate, BuildContext context) async {
    _onLocationUpdate = onLocationUpdate;
    _context = context; // Store the BuildContext
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if the location service is enabled and prompt the user to enable it if not
    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) {
        AppLogger.logError("Location service is disabled.");
        _sendAlert(
            "Location service is disabled. Please enable it in settings.");
        return;
      }
    }

    // Check for location permissions
    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        AppLogger.logError("Location permissions are denied.");
        _sendAlert(
            "Location access is denied. Please allow access in settings.");
        return;
      }
    }

    // Start listening for location updates
    _locationSubscription =
        _locationController.onLocationChanged.listen((LocationData location) {
      _onLocationUpdate(LatLng(location.latitude!, location.longitude!));
    });

    // Start the location update timer
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _locationController.getLocation().then((location) {
        _onLocationUpdate(LatLng(location.latitude!, location.longitude!));
        _updateLocationInDatabase(location);
      });
    });

    // Start the location timeout timer
    _startLocationTimeoutTimer();
  }

  void stopLocationService() {
    _locationSubscription.cancel();
    _locationUpdateTimer.cancel();
    _locationTimeoutTimer.cancel();
  }

  void _startLocationTimeoutTimer() {
    _locationTimeoutTimer = Timer(const Duration(seconds: 20), () {
      AppLogger.logWarning("GPS connection lost. Sending alert.");
      _sendAlert("GPS signal lost. Please check your GPS connection.");
      _isGpsSignalLost = true;
    });
  }

  void _resetLocationTimeoutTimer() {
    if (_isGpsSignalLost) {
      _sendAlert("GPS signal restored.");
      _isGpsSignalLost = false;
    }
    _locationTimeoutTimer.cancel();
    _startLocationTimeoutTimer();
  }

  void _sendAlert(String message) {
    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _updateLocationInDatabase(LocationData location) {
    String employeeId = '1';
    Map<String, dynamic> locationData = {
      'latitude': location.latitude,
      'longitude': location.longitude,
    };

    AssignmentApiService.updateEmployeeLocation(employeeId, locationData)
        .then((_) {
      AppLogger.logInfo('Location updated in the database successfully');
    }).catchError((error) {
      AppLogger.logError('Failed to update location in the database: $error');
    });
  }
}
