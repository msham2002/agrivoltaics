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
  }
  
  late PickerDateRange dateRangeSelection;
  TimeInterval timeInterval = TimeInterval(TimeUnit.hour, 1);

  Map<int, bool> zoneSelection = {
    1: true,
    2: true,
    3: true
  };
  Map<SensorMeasurement, bool> fieldSelection = {
    SensorMeasurement.humidity: true,
    SensorMeasurement.temperature: true
  };

  void finalizeState() {
    notifyListeners();
  }
}