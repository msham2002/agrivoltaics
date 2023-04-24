import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../app_constants.dart';

/*

Dashboard State
- Contains any data persisted while Dashboard is open

*/
class DashboardState extends ChangeNotifier {
  DashboardState(int site) {
    // Initialize site selection
    this.siteSelection = site;

    // Initialize date range selection as past week
    var now = DateTime.now();
    var initialDateRange = PickerDateRange(DateTime(now.year, now.month, now.day, now.hour - 24, now.minute), now);
    this.dateRangeSelection = initialDateRange;

    // Initialize zone selection 
    for (int zone = 1; zone <= AppConstants.numZones; zone++) {
      zoneSelection[zone] = true;
    }

    // Initialize sensor measurement selection
    for (var measurement in SensorMeasurement.values) {
      fieldSelection[measurement] = true;
    }
  }
  
  late PickerDateRange dateRangeSelection;
  TimeInterval timeInterval = TimeInterval(TimeUnit.minute, 1);
  late int siteSelection;
  Map<int, bool> zoneSelection = <int, bool>{};
  Map<SensorMeasurement, bool> fieldSelection = <SensorMeasurement, bool>{};

  void finalizeState() {
    notifyListeners();
  }
}