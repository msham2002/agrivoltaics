import 'package:agrivoltaics_flutter_app/app_constants.dart';
import 'package:agrivoltaics_flutter_app/pages/home/notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

class Zone {
  String name;
  List<bool> measurements;
  bool checked;

  Zone({
    required this.name,
    required this.measurements,
    this.checked = true,
  });
}

class Site {
  String name;
  List<Zone> zones;
  bool checked;

  Site({
    required this.name,
    required this.zones,
    this.checked = true,
  });
}

class AppState extends ChangeNotifier {
  AppState() {
    this.timezone = tz.getLocation(AppConstants.timezone);
    this.sites = [
      Site(
        name: 'Site 1',
        zones: [
          Zone(
            name: 'Zone 1',
            measurements: List<bool>.filled(6, true),
          ),
        ],
      ),
    ];
  }

  // Settings
  late tz.Location timezone;

  // Sites and Zones
  List<Site> sites = [];

  // Notifications
  List<AppNotification> notifications = [];

  void finalizeState() {
    notifyListeners();
  }
}