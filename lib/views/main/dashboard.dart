import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:order_processing_app/components/custom_button.dart';
import 'package:order_processing_app/services/token_manager.dart';
import 'package:order_processing_app/utils/app_components.dart';
import 'package:order_processing_app/views/auth/login.dart';
import 'package:order_processing_app/views/main/drawer.dart';

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
      backgroundColor: const Color(0xFFF1F1F1),
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
        icon: const Icon(Icons.menu),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer(); // Open the drawer
        },
      ),
      title: Container(
        padding: const EdgeInsets.all(8),
        child: SvgPicture.asset(
          AppComponents.appLogo,
          width: 20, // Adjust width as needed
          height: 20, // Adjust height as needed
          // You can also adjust other properties of SvgPicture.asset here
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
            const SizedBox(height: 20),
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
              image: AppComponents.dashMap,
              image1: AppComponents.dashMapData,
              text: "Map",
              text1: "",
              text2: "",
              onTap: () {
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
            // _buildListTile(),
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
                    image: AppComponents.dashMap,
                    image1: AppComponents.dashMapData,
                    text: "Map",
                    text1: "",
                    text2: "",
                    onTap: () {
                      print("Tapped Map");
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
                    image: AppComponents.dashMap,
                    image1: AppComponents.dashMapData,
                    text: "Map",
                    text1: "",
                    text2: "",
                    onTap: () {
                      print("Tapped Map");
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
    return const ListTile(
      contentPadding: EdgeInsets.only(left: 10, right: 10),
      title: Text(
        "Welcome Back John",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
          fontFamily: "PublicSansMedium",
        ),
        maxLines: 1,
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 5),
        child: Text(
          "Lorem ipsum dolor sit amet, welcome back Johny",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
            fontFamily: "PublicSansRegular",
          ),
          maxLines: 1,
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
                      Text(text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          )),
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
