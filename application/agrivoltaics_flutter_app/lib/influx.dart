import 'package:agrivoltaics_flutter_app/app_constants.dart';
import 'package:get_it/get_it.dart';
import 'package:influxdb_client/api.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:agrivoltaics_flutter_app/app_state.dart';
import 'package:agrivoltaics_flutter_app/pages/settings.dart';
import 'package:timezone/standalone.dart' as tz;

var getIt = GetIt.instance;
var influxDBClient = getIt.get<InfluxDBClient>();

// Generate InfluxDB Flux Query
String _generateQuery
(
  PickerDateRange timeUnit,
  TimeInterval timeInterval,
  List<Site> sites,
  bool singleGraphToggle,
  int numberOfZones,
  String returnDataValue
) {
  var startDate = DateFormat('yyyy-MM-dd').format(timeUnit.startDate!.toUtc());
  var endDate = DateFormat('yyyy-MM-dd').format(timeUnit.endDate!.toUtc());

String query = "|> filter(fn: (r) => ";
// first case is if the toggle for multiple sites is selected
if (singleGraphToggle == false) {
  for (int i = 1; i <= sites.length; i++) {
    if (sites[i-1].checked) {
      for (int j = 1; j <= sites[i-1].zones.length; j++) {
        if (sites[i-1].zones[j-1].checked) {
          

          numberOfZones -= 1;
          if (numberOfZones == 0) {
            query += '(r._measurement == "${sites[i-1].name}" and (r.Zone == "$j"';
            List<MapEntry<SensorMeasurement, bool>> fieldEntries = sites[i-1].zones[j-1].fields.entries.toList();

            int fieldCount = 0;

            for (var entry in fieldEntries) {
              bool checked = entry.value;

              if (checked == true) {
                fieldCount++;
              }
            }

            if (fieldCount == 0) {
              query += ' and (r._field == "N/A"))';
            }
            else {
              bool firstCheckedSite = true;
              for (int k = 1; k <= sites[i-1].zones[j-1].fields.length; k++) {
                MapEntry<SensorMeasurement, bool> firstEntry = fieldEntries[k-1];
                String measurement = firstEntry.key.fluxQuery;
                bool checked = firstEntry.value;

                if (checked) {
                  if (fieldCount == 1) {
                    query += ' and (r._field == "$measurement"))';
                  }
                  else if (k == 1 || firstCheckedSite == true) {
                    query += ' and (r._field == "$measurement"';
                    firstCheckedSite = false;
                  } else if (k != sites[i-1].zones[j-1].fields.length) {
                    query += ' or r._field  == "$measurement"';
                  } else {
                    query += ' or r._field  == "$measurement"))';
                  }
                }
              }
            }
          }
        }
      }
    }
  }
} else {
  
  for (int l = 1; l <= sites.length; l++) {
    bool firstZoneIsEmpty = false;
    bool zoneWasEmptyBefore = false;
    bool zeroZones = false;
     if (sites[l-1].checked) {
      int zoneCount = 0;
        for (int m = 1; m <= sites[l-1].zones.length; m++) {

          if (sites[l-1].zones[m-1].checked) {
            zoneCount += 1;
          }

          if (m == sites[l-1].zones.length && zoneCount == 0) {
            zeroZones = true;
          }
        }
       if (zeroZones) {
         continue;
       }
       else if (l == 1) {
         query += '(r._measurement == "${sites[l-1].name}" ';
       } else {
         query += ') or (r._measurement == "${sites[l-1].name}" ';
       }
       for (int i = 1; i <= sites[l-1].zones.length; i++) {
         
          List<MapEntry<SensorMeasurement, bool>> fieldEntries = sites[l-1].zones[i-1].fields.entries.toList();

          int fieldCount = 0;

          for (var entry in fieldEntries) {
            bool checked = entry.value;

            if (checked == true) {
              fieldCount++;
            }
          }
         
          if ((!sites[l-1].zones[i-1].checked || fieldCount == 0) && !zoneWasEmptyBefore) {
            firstZoneIsEmpty = true;
            continue;
          }
          else if (sites[l-1].zones[i-1].checked) {
            if (fieldCount == 0) {
              continue;
            }
            else if (i == 1 || firstZoneIsEmpty) {
              zoneWasEmptyBefore = true;
              firstZoneIsEmpty = false;
              query += 'and (r.Zone == "$i"';
            } else {
              query += ' or (r.Zone == "$i"';
            } 
            
            bool firstCheckedSite = true;
            int checkedCount = 0;
            for (int j = 1; j <= sites[l-1].zones[i-1].fields.length; j++) {
              MapEntry<SensorMeasurement, bool> firstEntry = fieldEntries[j-1];
              String measurement = firstEntry.key.fluxQuery;
              bool checked = firstEntry.value;
              
              if (checked) {
                checkedCount += 1;
                if (fieldCount == 1) {
                  query += ' and (r._field == "$measurement"))';
                }
                else if (j == 1 || firstCheckedSite == true) {
                  query += ' and (r._field == "$measurement"';
                  firstCheckedSite = false;
                } else if (checkedCount != fieldCount) {
                  query += ' or r._field == "$measurement"';
                } else {
                  query += ' or r._field == "$measurement"))';
                }
              }
            }
          }
        }
     }
  }
}

int openBrackets = query.split('(').length - 1;
int closeBrackets = query.split(')').length - 1;

int balance = openBrackets - closeBrackets;

if (balance > 0) {
  query += ')' * balance;
} else if (balance < 0) {
  query = query.substring(0, query.length + balance);
}

  return '''
  from(bucket: "${AppConstants.influxdbBucket}")
  |> range(start: ${startDate}T00:00:00Z, stop: ${endDate}T23:59:00Z)
  $query
  |> aggregateWindow(every: ${timeInterval.value}${timeInterval.unit.fluxQuery}, fn: $returnDataValue, createEmpty: false)
  |> yield(name: "$returnDataValue")
  ''';
}

// Get data from InfluxDB according to specified parameters
Future<Map<String, List<FluxRecord>>> getInfluxData
(
  PickerDateRange timeUnit,
  TimeInterval timeInterval,
  List<Site> sites,
  bool singleGraphToggle,
  int numberOfZones,
  String returnDataValue
) async {
  var queryService = influxDBClient.getQueryService();

  var dataSets = <String, List<FluxRecord>>{};    
  String query = _generateQuery(timeUnit, timeInterval, sites, singleGraphToggle, numberOfZones, returnDataValue);

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