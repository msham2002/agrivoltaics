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
  int site,
  List<int> zones,
  List<SensorMeasurement> fields,
  PickerDateRange timeUnit,
  TimeInterval timeInterval
) {
  var startDate = DateFormat('yyyy-MM-dd').format(timeUnit.startDate!);
  var endDate = DateFormat('yyyy-MM-dd').format(timeUnit.endDate!);

  String zoneQuery = 'r["Zone"] == "${zones[0]}"';
  for (int zone in zones.sublist(1, zones.length)) {
    zoneQuery += ' or r["Zone"] == "${zone}"';
  }

  String fieldQuery = 'r["_field"] == "${fields[0].displayName}"';
  for (SensorMeasurement field in fields.sublist(1, fields.length)) {
    fieldQuery += ' or r["_field"] == "${field.displayName}"';
  }

  return '''
  from(bucket: "${AppConstants.influxdbBucket}")
  |> range(start: ${startDate}T00:00:00Z, stop: ${endDate}T23:59:00Z)
  |> filter(fn: (r) => r["_measurement"] == "Site ${site}")
  |> filter(fn: (r) => ${zoneQuery})
  |> filter(fn: (r) => ${fieldQuery})
  |> aggregateWindow(every: ${timeInterval.value}${timeInterval.unit.fluxQuery}, fn: mean, createEmpty: false)
  |> yield(name: "mean")
  ''';
}

// Get data from InfluxDB according to specified parameters
Future<Map<String, List<FluxRecord>>> getInfluxData
(
  int site,
  Map<int, bool> zoneSelection,
  Map<SensorMeasurement, bool> fieldSelection,
  PickerDateRange timeUnit,
  TimeInterval timeInterval
) async {
  var queryService = influxDBClient.getQueryService();

  var startDate = DateFormat('yyyy-MM-dd').format(timeUnit.startDate!);
  var endDate = DateFormat('yyyy-MM-dd').format(timeUnit.endDate!);

  var dataSets = <String, List<FluxRecord>>{};    
  zoneSelection = Map.from(zoneSelection)..removeWhere((_, value) => !value);
  fieldSelection = Map.from(fieldSelection)..removeWhere((_, value) => !value);

  List<int> selectedZones = List.from(zoneSelection.keys);
  List<SensorMeasurement> selectedFields = List.from(fieldSelection.keys);
  String query = _generateQuery(site, selectedZones, selectedFields, timeUnit, timeInterval);
  Stream<FluxRecord> recordStream = await queryService.query(query);

  List<FluxRecord> records = await recordStream.toList();
  for (var record in records) {
    String key = '${record["_field"]} Zone ${record["Zone"]}';
    if (!dataSets.keys.contains(key)) {
      dataSets[key] = [record];
    } else {
      dataSets[key]!.add(record);
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