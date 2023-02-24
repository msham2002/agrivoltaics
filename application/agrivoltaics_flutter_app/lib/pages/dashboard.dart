import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:influxdb_client/api.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../app_constants.dart';


/*

Dashboard Page

*/
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        endDrawer: const DashboardDrawer(),
        appBar: AppBar(),
        body: const Dashboard()
      ),
    );
  }
}


/*

Dashboard Drawer

*/
class DashboardDrawer extends StatefulWidget {
  const DashboardDrawer({
    super.key,
  });

  @override
  State<DashboardDrawer> createState() => _DashboardDrawerState();
}

class _DashboardDrawerState extends State<DashboardDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          DateRangePicker(),
          TimeRangePicker()
        ],
      ),
    );
  }
}


/*

Dashboard

*/

Future<String> healthCheck() async {
  // TODO: remove on release
  var getIt = GetIt.instance;
  var influxDBClient = getIt.get<InfluxDBClient>();
  var healthCheck = await influxDBClient.getPingApi().getPingWithHttpInfo();
  return 'Health check: ${healthCheck.statusCode}';
}

Future<List<List<FluxRecord>>> getData() async {
  var getIt = GetIt.instance;
  var influxDBClient = getIt.get<InfluxDBClient>();

  var queryService = influxDBClient.getQueryService();
  var humidityQuery = '''
  from(bucket: "keithsprings51's Bucket")
  |> range(start: -3d, stop: -1h)
  |> filter(fn: (r) => r["SSID"] == "TeneComp")
  |> filter(fn: (r) => r["_field"] == "Humidity")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
  |> yield(name: "mean")
  ''';
  var temperatureQuery = '''
  from(bucket: "keithsprings51's Bucket")
  |> range(start: -3d, stop: -1h)
  |> filter(fn: (r) => r["SSID"] == "TeneComp")
  |> filter(fn: (r) => r["_field"] == "Temperature")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
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

class Dashboard extends StatelessWidget {
  const Dashboard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: FutureBuilder<List<List<FluxRecord>>>(
            future: getData(),
            builder: (BuildContext context, AsyncSnapshot<List<List<FluxRecord>>> snapshot) {
              if (snapshot.hasData) {
                return SfCartesianChart(
                  title: ChartTitle(text: 'TODO: change me'),
                  legend: Legend(isVisible: true),
                  trackballBehavior: TrackballBehavior(
                    enable: true,
                    activationMode: ActivationMode.singleTap,
                    tooltipSettings: const InteractiveTooltip(
                      enable: true,
                      format: 'point.y\npoint.x'
                    )
                  ),
                  primaryXAxis: CategoryAxis(),
                  series: <LineSeries<InfluxDatapoint, DateTime>>[
                    LineSeries<InfluxDatapoint, DateTime>(
                      dataSource: InfluxData(snapshot.data![0]).data,
                      xValueMapper: (InfluxDatapoint d, _) => d.timeStamp,
                      yValueMapper: (InfluxDatapoint d, _) => d.value,
                      legendItemText: "Humidity"
                    ),
                    LineSeries<InfluxDatapoint, DateTime>(
                      dataSource: InfluxData(snapshot.data![1]).data,
                      xValueMapper: (InfluxDatapoint d, _) => d.timeStamp,
                      yValueMapper: (InfluxDatapoint d, _) => d.value,
                      legendItemText: "Temperature"
                    )
                  ],
                  zoomPanBehavior: ZoomPanBehavior(
                    enablePinching: true
                  ),
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          )
        )
      ],
    );
  }
}


/*

Date Range Picker

*/
class DateRangePicker extends StatelessWidget {
  const DateRangePicker({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: SfDateRangePicker());
  }
}


/*

Time Range Picker

*/
class TimeRangePicker extends StatelessWidget {
  const TimeRangePicker({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Time Interval:',
            style: TextStyle(
              fontSize: 18
            )
          ),
          Container(
            width: 15,
          ),
          // TextField
          DropdownButton(
            items: const [
              DropdownMenuItem(
                value: TimeRange.minute,
                child: Text('minutes')
              ),
              DropdownMenuItem(
                value: TimeRange.hour,
                child: Text('hours')
              ),
            ],
            onChanged: (value) {
              print(value);
            },
            value: TimeRange.hour
          ),
        ],
      )
    );
  }
}

// TODO: Temporary mock data structure to be moved elsewhere
class LuxData {
  LuxData(this.timeStamp, this.lux);
  final DateTime timeStamp;
  final double lux;
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