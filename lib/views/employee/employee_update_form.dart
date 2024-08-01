import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:order_processing_app/services/employee_api_service.dart';
import 'package:order_processing_app/services/token_manager.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/views/clients/image_handller.dart';
import 'package:order_processing_app/models/employee_model.dart';
import 'package:order_processing_app/views/main/dashboard.dart';
import 'package:order_processing_app/widgets/profile_picture_widget.dart';
import '../../components/custom_button.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class EmployeeUpdate extends StatefulWidget {
  const EmployeeUpdate({super.key});

  @override
  State<EmployeeUpdate> createState() => _EmployeeUpdateState();
}

class _EmployeeUpdateState extends State<EmployeeUpdate> {
  String? _logoImagePath;
  bool isLoading = false;
  bool isUploading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  int empId = TokenManager.empId ?? 0;

  String? _nameError;
  String? _phoneError;
  String? _nicError;

  @override
  void initState() {
    super.initState();
    _fetchEmployeeDetails();
  }

  Future<void> _fetchEmployeeDetails() async {
    setState(() {
      isLoading = true;
    });
    try {
      EmployeeModel employee = await EmployeeService.getEmployeeDetails(empId);
      _nameController.text = employee.name ?? '';
      _phoneController.text = employee.phoneNo ?? '';
      _nicController.text = employee.nic ?? '';
      setState(() {
        _logoImagePath = employee.profilePicture;
      });
    } catch (e) {
      _showErrorDialog('Error fetching employee details', e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateProfilePicture(File imageFile) async {
    setState(() {
      isUploading = true;
    });
    try {
      await EmployeeService.updateProfilePicture(empId, imageFile);
      EmployeeModel updatedEmployee = await EmployeeService.getEmployeeDetails(empId);
      setState(() {
        _logoImagePath = updatedEmployee.profilePicture;
      });
    } catch (e) {
      _showErrorDialog('Error updating profile picture', e.toString());
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  String? _validateNic(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter NIC';
    }

    final nic9DigitWithLetterRegExp = RegExp(r'^\d{9}[A-Za-z]?$');
    final nic12DigitRegExp = RegExp(r'^\d{12}$');

    if (value.length == 10) {
      if (!nic9DigitWithLetterRegExp.hasMatch(value)) {
        return 'NIC must be 9 digits followed by a letter (optional)';
      }
    } else if (value.length == 12) {
      if (!nic12DigitRegExp.hasMatch(value)) {
        return 'NIC must be exactly 12 digits';
      }
    } else {
      return 'Invalid format for NIC';
    }

    return null;
  }

  String? _validatePhoneNumber(String? value) {
    final phoneRegExp = RegExp(r'^[0-9]{10}$');
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    } else if (!phoneRegExp.hasMatch(value)) {
      return 'Phone number must be 10 digits';
    }
    return null;
  }

  Future<void> _updateEmployeeDetails() async {
    setState(() {
      isLoading = true;
    });
    try {
      await EmployeeService.updateEmployeeDetails(
        empId,
        name: _nameController.text.isNotEmpty ? _nameController.text : null,
        nic: _nicController.text.isNotEmpty ? _nicController.text : null,
        phoneNo: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      );

      // Fetch updated employee details
      EmployeeModel updatedEmployee = await EmployeeService.getEmployeeDetails(empId);
      setState(() {
        _nameController.text = updatedEmployee.name ?? '';
        _phoneController.text = updatedEmployee.phoneNo ?? '';
        _nicController.text = updatedEmployee.nic ?? '';
      });

      // Show success dialog
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Success',
        desc: 'Employee details updated successfully.',
        btnOkText: 'OK',
        btnOkOnPress: () {
          // Optionally navigate back or refresh the screen
        },
      ).show();
    } catch (e) {
      _showErrorDialog('Error updating employee details', e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handleUpdate() {
    if (!isLoading) {
      setState(() {
        _nameError = _nameController.text.isEmpty ? 'Please enter a name' : null;
        _phoneError = _validatePhoneNumber(_phoneController.text);
        _nicError = _validateNic(_nicController.text);
      });

      if (_phoneError == null && _nicError == null) {
        _updateEmployeeDetails();
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      title: title,
      desc: message,
      btnOkText: 'OK',
      btnOkOnPress: () {},
    ).show();
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColor.primaryTextColor,
            fontWeight: FontWeight.w500,
          ),
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColor.primaryTextColor,
            ),
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColor.primaryTextColor.withOpacity(0.8),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColor.accentColor, // Replace with your desired color
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColor.primaryTextColor,
              size: 15,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const UserDashboard()),
              );
            },
          ),
        ),
        title: const Text(
          'Update Profile',
          style: TextStyle(
            color: Color(0xFF464949),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            fontFamily: 'SF Pro Text',
          ),
        ),
        backgroundColor: AppColor.backgroundColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30, bottom: 30),
                      child: ProfilePictureWidget(
                        imagePath: _logoImagePath,
                        isUploading: isUploading,
                        onTap: () async {
                          String? imagePath = await openImagePickerBottomSheet(context, ImageType.profile);
                          if (imagePath != null) {
                            File imageFile = File(imagePath);
                            await _updateProfilePicture(imageFile);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _nameController,
                      labelText: 'User name',
                      hintText: 'Enter User name',

                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _phoneController,
                      labelText: 'Phone number',
                      hintText: 'Enter Phone number',
                      errorText: _phoneError,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _nicController,
                      labelText: 'NIC',
                      hintText: 'Enter NIC Number (NIC)',
                      errorText: _nicError,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CustomButton(
                buttonText: isLoading ? 'Updating...' : 'Update',
                onTap: _handleUpdate,
                isLoading: isLoading,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
