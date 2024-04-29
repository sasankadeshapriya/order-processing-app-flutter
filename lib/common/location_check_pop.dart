import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

void showLocationServiceDialog(
    BuildContext context, bool isGpsSignalAvailable) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(isGpsSignalAvailable
            ? "Location Service Disabled"
            : "GPS Signal Lost"),
        content: Text(
          isGpsSignalAvailable
              ? "Please enable location services to use this app."
              : "GPS signal is lost. Please wait for GPS signal to be restored.",
        ),
        actions: <Widget>[
          if (isGpsSignalAvailable)
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          if (isGpsSignalAvailable)
            TextButton(
              child: const Text("Go to Settings"),
              onPressed: () =>
                  AppSettings.openAppSettings(type: AppSettingsType.location),
            ),
          if (!isGpsSignalAvailable)
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
        ],
      );
    },
  );
}
