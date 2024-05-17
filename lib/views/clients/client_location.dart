import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:logger/logger.dart';
import '../../components/alert_dialog.dart';
import '../../components/custom_button.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  late Location _location;
  LatLng? _currentPosition;
  bool _isLoadingLocation = true;

  Set<Marker> _markers = {};

  bool _isTapped = false;
  late StreamSubscription<LocationData> _locationSubscription;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _location = Location();
    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      final location = LatLng(locationData.latitude!, locationData.longitude!);
      _updateCurrentLocation(location);
    });
  }

  @override
  void dispose() {
    _locationSubscription.cancel(); // Cancel the location stream subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTapDown: (_) {
                setState(() {
                  _isTapped = true;
                });
                _getCurrentLocation();
              },
              onTapUp: (_) {
                setState(() {
                  _isTapped = false;
                });
              },
              onTapCancel: () {
                setState(() {
                  _isTapped = false;
                });
              },
              onTap: () {
                _getCurrentLocationAndNavigateBack();
              },
              child: Container(
                color: Colors.white,
                height: 95,
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 15.0, left: 5.0, right: 5.0, top: 10.0),
                  child: CustomButton(
                    buttonText: 'Select Client  Location',
                    isLoading: _isTapped,
                    onTap: _getCurrentLocation,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(pos, 14),
    );
  }

  void _updateCurrentLocation(LatLng location) {
    Logger().w('inside updateCurrentLocation');
    setState(() {
      _currentPosition = location;
    });
    _cameraToPosition(location); // Update camera position when location changes

    // Update markers
    _updateMarkers();

    // Print the saved location
    print('Saved location: $_currentPosition');
  }

  void _updateMarkers() {
    Logger().w('inside updateMarkers');
    if (_currentPosition != null) {
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('user_location'),
            position: _currentPosition!,
            infoWindow: const InfoWindow(title: 'Client Location'),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        };
      });
    }
  }

  void _getCurrentLocation() async {
    Logger().w('inside getCurrentLocation');
    try {
      LocationData locationData = await _location.getLocation();
      LatLng location = LatLng(locationData.latitude!, locationData.longitude!);
      _updateCurrentLocation(location);
    } catch (e) {
      print('Error getting current location: $e');
      setState(() {
        _isLoadingLocation = false; // Stop loading on error
      });
    }
  }

  void _getCurrentLocationAndNavigateBack() async {
    Logger().w('inside getCurrentLocationAndNavigateBack');
    try {
      if (_currentPosition == null) {
        LocationData locationData = await _location.getLocation();
        _currentPosition =
            LatLng(locationData.latitude!, locationData.longitude!);
        _isLoadingLocation = false;
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Location added successfully.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.pop(context, {
                      'latitude': _currentPosition!.latitude,
                      'longitude': _currentPosition!.longitude
                    });
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error getting current location: $e');
      setState(() {
        _isLoadingLocation = false; // Stop loading on error
      });
    }
  }
}
