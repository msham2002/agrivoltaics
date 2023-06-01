import 'package:agrivoltaics_flutter_app/app_constants.dart';
import 'package:agrivoltaics_flutter_app/pages/home/notifications.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:timezone/timezone.dart' as tz;

class Zone {
  String name;
  Map<SensorMeasurement, bool> fields;
  bool checked;
  
  Zone({
    required this.name,
    required this.fields,
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

class AppState with ChangeNotifier {
  AppState() {
    // Initialize site selection
    this.siteSelection = 1;

    this.singleGraphToggle = false;

    // Initialize date range selection as past week
    var now = DateTime.now();
    var initialDateRange = PickerDateRange(DateTime(now.year, now.month, now.day, now.hour - 24, now.minute), now);
    this.dateRangeSelection = initialDateRange;

    this.timezone = tz.getLocation(AppConstants.timezone);
    
    this.sites = [
      Site(
        name: 'Site 1',
        zones: [
          Zone(
            name: 'Zone 1',
            fields: {
        SensorMeasurement.humidity: true,
        SensorMeasurement.temperature: true,
        SensorMeasurement.light: true,
        SensorMeasurement.frost: true,
        SensorMeasurement.rain: true,
        SensorMeasurement.soil: true
      },
          ),
        ],
      ),
    ];
  }

  late PickerDateRange dateRangeSelection;
  TimeInterval timeInterval = TimeInterval(TimeUnit.hour, 1);
  Map<int, bool> zoneSelection = <int, bool>{};
  Map<SensorMeasurement, bool> fieldSelection = <SensorMeasurement, bool>{};

  // keeping temporarily for the chart name.
  late int siteSelection;

  late bool singleGraphToggle;

  // Settings
  late tz.Location timezone;

  // Sites and Zones
  List<Site> sites = [];

  // Notifications
  List<AppNotification> notifications = [];

  void setSingleGraphToggle(bool value) {
      singleGraphToggle = value;
      notifyListeners();
  }


  void addSite() {
      sites.add(
        Site(name: 'Site ${sites.length + 1}',         
        zones: [
          Zone(
            name: 'Zone 1',
            fields: {
        SensorMeasurement.humidity: true,
        SensorMeasurement.temperature: true,
        SensorMeasurement.light: true,
        SensorMeasurement.frost: true,
        SensorMeasurement.rain: true,
        SensorMeasurement.soil: true
      },
          ),
        ], checked: true),
      );
      notifyListeners();
  }

  void removeSite(int index) {

      sites.removeAt(index);
      for (int i = 0; i < sites.length; i++) { 
        sites[i].name = 'Site ${i + 1}';
      }
      notifyListeners();
  }

  void addZone(int siteIndex) {
      sites[siteIndex].zones.add(
        Zone(
          name: 'Zone ${sites[siteIndex].zones.length + 1}',
          fields: {
            SensorMeasurement.humidity: true,
            SensorMeasurement.temperature: true,
            SensorMeasurement.light: true,
            SensorMeasurement.rain: true,
            SensorMeasurement.frost: true,
            SensorMeasurement.soil: true,
          },
          checked: true,
        ),
      );
      notifyListeners();
  }

  void removeZone(int siteIndex, int zoneIndex) {
      sites[siteIndex].zones.removeAt(zoneIndex);
      for (int i = 0; i < sites.length; i++) {
        for (int j = 0; j < sites[i].zones.length; j++) {
          sites[i].zones[j].name = 'Zone ${j + 1}';
        }
      }
      notifyListeners();
  }

  void toggleSiteChecked(int siteIndex) {
      sites[siteIndex].checked = !sites[siteIndex].checked;
      notifyListeners();
  }

  void toggleZoneChecked(int siteIndex, int zoneIndex) {
      sites[siteIndex].zones[zoneIndex].checked =
          !sites[siteIndex].zones[zoneIndex].checked;
      notifyListeners();
  }

  void toggleMeasurementChecked(
      int siteIndex, int zoneIndex, SensorMeasurement measurement) {
      sites[siteIndex].zones[zoneIndex].fields[measurement] =
          !sites[siteIndex].zones[zoneIndex].fields[measurement]!;
      notifyListeners();
  }

  void finalizeState() {
    notifyListeners();
  }
}