import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:order_processing_app/services/connection_check_service.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/views/splash/splashscreen.dart';

import 'common/location_service.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  ConnectivityChecker.instance; // Initialize the connectivity checker
  runApp(const MyApp());
}

final GlobalKey<ScaffoldState> globalScaffoldKey = GlobalKey<ScaffoldState>();

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
      home: Scaffold(
        key: globalScaffoldKey, // Use the global scaffold key here
        body: const Splashscreen(), //UserDashboard
      ),
    );
  }
}
