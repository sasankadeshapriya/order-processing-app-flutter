import 'package:flutter/material.dart';
import 'package:order_processing_app/utils/app_colors.dart';

class ProfilePictureWidget extends StatelessWidget {
  final String? imagePath;
  final bool isUploading;
  final VoidCallback onTap;

  const ProfilePictureWidget({
    Key? key,
    required this.imagePath,
    required this.isUploading,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 70,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: imagePath != null ? NetworkImage(imagePath!) : null,
          child: imagePath == null
              ? const Icon(Icons.person, size: 50, color: Colors.grey)
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.camera_alt, size: 20, color: Colors.black),
            ),
          ),
        ),
        if (isUploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.accentColor),
                ),
              ),
            ),
          ),

      ],
    );
  }
}
