import 'package:agrivoltaics_flutter_app/app_constants.dart';
import 'package:get_it/get_it.dart';
import 'package:influxdb_client/api.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:timezone/standalone.dart' as tz;

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
  var startDate = DateFormat('yyyy-MM-dd').format(timeUnit.startDate!.toUtc());
  var endDate = DateFormat('yyyy-MM-dd').format(timeUnit.endDate!.toUtc());

  String zoneQuery = 'r["Zone"] == "${zones[0]}"';
  for (int zone in zones.sublist(1, zones.length)) {
    zoneQuery += ' or r["Zone"] == "${zone}"';
  }

  String fieldQuery = 'r["_field"] == "${fields[0].fluxQuery}"';
  // String fieldQuery = 'r["_field"] == "${fields[0].displayName}"';
  for (SensorMeasurement field in fields.sublist(1, fields.length)) {
    fieldQuery += ' or r["_field"] == "${field.fluxQuery}"';
    // fieldQuery += ' or r["_field"] == "${field.displayName}"';
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

  var dataSets = <String, List<FluxRecord>>{};    
  zoneSelection = Map.from(zoneSelection)..removeWhere((_, value) => !value);
  fieldSelection = Map.from(fieldSelection)..removeWhere((_, value) => !value);

  List<int> selectedZones = List.from(zoneSelection.keys);
  List<SensorMeasurement> selectedFields = List.from(fieldSelection.keys);
  String query = _generateQuery(site, selectedZones, selectedFields, timeUnit, timeInterval);
  Stream<FluxRecord> recordStream = await queryService.query(query);

  List<FluxRecord> records = await recordStream.toList();
  for (var record in records) {
    // DO NOT EXECUTE THE BELOW OR THE RECORDSTREAM WILL NEVER BE READ
    // WHO KNOWS WHY, I SURE DON'T
    // TOOK ME 3 HOURS OF DEBUGGING TO FIGURE THAT ONE OUT
    // String field = record['_field'];
    // String zone = record['Zone'];

    SensorMeasurement measurement = SensorMeasurement.values.firstWhere((e) => e.fluxQuery == record['_field']);

    String key = '${measurement.displayName} (${measurement.unit}) Zone ${record["Zone"]}';
    if (!dataSets.keys.contains(key)) {
      dataSets[key] = [record];
    } else {
      dataSets[key]!.add(record);
    }
  }
  
  Map<String, List<FluxRecord>> sortedDataSets = Map.fromEntries(
    dataSets.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key))
  );
  return sortedDataSets;
}

// TODO: document these properly, maybe clean up/rename to make more understandable
class InfluxDatapoint {
  InfluxDatapoint(DateTime timeStamp, this.value, this.unit, tz.Location timezone) {
    this.timeStamp = DateFormat('yyyy-MM-dd kk:mm:ss').format(tz.TZDateTime.from(timeStamp, timezone));
  }
  late String timeStamp;
  final double? value;
  final String unit;
}

class InfluxData {
  InfluxData(this.data, tz.Location timezone) {
    for (var record in this.data.value) {
      DateTime timestamp = DateTime.parse(record['_time']);
      String field = record['_field'];
      double? value = record['_value'];
      String unit = SensorMeasurement.values.firstWhere((e) => e.fluxQuery == field).unit;
      this.datapoints.add(InfluxDatapoint(timestamp, value, unit, timezone));
    }
  }
  // final List<FluxRecord> records;
  MapEntry<String, List<FluxRecord>> data;
  List<InfluxDatapoint> datapoints = [];
}