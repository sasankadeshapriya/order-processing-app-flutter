import 'dart:async';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:order_processing_app/common/location_check_pop.dart';
import 'package:order_processing_app/common/location_service.dart';
import 'package:order_processing_app/common/map_builder.dart';
import 'package:order_processing_app/common/polyline_creation.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/utils/app_components.dart';
import 'package:order_processing_app/views/map/loading.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapBuilder _mapBuilder;
  late LocationService _locationService;
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);
  static const LatLng _pApplePark = LatLng(37.3346, -122.0090);

  LatLng? _currentP;

  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? currentLocationIcon;

  Map<PolylineId, Polyline> polylines = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _mapBuilder = MapBuilder();
    _locationService = LocationService();
    _locationService.startLocationService(_updateCurrentLocation,
        context); // Start listening for location updates
    _setCustomMarkerIcon(); // Set custom marker icons
    _fetchPolyline(); // Fetch polyline data
  }

  @override
  void dispose() {
    _locationService
        .stopLocationService(); // Stop location updates when the widget is disposed
    super.dispose();
  }

  // Update the current location on the map
  void _updateCurrentLocation(LatLng location) {
    setState(() {
      _currentP = location;
    });
    _cameraToPosition(location); // Move camera to the updated location

    // Check if GPS signal is available
    if (_currentP == null) {
      // GPS signal is lost, show location service dialog
      showLocationServiceDialog(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isLoading ? null : _buildAppBar(),
      body: _isLoading ? const Loading() : _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF1F1F1),
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
      title: const Text(
        "Route Management",
        style: TextStyle(
          color: Color(0xFF464949),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          fontFamily: 'SF Pro Text',
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        _buildMap(),
      ],
    );
  }

  Widget _buildMap() {
    return _mapBuilder.buildMap(
      initialPosition: _currentP,
      markers: _currentP != null ? _buildMarkers() : {},
      onMapCreated: _onMapCreated,
    );
  }

  Set<Marker> _buildMarkers() {
    Set<Marker> markers = {};

    if (_currentP != null && currentLocationIcon != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("_currentLocation"),
          icon: currentLocationIcon!,
          position: _currentP!,
        ),
      );
    }

    if (sourceIcon != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("_sourceLocation"),
          icon: sourceIcon!,
          position: _pGooglePlex,
        ),
      );
    }

    if (destinationIcon != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("_destinationLocation"),
          icon: destinationIcon!,
          position: _pApplePark,
        ),
      );
    }

    return markers;
  }

  // Callback function when the map is created
  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
  }

  // Set custom marker icons
  void _setCustomMarkerIcon() {
    _loadBitmapDescriptor(AppComponents.sourceLocation).then((icon) {
      setState(() {
        sourceIcon = icon;
      });
    });

    _loadBitmapDescriptor(AppComponents.destinationLocation).then((icon) {
      setState(() {
        destinationIcon = icon;
      });
    });

    _loadBitmapDescriptor(AppComponents.currentLocation).then((icon) {
      setState(() {
        currentLocationIcon = icon;
      });
    });
  }

  // Load custom marker icons from assets
  Future<BitmapDescriptor> _loadBitmapDescriptor(String assetName) async {
    return BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      assetName,
    );
  }

  // Fetch polyline data from service
  void _fetchPolyline() async {
    // Simulate fetching polyline data
    await Future.delayed(const Duration(seconds: 2));
    List<LatLng> coordinates =
        await PolylineService.getPolyLinePoints(_pGooglePlex, _pApplePark);
    PolylineService.generatepolyLineFromPoints(coordinates, polylines);
    setState(() {
      _isLoading = false; // Set isLoading to false after fetching data
    });
  }

  // Move the camera to a specific position
  void _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(pos, 14),
    );
  }
}
