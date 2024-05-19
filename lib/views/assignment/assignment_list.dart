import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/web.dart';
import 'package:order_processing_app/components/card_assignment.dart';
import 'package:order_processing_app/models/assignment.dart';
import 'package:order_processing_app/services/assignment_api_service.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/utils/app_components.dart';
import 'package:order_processing_app/views/map/map_page.dart';

class AssignmentList extends StatefulWidget {
  const AssignmentList({super.key});

  @override
  State<AssignmentList> createState() => _AssignmentListState();
}

class _AssignmentListState extends State<AssignmentList> {
  List<Assignment> assignments = [];
  List<Assignment> filteredAssignments = [];
  String _sortBy = 'Sort by Date';
  String _filterBy = 'All';
  bool _isAscending = false; // Initialize with descending order
  bool _isLoading = true;
  DateTimeRange? _selectedDateRange;

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
      if (_sortBy == 'Sort by Date') {
        filteredAssignments.sort((a, b) => _isAscending
            ? a.assignDate.compareTo(b.assignDate)
            : b.assignDate.compareTo(a.assignDate));
      } else if (_sortBy == 'Sort by Route') {
        filteredAssignments.sort((a, b) => _isAscending
            ? a.routeName.compareTo(b.routeName)
            : b.routeName.compareTo(a.routeName));
      } else if (_sortBy == 'Sort by Vehicle Number') {
        filteredAssignments.sort((a, b) => _isAscending
            ? a.vehicleNo.compareTo(b.vehicleNo)
            : b.vehicleNo.compareTo(a.vehicleNo));
      }
    });
  }

  void _applyDateFilter() {
    if (_selectedDateRange != null) {
      setState(() {
        filteredAssignments = assignments.where((assignment) {
          DateTime assignmentDate =
              DateFormat('yyyy-MM-dd').parse(assignment.assignDate);
          return assignmentDate.isAfter(_selectedDateRange!.start) &&
              assignmentDate.isBefore(_selectedDateRange!.end);
        }).toList();
        _sortAssignments();
      });
    } else {
      setState(() {
        filteredAssignments = List.from(assignments);
        _sortAssignments();
      });
    }
  }

  void _applyFilter(String filter) {
    DateTime now = DateTime.now();
    setState(() {
      _filterBy = filter;
      if (filter == 'Today') {
        filteredAssignments = assignments
            .where((a) => DateFormat('yyyy-MM-dd')
                .parse(a.assignDate)
                .isAtSameMomentAs(DateTime(now.year, now.month, now.day)))
            .toList();
        _selectedDateRange = null; // Reset the date range
      } else if (filter == 'All') {
        filteredAssignments = List.from(assignments);
        _selectedDateRange = null; // Reset the date range
      } else if (filter == 'Select Date Range' && _selectedDateRange != null) {
        _applyDateFilter();
      }
      _sortAssignments();
    });
  }

  void _onSortBySelected(String sortBy) {
    setState(() {
      _sortBy = sortBy;
      _sortAssignments(); // Call sorting function when sort by changes
    });
  }

  void _onSortOrderChanged() {
    setState(() {
      _isAscending = !_isAscending;
      _sortAssignments(); // Call sorting function when sort order changes
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColor.accentColor, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: AppColor.primaryTextColor, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColor.accentColor, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _applyFilter('Select Date Range');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.accentColor,
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
          IconButton(
            icon: Icon(
              _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
              color: AppColor.primaryTextColor,
              size: 24,
            ),
            onPressed: _onSortOrderChanged,
          ),
          PopupMenuTheme(
            data: const PopupMenuThemeData(
              color: Colors.white,
              textStyle: TextStyle(color: AppColor.primaryTextColor),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.filter_alt_outlined),
              onSelected: (String result) {
                if (result == 'Select Date Range') {
                  _selectDateRange(context);
                } else {
                  _applyFilter(result);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                _buildRadioMenuItem('All', _filterBy),
                _buildRadioMenuItem('Today', _filterBy),
                _buildRadioMenuItem('Select Date Range', _filterBy),
              ],
            ),
          ),
          PopupMenuTheme(
            data: const PopupMenuThemeData(
              color: Colors.white,
              textStyle: TextStyle(color: AppColor.primaryTextColor),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.sort_rounded),
              onSelected: _onSortBySelected,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                _buildRadioMenuItem('Sort by Date', _sortBy),
                _buildRadioMenuItem('Sort by Route', _sortBy),
                _buildRadioMenuItem('Sort by Vehicle Number', _sortBy),
              ],
            ),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FloatingActionButton(
          backgroundColor: AppColor.accentColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MapPage()),
            );
          },
          child: const Icon(Icons.map_rounded, color: Colors.white),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildRadioMenuItem(String value, String groupValue) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: groupValue,
            onChanged: (String? newValue) {
              if (newValue != null) {
                if (newValue == 'Select Date Range') {
                  _selectDateRange(context);
                } else {
                  _applyFilter(newValue);
                }
                Navigator.pop(context); // Close the popup menu after selection
              }
            },
            activeColor: AppColor.accentColor,
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        const SizedBox(height: 14),
        _buildStatusHeader(), // Update header based on selected date range
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

  Widget _buildStatusHeader() {
    String headerText = 'All Assignments'; // Default header text
    if (_selectedDateRange != null) {
      headerText =
          'Assignments from ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start)} to ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end)}';
    } else if (_filterBy == 'Today') {
      headerText = 'Assignments for Today';
    }
    return Container(
      padding: const EdgeInsets.all(5),
      width: 350,
      decoration: BoxDecoration(
        color: const Color.fromARGB(17, 200, 180, 0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.primaryTextColor, width: 2),
      ),
      child: Text(
        headerText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColor.accentColor,
          fontFamily: AppComponents.fontSFProTextSemibold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
