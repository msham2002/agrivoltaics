import 'package:agrivoltaics_flutter_app/app_constants.dart';
import 'package:get_it/get_it.dart';
import 'package:influxdb_client/api.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

var getIt = GetIt.instance;
var influxDBClient = getIt.get<InfluxDBClient>();

// Generate InfluxDB Flux query
String _generateQuery
(
  int zone,
  PickerDateRange timeRange,
  String field,
  TimeRange timeIntervalUnit,
  int timeIntervalValue
) {
  var startDate = DateFormat('yyyy-MM-dd').format(timeRange.startDate!);
  var endDate = DateFormat('yyyy-MM-dd').format(timeRange.endDate!);

  return '''
  from(bucket: "keithsprings51's Bucket")
  |> range(start: ${startDate}T00:00:00Z, stop: ${endDate}T23:59:00Z)
  |> filter(fn: (r) => r["SSID"] == "TeneComp")
  |> filter(fn: (r) => r["_field"] == "${field} Site ${zone}")
  |> aggregateWindow(every: ${timeIntervalValue}${timeIntervalUnit.fluxQuery}, fn: mean, createEmpty: false)
  |> yield(name: "mean")
  ''';
}

// Get data from InfluxDB according to specified parameters
Future<Map<String, List<FluxRecord>>> getInfluxData
(
  PickerDateRange timeRange,
  Map<int, bool> zoneSelection,
  Map<SensorType, bool> fieldSelection,
  TimeRange timeIntervalUnit,
  int timeIntervalValue
) async {
  var queryService = influxDBClient.getQueryService();

  var startDate = DateFormat('yyyy-MM-dd').format(timeRange.startDate!);
  var endDate = DateFormat('yyyy-MM-dd').format(timeRange.endDate!);

  var dataSets = <String, List<FluxRecord>>{};    
  var selectedZones = Map.from(zoneSelection)..removeWhere((_, value) => !value);
  var selectedFields = Map.from(fieldSelection)..removeWhere((_, value) => !value);
  for (var field in selectedFields.entries) {
    for (var zone in selectedZones.entries) {
      SensorType selectedField = field.key;
      var humidityQuery = _generateQuery(zone.key, timeRange, selectedField.displayName!, timeIntervalUnit, timeIntervalValue);

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

class InfluxDatapoint {
  InfluxDatapoint(this.timeStamp, this.value);
  final DateTime timeStamp;
  final double value;
}

class InfluxData {
  InfluxData(this.records) {
    this.data = <InfluxDatapoint>[];
    for (var record in this.records) {
      this.data.add(InfluxDatapoint(DateTime.parse(record['_time']), record['_value']));
    }
  }
  final List<FluxRecord> records;
  late List<InfluxDatapoint> data;
}