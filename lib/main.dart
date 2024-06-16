import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/views/main/dashboard.dart';
import 'common/location_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GlobalLocationService _globalLocationService;

  @override
  void initState() {
    super.initState();
    _globalLocationService = GlobalLocationService();
    _globalLocationService.startLocationService((LatLng location) {
      print('Location updated: $location');
    });
  }

  @override
  void dispose() {
    _globalLocationService.stopLocationService();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColor.backgroundColor,
      ),
      home: const UserDashboard(),
    );
  }
}
