import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:order_processing_app/models/employee_model.dart';
import 'package:order_processing_app/services/commission_api_service.dart';
import 'package:order_processing_app/services/connection_check_service.dart';
import 'package:order_processing_app/services/employee_api_service.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/utils/app_components.dart';
import 'package:order_processing_app/views/assignment/assignment_list.dart';
import 'package:order_processing_app/views/main/drawer.dart';
import 'package:order_processing_app/views/map/map_page.dart';
import 'package:order_processing_app/views/reports/report_list_page.dart';

import '../../components/alert_dialog.dart';
import '../clients/client_form.dart';
import '../inventory/product_list.dart';
import '../invoice/invoicePage.dart';
import '../invoice/invoice_list_page.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  late ScrollController controller;
  double _todaysCommission = 0;
  String _userName = "Loading...";
  String _userEmail = "";
  String _userProfilePic = "";
  Color connectionStatusColor = Colors.grey; // Default to grey

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
    _loadData();
    _fetchUserDetails();
    ConnectivityChecker.instance.onConnectivityChanged = (isConnected) {
      setState(() {
        connectionStatusColor = isConnected ? Colors.green : Colors.grey;
      });
    };
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
    ConnectivityChecker.instance.onConnectivityChanged = null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final double maxWidth = MediaQuery.of(context).size.width;
    final double maxHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      drawer: AppDrawer(
        userName: _userName,
        userEmail: _userEmail,
        userProfilePic: _userProfilePic,
        connectionStatusColor: connectionStatusColor,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadData();
          await _fetchUserDetails();
        },
        color: AppColor.accentColor,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          width: maxWidth,
          height: maxHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return _buildSmallScreenLayout(constraints.maxWidth);
              } else if (constraints.maxWidth < 1000) {
                return _buildMediumScreenLayout();
              } else {
                return _buildLargeScreenLayout();
              }
            },
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FloatingActionButton(
          elevation: 20, // Add a noticeable shadow
          shape: const CircleBorder(), // Make it round
          backgroundColor:
              AppColor.backgroundColor, // Change background color to white
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InvoicePage()),
            );
          },
          child: const Icon(Icons.receipt_long_outlined,
              color: AppColor.accentColor), // Change icon color to accent color
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      // backgroundColor: const Color(0xFFF1F1F1),
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      title: Container(
        padding: const EdgeInsets.all(8),
        child: SvgPicture.asset(
          AppComponents.appLogo,
          width: 20, // Adjust width as needed
          height: 20, // Adjust height as needed
        ),
      ),
    );
  }

  Widget _buildSmallScreenLayout(double screenWidth) {
    return Material(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildListTile(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    containerRow1(
                      image: AppComponents.dashReport,
                      image1: AppComponents.dashReportData,
                      text: "Reports",
                      text1: "",
                      text2: "",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReportList(),
                          ),
                        );
                        print("Tapped Reports");
                      },
                    ),
                    containerRow1(
                      image: AppComponents.dashInvoice,
                      image1: AppComponents.dashInvoiceData,
                      text: "Invoices",
                      text1: "",
                      text2: "",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InvoiceList(),
                          ),
                        );
                        print("Tapped Invoices");
                      },
                    ),
                    containerRow1(
                      image: AppComponents.dashPayment,
                      image1: AppComponents.dashPaymentData,
                      text: "Payments",
                      text1: "",
                      text2: "",
                      onTap: () {
                        print("Tapped Payments");
                        AleartBox.showAleart(
                          context,
                          DialogType.info,
                          'Under development',
                          'This section Under development. Sorry for the inconvenience.',
                        );
                      },
                    ),
                    containerRow1(
                      image: AppComponents.dashClient,
                      image1: AppComponents.dashClientData,
                      text: "Clients",
                      text1: "",
                      text2: "",
                      onTap: () {
                        print("Tapped Clients");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ClientForm(),
                          ),
                        );
                        print("Tapped Invoices");
                      },
                    ),
                    containerRow1(
                      image: AppComponents.dashInventory,
                      image1: AppComponents.dashInventoryData,
                      text: "Inventory",
                      text1: "",
                      text2: "",
                      onTap: () {
                        print("Tapped Inventory");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProductList()),
                        );
                      },
                    ),
                    containerRow1(
                      image: AppComponents.dashAssignment,
                      image1: AppComponents.dashAssignmentData,
                      text: "Assignments",
                      text1: "",
                      text2: "",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AssignmentList(),
                          ),
                        );
                        print("Tapped Assignment");
                      },
                    ),
                    containerRow1(
                      image: AppComponents.dashMap,
                      image1: AppComponents.dashMapData,
                      text: "Map",
                      text1: "",
                      text2: "",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MapPage(),
                          ),
                        );
                        print("Tapped Maps");
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediumScreenLayout() {
    return Material(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildListTile(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: containerRow1(
                            image: AppComponents.dashReport,
                            image1: AppComponents.dashReportData,
                            text: "Reports",
                            text1: "",
                            text2: "",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ReportList(),
                                ),
                              );
                              print("Tapped Reports");
                            },
                          ),
                        ),
                        Expanded(
                          child: containerRow1(
                            image: AppComponents.dashInvoice,
                            image1: AppComponents.dashInvoiceData,
                            text: "Invoices",
                            text1: "",
                            text2: "",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const InvoiceList(),
                                ),
                              );
                              print("Tapped Invoices");
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: containerRow1(
                            image: AppComponents.dashPayment,
                            image1: AppComponents.dashPaymentData,
                            text: "Payments",
                            text1: "",
                            text2: "",
                            onTap: () {
                              print("Tapped Payments");
                            },
                          ),
                        ),
                        Expanded(
                          child: containerRow1(
                            image: AppComponents.dashClient,
                            image1: AppComponents.dashClientData,
                            text: "Clients",
                            text1: "",
                            text2: "",
                            onTap: () {
                              print("Tapped Clients");
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: containerRow1(
                            image: AppComponents.dashInventory,
                            image1: AppComponents.dashInventoryData,
                            text: "Inventory",
                            text1: "",
                            text2: "",
                            onTap: () {
                              print("Tapped Inventory");
                            },
                          ),
                        ),
                        Expanded(
                          child: containerRow1(
                            image: AppComponents.dashAssignment,
                            image1: AppComponents.dashAssignmentData,
                            text: "Assignments",
                            text1: "",
                            text2: "",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AssignmentList(),
                                ),
                              );
                              print("Tapped Assignment");
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: containerRow1(
                            image: AppComponents.dashMap,
                            image1: AppComponents.dashMapData,
                            text: "Map",
                            text1: "",
                            text2: "",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MapPage(),
                                ),
                              );
                              print("Tapped Maps");
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeScreenLayout() {
    return Material(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildListTile(),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: containerRow1(
                            image: AppComponents.dashReport,
                            image1: AppComponents.dashReportData,
                            text: "Reports",
                            text1: "",
                            text2: "",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ReportList(),
                                ),
                              );
                              print("Tapped Reports");
                            },
                          ),
                        ),
                        Expanded(
                          child: containerRow1(
                            image: AppComponents.dashInvoice,
                            image1: AppComponents.dashInvoiceData,
                            text: "Invoices",
                            text1: "",
                            text2: "",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const InvoiceList(),
                                ),
                              );
                              print("Tapped Invoices");
                            },
                          ),
                        ),
                        Expanded(
                          child: containerRow1(
                            image: AppComponents.dashPayment,
                            image1: AppComponents.dashPaymentData,
                            text: "Payments",
                            text1: "",
                            text2: "",
                            onTap: () {
                              print("Tapped Payments");
                            },
                          ),
                        ),
                        Expanded(
                          child: containerRow1(
                            image: AppComponents.dashClient,
                            image1: AppComponents.dashClientData,
                            text: "Clients",
                            text1: "",
                            text2: "",
                            onTap: () {
                              print("Tapped Clients");
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: containerRow1(
                            image: AppComponents.dashInventory,
                            image1: AppComponents.dashInventoryData,
                            text: "Inventory",
                            text1: "",
                            text2: "",
                            onTap: () {
                              print("Tapped Inventory");
                            },
                          ),
                        ),
                        Expanded(
                          child: containerRow1(
                            image: AppComponents.dashAssignment,
                            image1: AppComponents.dashAssignmentData,
                            text: "Assignments",
                            text1: "",
                            text2: "",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AssignmentList(),
                                ),
                              );
                              print("Tapped Assignment");
                            },
                          ),
                        ),
                        Expanded(
                          child: containerRow1(
                            image: AppComponents.dashMap,
                            image1: AppComponents.dashMapData,
                            text: "Map",
                            text1: "",
                            text2: "",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MapPage(),
                                ),
                              );
                              print("Tapped Maps");
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    final commissions = await CommissionService.getCommissionsByEmpId(1);
    final todaysCommissions =
        await CommissionService.getTodaysCommissions(commissions);
    double todaysCommission = 0;
    if (todaysCommissions.isNotEmpty) {
      todaysCommission = double.parse(todaysCommissions.first.commission);
    }
    setState(() {
      _todaysCommission = todaysCommission;
    });
    return;
  }

  Future<void> _fetchUserDetails() async {
    try {
      EmployeeModel user =
          await EmployeeService.getEmployeeDetails(1); // Example user ID
      setState(() {
        _userName = user.name;
        _userEmail = user.email ?? "";
        _userProfilePic = user.profilePicture ?? "";
      });
    } catch (e) {
      print("Failed to fetch user details: $e");
      setState(() {
        _userName = "Failed to load";
      });
    }
  }

  Widget _buildListTile() {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 10, right: 10),
      title: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              SizedBox(
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome back",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                            fontFamily: "PublicSansMedium",
                            fontSize: 12,
                            color: AppColor.placeholderTextColor),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 18,
                            color: AppColor.accentColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _userName,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: AppColor.primaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 1),
              Container(
                decoration: BoxDecoration(
                  color: AppColor.backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color.fromARGB(38, 228, 228, 228),
                    width: 2,
                  ),
                ),
                height: 70,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        size: 30,
                        color: AppColor.accentColor,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          const Expanded(
                            child: Text(
                              "Daily Commission",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1,
                                  fontFamily: "PublicSansMedium",
                                  fontSize: 12,
                                  color: AppColor.placeholderTextColor),
                            ),
                          ),
                          Text(
                            "LKR ${_todaysCommission.toStringAsFixed(2)}",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: AppColor.primaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget containerRow1({
  required String image,
  required String image1,
  required String text,
  required String text1,
  required String text2,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(14),
        elevation: 4,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            text1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            alignment: Alignment.center,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              text2,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  // Ensure InkWell covers the entire Container
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Image.asset(
                    image1,
                    scale: 4.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
