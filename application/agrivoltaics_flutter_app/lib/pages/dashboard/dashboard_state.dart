import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../app_constants.dart';

/*

Dashboard State
- Contains any data persisted while Dashboard is open

*/
class DashboardState extends ChangeNotifier {
  DashboardState() {
    // Initialize date range selection as past week
    var today = DateTime.now();
    var initialDateRange = PickerDateRange(DateTime(today.year, today.month, today.day - 7, today.hour, today.minute), today);
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
  TimeInterval timeInterval = TimeInterval(TimeUnit.hour, 1);
  late Map<int, bool> zoneSelection;
  late Map<SensorMeasurement, bool> fieldSelection;

  void finalizeState() {
    notifyListeners();
  }
}