import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';

import '../../components/alert_dialog.dart';
import '../../components/custom_button.dart';
import '../../components/custom_widget.dart';
import '../../models/clients_modle.dart';
import '../../services/client_api_service.dart';
import '../../utils/app_colors.dart';
import '../helpers/form_validation.dart';
import '../main/dashboard.dart';
import 'client_location.dart';
import 'image_handller.dart';

class ClientForm extends StatefulWidget {
  const ClientForm({
    super.key,
  });

  @override
  _ClientFormState createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> {
  final ClientService clientService = ClientService();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _logoController =
      TextEditingController(); // Add controller for logo field
  bool _showAdditionalNicField = false; // Track additional field for NIC
  bool _showAdditionalLogoField = false; // Track additional field for logo
  late bool _isExpanded = false;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false; // Add a loading state

  String? _organizationName;
  String? _nicFrontImagePath;
  String? _nicBackImagePath;
  String? _logoImagePath;
  String? _contactNumber;

  String? _clientName;
  String? _shippingAddress;
  String? _taxId;
  String? _businessDetails;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();

    // Initialize logo controller
  }

  @override
  void dispose() {
    _nicController.dispose();
    _logoController.dispose(); // Dispose logo controller
    _locationController.dispose();
    super.dispose();
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
              Navigator.pop(context);
            },
          ),
        ),
        title: const Text(
          'Client Entry Form',
          style: TextStyle(
            color: Color(0xFF464949),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            fontFamily: 'SF Pro Text',
          ),
        ),
        backgroundColor: AppColor.accentColor,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CustomTextFormField(
                            autofocus: true,
                            labelText: 'Organization Name',
                            hintText: 'Organization Name',
                            validator: FormValidator.validateOrgName,
                            onSaved: (value) {
                              _organizationName = value;
                            },
                          ),

                          const SizedBox(
                            height: 10,
                          ),
                          CustomTextFormField(
                            readOnly: true,
                            controller:
                                _locationController, // Controller to display location data
                            labelText: 'Location',
                            onAddPressed: () async {
                              var locationResult = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MapSample(),
                                ),
                              );

                              // Check if the locationResult is not null and then update latitude and longitude
                              if (locationResult != null) {
                                _latitude = locationResult['latitude'];
                                _longitude = locationResult['longitude'];

                                // Update the text field to show these values
                                _locationController.text =
                                    'Lat: $_latitude, Lng: $_longitude';
                              }
                            },
                          ),

                          const SizedBox(
                            height: 10,
                          ),
                          CustomTextFormField(
                            keyboardType: TextInputType.phone,
                            hintText: 'Contact No.',
                            labelText: 'Contact No.',
                            validator: FormValidator.phoneNumber,
                            onSaved: (value) {
                              _contactNumber = value;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomTextFormField(
                            labelText: 'Client Name',
                            hintText: 'Client Name',
                            validator: FormValidator.validateClientName,
                            onSaved: (value) {
                              _clientName = value;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (_isExpanded)
                            Column(
                              children: [
                                CustomTextFormField(
                                  readOnly: true,
                                  labelText: 'NIC',
                                  onAddPressed: () {
                                    setState(() {
                                      _showAdditionalNicField =
                                          !_showAdditionalNicField;
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                if (_showAdditionalNicField)
                                  Column(
                                    children: [
                                      CustomTextFormField(
                                        labelText: 'Front NIC Image',
                                        buttonText: 'Choose File',
                                        onAddPressed: () async {
                                          String? imagePath =
                                              await openImagePickerBottomSheet(
                                                  context, ImageType.nicFront);
                                          setState(() {
                                            _nicFrontImagePath = imagePath;
                                          });
                                        },
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      CustomTextFormField(
                                        labelText: 'Back NIC Image',
                                        buttonText: 'Choose File',
                                        onAddPressed: () async {
                                          String? imagePath =
                                              await openImagePickerBottomSheet(
                                                  context, ImageType.nicBack);
                                          setState(() {
                                            _nicBackImagePath = imagePath;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                const SizedBox(
                                  height: 8,
                                ),
                                CustomTextFormField(
                                  readOnly: true,
                                  labelText: 'LOGO',
                                  onAddPressed: () {
                                    setState(() {
                                      _showAdditionalLogoField =
                                          !_showAdditionalLogoField;
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                if (_showAdditionalLogoField)
                                  CustomTextFormField(
                                    labelText: 'Logo Image',
                                    buttonText: 'Choose File',
                                    onAddPressed: () async {
                                      String? imagePath =
                                          await openImagePickerBottomSheet(
                                              context, ImageType.logo);
                                      setState(() {
                                        _logoImagePath = imagePath;
                                      });
                                    },
                                  ),
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomTextFormField(
                                  labelText: 'Business Address',
                                  hintText: 'Business Address',
                                  validator: FormValidator.validateAddress,
                                  onSaved: (value) {
                                    _shippingAddress = value;
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomTextFormField(
                                  labelText: 'Tax Id',
                                  hintText: 'Tax Id',
                                  onSaved: (value) {
                                    _taxId = value;
                                  },
                                  validator: FormValidator.taxID,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomTextFormField(
                                  labelText: ' Business Details',
                                  hintText: ' Business Details',
                                  validator:
                                      FormValidator.validateBusinessDetails,
                                  onSaved: (value) {
                                    _businessDetails = value;
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          const SizedBox(
                            height: 15,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isExpanded = !_isExpanded;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  _isExpanded
                                      ? 'assets/icon/less_info.svg'
                                      : 'assets/icon/add_more.svg',
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isExpanded ? 'View Less' : 'Add More Info',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 80), // Adjust as needed
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: CustomButton(
                    buttonText: 'Add This Client',
                    onTap: () {
                      setState(() {
                        isLoading = true;
                      });
                      _handleAddClient();
                    },
                    isLoading: isLoading,

                    // Other code...
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  void _handleAddClient() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save form state

      Logger().i('Organization Name: $_organizationName');
      Logger().i('Client Name: $_clientName');
      Logger().i('Contact Number: $_contactNumber');
      Logger().i('Latitude: $_latitude');
      Logger().i('Longitude: $_longitude');

      createNewClient();
    }
  }

  void createNewClient() async {
    isLoading = true;

    Client newClient = Client(
      organizationName: _organizationName!,
      name: _clientName!,
      latitude: _latitude,
      longitude: _longitude,
      phoneNo: _contactNumber,
      addedByEmployeeId: 1, //TokenManager.empId,
      status: 'not verified', // Default status set to 'not verified'
      creditLimit: 0.0, // Default credit limit set to 0
      creditPeriod: 0, // Default credit period set to 90
      routeId: 1, // Default route ID set to 1
      discount: 0.0,
    );

    // Now send this data to your server
    clientService.postClientData(newClient);
    var result = await clientService.postClientData(newClient);
    await Future.delayed(Duration(seconds: 1));
    isLoading = false; // Turn off loading indicator after the request

    if (result['success']) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success, // Changed to DialogType.SUCCES
        animType: AnimType.bottomSlide,
        title: 'Success', // Changed title to Success
        desc:
            'Client successfully created', // Changed message to a success notification
        btnOkText: 'OK',
        btnOkOnPress: () {
          // Navigate to dashboard after clicking OK
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const UserDashboard()));
        },
      )..show();
    } else {
      AleartBox.showAleart(
        context,
        DialogType.error,
        'Error',
        result['message'] ??
            'An unknown error occurred.', // Default message if none provided
      );
    }
  }
}
