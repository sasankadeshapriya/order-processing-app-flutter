import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

enum ImageType { profile, logo, nicFront, nicBack }

// Function to get image from gallery
Future<String?> getImageFromGallery(
    BuildContext context, ImageType imageType) async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    // Handle the picked image file
    File image = File(pickedFile.path);
    // Show toast message
    Fluttertoast.showToast(
      msg: 'Image added successfully',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
    return pickedFile.path; // Return the image path
  } else {
    return null; // Return null if no image was selected
  }
}

// Function to get image from camera
Future<String?> getImageFromCamera(
    BuildContext context, ImageType imageType) async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
  if (pickedFile != null) {
    // Handle the picked image file
    File image = File(pickedFile.path);
    // Show toast message
    Fluttertoast.showToast(
      msg: 'Image added successfully',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
    return pickedFile.path; // Return the image path
  } else {
    return null; // Return null if no image was captured
  }
}

Future<String?> openImagePickerBottomSheet(
    BuildContext context, ImageType imageType) async {
  String? imagePath;

  imagePath = await showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(
                    context, await getImageFromGallery(context, imageType));
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(
                    context, await getImageFromCamera(context, imageType));
              },
            ),
          ],
        ),
      );
    },
  );

  // Return the selected imagePath or null if no image was selected
  return imagePath;
}
