import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';

import '../../components/alert_dialog.dart';
import '../../components/custom_button.dart';
import '../../components/custom_widget.dart';
import '../../models/clients_modle.dart';
import '../../services/client_api_service.dart';
import '../../services/token_manager.dart';
import '../../utils/app_colors.dart';
import '../helpers/form_validation.dart';
import '../main/dashboard.dart';
import 'client_location.dart';
import 'image_handller.dart';

class ClientForm extends StatefulWidget {
  final Client? client;

  const ClientForm({Key? key, this.client}) : super(key: key);

  @override
  _ClientFormState createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> {
  final ClientService clientService = ClientService();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _orgController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _clientNameController = TextEditingController();

  bool _showAdditionalNicField = false;
  bool _showAdditionalLogoField = false;
  bool _isExpanded = false;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String appBarTitle = 'Client Entry Form';
  bool showPrefixIcon = false;

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
    if (widget.client != null) {
      appBarTitle = 'Update Client Form';
      Logger().i('Selected Client for Edit:', error: widget.client);

      _orgController.text = widget.client!.organizationName ?? '';
      _clientNameController.text = widget.client!.name ?? '';
      _contactNumberController.text = widget.client!.phoneNo ?? '';
      _latitude = widget.client!.latitude;
      _longitude = widget.client!.longitude;

      // Log client details
      // Logger().i('Organization Name: ${widget.client!.organizationName}');
      // Logger().i('Client Name: ${widget.client!.name}');
      // Logger().i('Contact Number: ${widget.client!.phoneNo}');
      // Logger().i('Latitude: ${widget.client!.latitude}');
      // Logger().i('Longitude: ${widget.client!.longitude}');
    }
  }

  @override
  void dispose() {
    _contactNumberController.dispose();
    _locationController.dispose();
    _orgController.dispose();
    _clientNameController.dispose();
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
        title: Text(
          appBarTitle,
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
                            controller: _orgController,
                            autofocus: true,
                            labelText: 'Organization Name',
                            hintText: 'Organization Name',
                            validator: FormValidator.validateOrgName,
                            onSaved: (value) {
                              _organizationName = value;
                            },
                          ),
                          const SizedBox(height: 10),
                          CustomTextFormField(
                            readOnly: true,
                            controller: _locationController,
                            labelText: 'Location',
                            prefixIcon:
                                Icon(Icons.check_circle, color: Colors.green),
                            showPrefixIcon: showPrefixIcon,
                            onAddPressed: () async {
                              var locationResult = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MapSample(),
                                ),
                              );

                              if (locationResult != null) {
                                setState(() {
                                  showPrefixIcon = true;
                                  _latitude = locationResult['latitude'];
                                  _longitude = locationResult['longitude'];
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          CustomTextFormField(
                            controller: _contactNumberController,
                            keyboardType: TextInputType.phone,
                            hintText: 'Contact No.',
                            labelText: 'Contact No.',
                            validator: FormValidator.phoneNumber,
                            onSaved: (value) {
                              _contactNumber = value;
                            },
                          ),
                          const SizedBox(height: 10),
                          CustomTextFormField(
                            controller: _clientNameController,
                            labelText: 'Client Name',
                            hintText: 'Client Name',
                            validator: FormValidator.validateClientName,
                            onSaved: (value) {
                              _clientName = value;
                            },
                          ),
                          const SizedBox(height: 10),
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
                                const SizedBox(height: 8),
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
                                      const SizedBox(height: 10),
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
                                const SizedBox(height: 8),
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
                                const SizedBox(height: 8),
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
                                const SizedBox(height: 10),
                                CustomTextFormField(
                                  labelText: 'Business Address',
                                  hintText: 'Business Address',
                                  validator: FormValidator.validateAddress,
                                  onSaved: (value) {
                                    _shippingAddress = value;
                                  },
                                ),
                                const SizedBox(height: 10),
                                CustomTextFormField(
                                  labelText: 'Tax Id',
                                  hintText: 'Tax Id',
                                  onSaved: (value) {
                                    _taxId = value;
                                  },
                                  validator: FormValidator.taxID,
                                ),
                                const SizedBox(height: 10),
                                CustomTextFormField(
                                  labelText: 'Business Details',
                                  hintText: 'Business Details',
                                  validator:
                                      FormValidator.validateBusinessDetails,
                                  onSaved: (value) {
                                    _businessDetails = value;
                                  },
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          const SizedBox(height: 15),
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
                          const SizedBox(height: 80),
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
                    buttonText: widget.client != null
                        ? 'Update Client'
                        : 'Add This Client',
                    onTap: () {
                      _handleAddClient();
                    },
                    isLoading: isLoading,
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
      _formKey.currentState!.save();

      // Logger().i('Organization Name: $_organizationName');
      // Logger().i('Client Name: $_clientName');
      // Logger().i('Contact Number: $_contactNumber');
      // Logger().i('Latitude: $_latitude');
      // Logger().i('Longitude: $_longitude');

      if (widget.client != null) {
        // Update existing client logic
        updateClient(widget.client!);
      } else {
        // Create new client logic
        createNewClient();
      }
    }
  }

  void createNewClient() async {
    setState(() {
      isLoading = true;
    });

    Client newClient = Client(
      organizationName: _organizationName!,
      name: _clientName!,
      latitude: _latitude,
      longitude: _longitude,
      phoneNo: _contactNumber,
      addedByEmployeeId: TokenManager.empId ?? 1, // change hard code values
      status: 'not verified',
      creditLimit: 30000.0,
      creditPeriod: 90,
      routeId: 3, // change hard code values
      discount: 1.0,
    );

    var result = await clientService.postClientData(newClient);

    setState(() {
      isLoading = false;
    });

    if (result['success']) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Success',
        desc: 'Client successfully created',
        btnOkText: 'OK',
        btnOkOnPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserDashboard()),
          );
        },
      ).show();
    } else {
      AleartBox.showAleart(
        context,
        DialogType.error,
        'Error',
        result['message'] ?? 'An unknown error occurred.',
      );
    }
  }

  void updateClient(Client client) async {
    setState(() {
      isLoading = true;
    });
    String phoneAsString = _contactNumber.toString();
    double? latitude = _latitude ?? client.latitude;
    double? longitude = _longitude ?? client.longitude;
    Map<String, dynamic> clientData = {
      'organization_name': _organizationName!,
      'name': _clientName!,
      'latitude': latitude,
      'longitude': longitude,
      'phone_no': phoneAsString,
      'route_id': client.routeId,
      'discount': client.discount,
      'credit_limit': client.creditLimit,
      'credit_period': client.creditPeriod,
      'added_by_employee_id': TokenManager.empId ?? 1,
    };

    var result = await clientService.updateClient(client.clientId, clientData);

    setState(() {
      isLoading = false;
    });

    if (result['success']) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Success',
        desc: 'Client successfully updated',
        btnOkText: 'OK',
        btnOkOnPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserDashboard()),
          );
        },
      ).show();
    } else {
      Logger().e("Update Failed: ${result['message']}");
      AleartBox.showAleart(
        context,
        DialogType.error,
        'Error',
        result['message'] ?? 'An unknown error occurred.',
      );
    }
  }
}
