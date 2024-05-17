import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/utils/app_components.dart';
import 'package:order_processing_app/views/assignment/assignment_list.dart';
import 'package:order_processing_app/views/invoice/invoice_list_page.dart';
import 'package:order_processing_app/views/main/drawer.dart';
import 'package:order_processing_app/views/map/map_page.dart';
import '../clients/client_form.dart';
import '../invoice/invoicePage.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  late ScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double maxWidth = MediaQuery.of(context).size.width;
    final double maxHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      drawer: const AppDrawer(),
      body: Container(
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
            const SizedBox(height: 10),
            containerRow1(
              image: AppComponents.dashReport,
              image1: AppComponents.dashReportData,
              text: "Reports",
              text1: "",
              text2: "",
              onTap: () {
                print("Tapped Repoerts");
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
                    builder: (context) => ClientForm(),
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
                      print("Tapped Repoerts");
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
            const SizedBox(height: 20),
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
                      print("Tapped Repoerts");
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
    );
  }

  Widget _buildListTile() {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 10, right: 10),
      title: const Text(
        "Welcome Back John",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
          fontFamily: "PublicSansMedium",
        ),
        maxLines: 1,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColor.placeholderTextColor),
          ),
          child: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Daily Commission :",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                      fontFamily: "PublicSansMedium",
                    ),
                    maxLines: 1,
                  ),
                ),
                Text(
                  "\$00.00",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    fontFamily: "PublicSansMedium",
                    color: AppColor.accentColor,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
    );
  }
}
