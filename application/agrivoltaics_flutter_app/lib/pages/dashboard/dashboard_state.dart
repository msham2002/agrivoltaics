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
    // Initialize date range selection as today through next week
    var today = DateTime.now();
    var initialDateRange = PickerDateRange(today, DateTime(today.year, today.month, today.day, today.hour + 23, today.minute + 59));
    this.dateRangeSelection = initialDateRange;
  }
  
  late PickerDateRange dateRangeSelection;
  TimeRange timeInterval = TimeRange.hour;
  int timeIntervalValue = 1;

  void finalizeState() {
    notifyListeners();
  }

  Future<List<List<FluxRecord>>> getData(PickerDateRange timeRange) async {
    var queryService = influxDBClient.getQueryService();

    var startDate = DateFormat('yyyy-MM-dd').format(timeRange.startDate!);
    var endDate = DateFormat('yyyy-MM-dd').format(timeRange.endDate!);

    var humidityQuery = '''
    from(bucket: "keithsprings51's Bucket")
    |> range(start: ${startDate}T00:00:00Z, stop: ${endDate}T23:59:00Z)
    |> filter(fn: (r) => r["SSID"] == "TeneComp")
    |> filter(fn: (r) => r["_field"] == "Humidity")
    |> aggregateWindow(every: ${this.timeIntervalValue}${this.timeInterval.fluxQuery}, fn: mean, createEmpty: false)
    |> yield(name: "mean")
    ''';
    var temperatureQuery = '''
    from(bucket: "keithsprings51's Bucket")
    |> range(start: ${startDate}T00:00:00Z, stop: ${endDate}T23:59:00Z)
    |> filter(fn: (r) => r["SSID"] == "TeneComp")
    |> filter(fn: (r) => r["_field"] == "Temperature")
    |> aggregateWindow(every: ${this.timeIntervalValue}${this.timeInterval.fluxQuery}, fn: mean, createEmpty: false)
    |> yield(name: "mean")
    ''';

    Stream<FluxRecord> humidityRecordStream = await queryService.query(humidityQuery);
    Stream<FluxRecord> temperatureRecordStream = await queryService.query(temperatureQuery);

    var dataSets = <List<FluxRecord>>[];

    var humidityRecords = <FluxRecord>[];
    await humidityRecordStream.forEach((record) {
      humidityRecords.add(record);
    });
    var temperatureRecords = <FluxRecord>[];
    await temperatureRecordStream.forEach((record) {
      temperatureRecords.add(record);
    });

    dataSets.add(humidityRecords);
    dataSets.add(temperatureRecords);
    
    return dataSets;
  }
}