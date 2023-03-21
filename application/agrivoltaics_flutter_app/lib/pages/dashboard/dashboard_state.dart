import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';
import 'package:influxdb_client/api.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../app_constants.dart';

var getIt = GetIt.instance;
var influxDBClient = getIt.get<InfluxDBClient>();

/*

Dashboard State

*/
class DashboardState extends ChangeNotifier {
  DashboardState() {
    // Initialize date range selection as past week
    var today = DateTime.now();
    var initialDateRange = PickerDateRange(DateTime(today.year, today.month, today.day - 7, today.hour, today.minute), today);
    this.dateRangeSelection = initialDateRange;
  }
  
  late PickerDateRange dateRangeSelection;
  TimeRange timeInterval = TimeRange.hour;
  int timeIntervalValue = 1;
  List<int> selectedZones = [1, 2, 3];

  void finalizeState() {
    notifyListeners();
  }

  String _generateQuery(int zone, PickerDateRange timeRange, String field) {
    var startDate = DateFormat('yyyy-MM-dd').format(timeRange.startDate!);
    var endDate = DateFormat('yyyy-MM-dd').format(timeRange.endDate!);

    return '''
    from(bucket: "keithsprings51's Bucket")
    |> range(start: ${startDate}T00:00:00Z, stop: ${endDate}T23:59:00Z)
    |> filter(fn: (r) => r["SSID"] == "TeneComp")
    |> filter(fn: (r) => r["_field"] == "${field} Site ${zone}")
    |> aggregateWindow(every: ${this.timeIntervalValue}${this.timeInterval.fluxQuery}, fn: mean, createEmpty: false)
    |> yield(name: "mean")
    ''';
  }

  Future<Map<String, List<FluxRecord>>> getData(PickerDateRange timeRange) async {
    var queryService = influxDBClient.getQueryService();

    var startDate = DateFormat('yyyy-MM-dd').format(timeRange.startDate!);
    var endDate = DateFormat('yyyy-MM-dd').format(timeRange.endDate!);

    var dataSets = new Map<String, List<FluxRecord>>();

    for (int zone in selectedZones) {
      // TODO: Create constants for query fields like humidity and temperature
      var humidityQuery = _generateQuery(zone, timeRange, 'Humidity');
      var temperatureQuery = _generateQuery(zone, timeRange, 'Temperature');

      Stream<FluxRecord> humidityRecordStream = await queryService.query(humidityQuery);
      Stream<FluxRecord> temperatureRecordStream = await queryService.query(temperatureQuery);

      var humidityRecords = <FluxRecord>[];
      await humidityRecordStream.forEach((record) {
        humidityRecords.add(record);
      });
      var temperatureRecords = <FluxRecord>[];
      await temperatureRecordStream.forEach((record) {
        temperatureRecords.add(record);
      });

      // TODO: constants here too
      dataSets['Humidity Zone ${zone}'] = humidityRecords;
      dataSets['Temperature Zone ${zone}'] = temperatureRecords;
    }
    
    
    return dataSets;
  }
}