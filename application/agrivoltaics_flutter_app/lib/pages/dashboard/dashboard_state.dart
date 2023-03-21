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
  Map<int, bool> zoneSelection = {
    1: true,
    2: true,
    3: true
  };
  Map<SensorType, bool> fieldSelection = {
    SensorType.humidity: true,
    SensorType.temperature: true
  };

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
    var selectedZones = Map.from(zoneSelection)..removeWhere((_, value) => !value);
    var selectedFields = Map.from(fieldSelection)..removeWhere((_, value) => !value);
    for (var field in selectedFields.entries) {
      for (var zone in selectedZones.entries) {
        SensorType selectedField = field.key;
        var humidityQuery = _generateQuery(zone.key, timeRange, selectedField.displayName!);

        Stream<FluxRecord> recordStream = await queryService.query(humidityQuery);

        var records = <FluxRecord>[];
        await recordStream.forEach((record) {
          records.add(record);
        });

        dataSets['${selectedField.displayName} Zone ${zone.key}'] = records;
      }
    }
    
    
    
    return dataSets;
  }
}