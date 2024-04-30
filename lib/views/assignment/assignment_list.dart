import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logger/web.dart';
import 'package:order_processing_app/components/card_assignment.dart';
import 'package:order_processing_app/models/assignment.dart';
import 'package:order_processing_app/services/assignment_api_service.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/utils/app_components.dart';
import 'package:order_processing_app/views/map/map_page.dart';

class AssignmentList extends StatefulWidget {
  const AssignmentList({Key? key}) : super(key: key);

  @override
  State<AssignmentList> createState() => _AssignmentListState();
}

class _AssignmentListState extends State<AssignmentList> {
  List<Assignment> assignments = [];
  List<Assignment> filteredAssignments = [];
  String _sortBy = 'date';
  String _filterBy = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  void _loadAssignments() async {
    try {
      var assignmentDetails =
          await AssignmentApiService.getAssignmentsWithDetails(1);
      setState(() {
        assignments =
            assignmentDetails.map((e) => Assignment.fromJson(e)).toList();
        filteredAssignments = List.from(assignments); // Initially no filter
        _sortAssignments();
        _isLoading = false; // Set loading to false after assignments are loaded
      });
    } catch (e) {
      Logger().w('Failed to load assignments: $e');
      setState(() {
        _isLoading =
            false; // Ensure loading state is updated even if there's an error
      });
    }
  }

  void _sortAssignments() {
    setState(() {
      if (_sortBy == 'date') {
        filteredAssignments
            .sort((a, b) => a.assignDate.compareTo(b.assignDate));
      } else if (_sortBy == 'route') {
        filteredAssignments.sort((a, b) => a.routeName.compareTo(b.routeName));
      } else if (_sortBy == 'vehicle number') {
        filteredAssignments.sort((a, b) => a.vehicleNo.compareTo(b.vehicleNo));
      }
    });
  }

  void _applyFilter(String filter) {
    DateTime now = DateTime.now();
    setState(() {
      _filterBy = filter;
      switch (filter) {
        case 'today':
          filteredAssignments = assignments
              .where((a) => DateFormat('yyyy-MM-dd')
                  .parse(a.assignDate)
                  .isAtSameMomentAs(DateTime(now.year, now.month, now.day)))
              .toList();
          break;
        case 'this month':
          filteredAssignments = assignments.where((a) {
            DateTime date = DateFormat('yyyy-MM-dd').parse(a.assignDate);
            return date.month == now.month && date.year == now.year;
          }).toList();
          break;
        default:
          filteredAssignments = List.from(assignments);
      }
      _sortAssignments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
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
          "Assignments",
          style: TextStyle(
            color: Color(0xFF464949),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            fontFamily: 'SF Pro Text',
          ),
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String result) {
              _applyFilter(result);
            },
            icon: const Icon(Icons.filter_alt_outlined,
                color: AppColor.primaryTextColor),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              CheckedPopupMenuItem<String>(
                value: 'all',
                checked: _filterBy == 'all',
                child: const Text('All assignments'),
              ),
              CheckedPopupMenuItem<String>(
                value: 'today',
                checked: _filterBy == 'today',
                child: const Text('For today'),
              ),
              CheckedPopupMenuItem<String>(
                value: 'this month',
                checked: _filterBy == 'this month',
                child: const Text('For this month'),
              ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (String result) {
              setState(() {
                _sortBy = result;
                _sortAssignments();
              });
            },
            icon: const Icon(Icons.sort_rounded,
                color: AppColor.primaryTextColor),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              CheckedPopupMenuItem<String>(
                value: 'date',
                checked: _sortBy == 'date',
                child: const Text('Sort by date'),
              ),
              CheckedPopupMenuItem<String>(
                value: 'route',
                checked: _sortBy == 'route',
                child: const Text('Sort by route'),
              ),
              CheckedPopupMenuItem<String>(
                value: 'vehicle number',
                checked: _sortBy == 'vehicle number',
                child: const Text('Sort by vehicle number'),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FloatingActionButton(
          onPressed: () {
            // Navigate to the map view
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const MapPage()), // Assuming MapPage is your map widget
            );
          },
          backgroundColor: AppColor.accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: const BorderSide(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.map_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildStatusHeader(_filterBy), // Update header based on filter
        const SizedBox(height: 14),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColor.accentColor),
                  ),
                )
              : filteredAssignments.isEmpty
                  ? const Center(
                      child: Text(
                        "No assignments available.",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primaryTextColor,
                        ),
                      ),
                    )
                  : _buildAssignmentsContainer(context),
        ),
      ],
    );
  }

  Widget _buildAssignmentsContainer(BuildContext context,
      {double widthFactor = 1.0}) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
      width: MediaQuery.of(context).size.width * widthFactor,
      decoration: BoxDecoration(
        color: AppColor.primaryTextColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListView.builder(
        itemCount: filteredAssignments.length,
        itemBuilder: (context, index) {
          final assignment = filteredAssignments[index];
          print(assignment.assignDate);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: AssignmentCard(
              date: assignment.assignDate.toString(), // Format date as needed
              routeName: assignment.routeName,
              vehicleNumber: assignment.vehicleNo,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusHeader(String filter) {
    String headerText = 'All'; // Default header text
    if (filter == 'today') {
      headerText = 'Assignments for Today';
    } else if (filter == 'this month') {
      headerText = 'Assignments for This Month';
    }
    return Container(
      padding: const EdgeInsets.all(5),
      width: 350,
      decoration: BoxDecoration(
          color: AppColor.backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColor.primaryTextColor, width: 2)),
      child: Text(
        headerText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryTextColor,
          fontFamily: AppComponents.fontSFProTextSemibold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
