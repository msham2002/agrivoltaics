import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:influxdb_client/api.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../app_constants.dart';

var getIt = GetIt.instance;
var influxDBClient = getIt.get<InfluxDBClient>();


/*

Dashboard Page

*/
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DashboardState(),
      child: SafeArea(
        child: Scaffold(
          endDrawer: const DashboardDrawer(),
          appBar: AppBar(),
          body: const Dashboard()
        ),
      ),
    );
  }
}

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
    |> aggregateWindow(every: 1${this.timeInterval.fluxQuery}, fn: mean, createEmpty: false)
    |> yield(name: "mean")
    ''';
    var temperatureQuery = '''
    from(bucket: "keithsprings51's Bucket")
    |> range(start: ${startDate}T00:00:00Z, stop: ${endDate}T23:59:00Z)
    |> filter(fn: (r) => r["SSID"] == "TeneComp")
    |> filter(fn: (r) => r["_field"] == "Temperature")
    |> aggregateWindow(every: 1${this.timeInterval.fluxQuery}, fn: mean, createEmpty: false)
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

/*

Dashboard Drawer

*/
class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var dashboardState = context.watch<DashboardState>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DateRangePicker(),
          const TimeRangePicker(),
          ElevatedButton(
            onPressed:() {
              dashboardState.finalizeState();
            },
            child: const Text('Apply')
          )
        ],
      ),
    );
  }
}

/*

Dashboard

*/
class Dashboard extends StatelessWidget {
  const Dashboard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: Consumer<DashboardState>(
              builder: (context, dashboardState, child) {
                return FutureBuilder<List<List<FluxRecord>>>(
                  future: dashboardState.getData(dashboardState.dateRangeSelection),
                  builder: (BuildContext context, AsyncSnapshot<List<List<FluxRecord>>> snapshot) {
                    if (snapshot.hasData) {
                      return SfCartesianChart(
                        // title: ChartTitle(text: 'TODO: change me'),
                        legend: Legend(isVisible: true),
                        trackballBehavior: TrackballBehavior(
                          enable: true,
                          activationMode: ActivationMode.singleTap,
                          tooltipSettings: const InteractiveTooltip(
                            enable: true,
                            format: 'series.name\npoint.y | point.x',
                            borderWidth: 20
                          )
                        ),
                        primaryXAxis: CategoryAxis(),
                        series: <LineSeries<InfluxDatapoint, DateTime>>[
                          LineSeries<InfluxDatapoint, DateTime>(
                            dataSource: InfluxData(snapshot.data![0]).data,
                            xValueMapper: (InfluxDatapoint d, _) => d.timeStamp,
                            yValueMapper: (InfluxDatapoint d, _) => d.value,
                            legendItemText: 'Humidity',
                            name: 'Humidity'
                          ),
                          LineSeries<InfluxDatapoint, DateTime>(
                            dataSource: InfluxData(snapshot.data![1]).data,
                            xValueMapper: (InfluxDatapoint d, _) => d.timeStamp,
                            yValueMapper: (InfluxDatapoint d, _) => d.value,
                            legendItemText: 'Temperature',
                            name: 'Temperature'
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
                );
              }
            )
          ),
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
    var dashboardState = context.watch<DashboardState>();
    
    return Center(child: SfDateRangePicker(
      onSelectionChanged: (args) {
        dashboardState.dateRangeSelection = args.value;
      },
      initialSelectedRange: dashboardState.dateRangeSelection,
      selectionMode: DateRangePickerSelectionMode.extendableRange
    ));
  }
}

/*

Time Range Picker

*/
class TimeRangePicker extends StatefulWidget {
  const TimeRangePicker({
    super.key,
  });

  @override
  State<TimeRangePicker> createState() => _TimeRangePickerState();
}

class _TimeRangePickerState extends State<TimeRangePicker> {
  @override
  Widget build(BuildContext context) {
    var dashboardState = context.watch<DashboardState>();
    TimeRange dropdownValue = dashboardState.timeInterval;

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
              DropdownMenuItem(
                value: TimeRange.day,
                child: Text('days')
              ),
              DropdownMenuItem(
                value: TimeRange.week,
                child: Text('weeks')
              ),
              DropdownMenuItem(
                value: TimeRange.month,
                child: Text('months')
              )
            ],
            onChanged: (value) {
              dashboardState.timeInterval = value!;
              setState(() {
                dropdownValue = value;
              });
            },
            value: dropdownValue
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