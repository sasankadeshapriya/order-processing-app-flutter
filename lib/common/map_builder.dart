import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapBuilder {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);

  GoogleMap buildMap({
    LatLng? initialPosition,
    Set<Marker> markers = const {},
    required void Function(GoogleMapController) onMapCreated,
  }) {
    return GoogleMap(
      onMapCreated: (controller) {
        _onMapCreated(controller);
        onMapCreated(controller);
      },
      initialCameraPosition: initialPosition != null
          ? CameraPosition(
              target: initialPosition,
              zoom: 13,
            )
          : const CameraPosition(
              target: _pGooglePlex,
              zoom: 13,
            ),
      mapType: MapType.normal,
      trafficEnabled: true,
      markers: markers,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
  }
}
