import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:order_processing_app/common/location_check_pop.dart';
import 'package:order_processing_app/common/location_service.dart';
import 'package:order_processing_app/common/map_builder.dart';
import 'package:order_processing_app/constants/consts.dart';
import 'package:order_processing_app/services/assignment_api_service.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/utils/app_components.dart';
import 'package:order_processing_app/utils/logger.dart';
import 'package:order_processing_app/views/map/loading.dart';
import 'package:order_processing_app/widgets/assignment_container_widget.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapBuilder _mapBuilder;
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  LatLng? _currentP;

  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? currentLocationIcon;

  Map<PolylineId, Polyline> polylines = {};
  Set<Marker> markers = {};

  bool _isLoading = true;
  String _vehicleNumber = 'N/A';
  String _routeName = 'No Route Assigned';
  int _clientCount = 0;

  @override
  void initState() {
    super.initState();
    _mapBuilder = MapBuilder();
    _setCustomMarkerIcon();
    _fetchAssignmentAndClients();

    // Listen for location updates from the GlobalLocationService
    GlobalLocationService().startLocationService(_updateCurrentLocation);
  }

  void _updateCurrentLocation(LatLng location) {
    setState(() {
      _currentP = location;
      _updateCurrentLocationMarker(location);
    });
    _cameraToPosition(location);
    if (_currentP == null) {
      showLocationServiceDialog(context, false);
    }
  }

  void _updateCurrentLocationMarker(LatLng location) {
    Marker currentLocationMarker = Marker(
      markerId: const MarkerId("currentLocation"),
      position: location,
      icon: currentLocationIcon ?? BitmapDescriptor.defaultMarker,
      infoWindow: const InfoWindow(title: "Current Location"),
    );

    setState(() {
      markers
          .removeWhere((m) => m.markerId == const MarkerId("currentLocation"));
      markers.add(currentLocationMarker);
    });
  }

  AppBar _buildAppBar() {
    return AppBar(
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
      title: const Text(
        "Map",
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
        FloatingContainer(
          vehicleNumber: _vehicleNumber,
          routeName: _routeName,
          clientCount: _clientCount,
          date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        ),
      ],
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition:
          CameraPosition(target: _currentP ?? const LatLng(0, 0), zoom: 14.0),
      polylines: Set<Polyline>.from(polylines.values),
      markers: markers,
      onMapCreated: _onMapCreated,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
  }

  Future<BitmapDescriptor> _loadBitmapDescriptor(String assetName) async {
    return BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, assetName);
  }

  void _setCustomMarkerIcon() async {
    sourceIcon = await _loadBitmapDescriptor(AppComponents.sourceLocation);
    destinationIcon =
        await _loadBitmapDescriptor(AppComponents.destinationLocation);
    currentLocationIcon =
        await _loadBitmapDescriptor(AppComponents.currentLocation);
    setState(() {});
  }

  void _fetchAssignmentAndClients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      int employeeId = 1; // Assuming you have the employeeId beforehand
      List<Map<String, dynamic>> assignments =
          await AssignmentApiService.getAssignmentsWithDetails(employeeId);
      DateTime today = DateTime.now();
      bool foundAssignmentsForToday = false;

      for (var assignment in assignments) {
        DateTime assignDate = DateTime.parse(assignment['assignment_date']);
        if (assignDate.year == today.year &&
            assignDate.month == today.month &&
            assignDate.day == today.day) {
          foundAssignmentsForToday = true;

          List<LatLng> waypoints = (assignment['waypoints'] as List)
              .map((wp) => LatLng(wp.latitude, wp.longitude))
              .toList();
          LatLng start = waypoints.first;
          LatLng destination = waypoints.last;

          List<LatLng> routeCoordinates = await getRouteCoordinates(
              start,
              destination,
              waypoints.skip(1).take(waypoints.length - 2).toList());

          polylines[PolylineId('route_${assignment['route_name']}')] = Polyline(
            polylineId: PolylineId('route_${assignment['route_name']}'),
            color: Colors.redAccent,
            points: routeCoordinates,
            width: 8,
          );

          _vehicleNumber = assignment['vehicle_number'];
          _routeName = assignment['route_name'];

          markers.clear();
          setMarkers(start, destination, _routeName);

          int routeId = assignment['route_id'];
          print("Route ID: $routeId");

          fetchClientLocations(routeId);

          break;
        }
      }

      if (!foundAssignmentsForToday) {
        _showNoAssignmentsAlert();
      }
    } catch (e) {
      print('Error fetching assignments: $e');
      AppLogger.logError('Failed to fetch assignment data: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showNoAssignmentsAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("No Assignments"),
          content: const Text("There are no assignments scheduled for today."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void setMarkers(LatLng start, LatLng destination, String routeName) {
    markers.add(Marker(
      markerId: MarkerId('source_$routeName'),
      position: start,
      icon: sourceIcon ?? BitmapDescriptor.defaultMarker,
      infoWindow:
          InfoWindow(title: 'Start of $routeName', snippet: 'Start Point'),
    ));

    markers.add(Marker(
      markerId: MarkerId('destination_$routeName'),
      position: destination,
      icon: destinationIcon ?? BitmapDescriptor.defaultMarker,
      infoWindow:
          InfoWindow(title: 'End of $routeName', snippet: 'Destination'),
    ));
  }

  Future<List<LatLng>> getRouteCoordinates(
      LatLng start, LatLng destination, List<LatLng> waypoints) async {
    String waypointsStr = waypoints
        .map((point) => "${point.latitude},${point.longitude}")
        .join('|');
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${destination.latitude},${destination.longitude}&waypoints=optimize:true|$waypointsStr&key=$GOOGLE_MAPS_API_KEY';
    http.Response response = await http.get(Uri.parse(url));
    Map values = jsonDecode(response.body);
    List<LatLng> routeCoordinates = [];

    if (values['routes'].isNotEmpty) {
      String polyline = values['routes'][0]['overview_polyline']['points'];
      routeCoordinates = decodePolyline(polyline);
    }
    return routeCoordinates;
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      points.add(p);
    }
    return points;
  }

  void fetchClientLocations(int routeId) async {
    try {
      List<dynamic> clientLocations =
          await AssignmentApiService.getClientLocationsByRouteId(routeId);
      AppLogger.logInfo(
          "Client Locations for Route ID $routeId: ${clientLocations.length} found.");

      setState(() {
        _clientCount = clientLocations.length;

        for (var location in clientLocations) {
          double? lat = double.tryParse(location['latitude']?.toString() ?? '');
          double? lng =
              double.tryParse(location['longitude']?.toString() ?? '');
          String organization =
              location['organization_name'] ?? 'Unknown Organization';

          if (lat != null && lng != null) {
            LatLng position = LatLng(lat, lng);
            markers.add(Marker(
              markerId: MarkerId('client_${lat}_$lng'),
              position: position,
              icon: BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(
                title: organization,
                snippet: 'Client at Route $routeId',
              ),
            ));
          } else {
            AppLogger.logError('Invalid client location data: $location');
          }
        }
      });
    } catch (e) {
      print('Failed to fetch client locations: $e');
      AppLogger.logError('Error fetching client locations: $e');
      throw Exception('Error fetching client locations: $e');
    }
  }

  void _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(pos, 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isLoading ? null : _buildAppBar(),
      body: _isLoading ? const Loading() : _buildBody(),
    );
  }
}
