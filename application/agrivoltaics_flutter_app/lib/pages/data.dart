import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard)),
              Tab(icon: Icon(Icons.calendar_today)),
              Tab(icon: Icon(Icons.access_alarm))
            ]
          )
        ),
        body: const TabBarView(
          children: [
            Dashboard(),
            DateRangePicker(),
            TimeRangePicker()
          ]
        )
      ),
    );
  }
}

enum TimeRange {
  minute,
  hour,
  day,
  week,
  month
}

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

class DateRangePicker extends StatelessWidget {
  const DateRangePicker({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: SfDateRangePicker());
  }
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
          child: SfCartesianChart(
            title: ChartTitle(text: 'Dashboard'),
            primaryXAxis: CategoryAxis(),
            series: <LineSeries<LuxData, DateTime>>[
              LineSeries<LuxData, DateTime>(
                dataSource: <LuxData>[
                  LuxData(DateTime.parse("1997-07-16"), 37.11),
                  LuxData(DateTime.parse("1997-07-17"), 34.18),
                  LuxData(DateTime.parse("1997-07-18"), 37.11),
                  LuxData(DateTime.parse("1997-07-19"), 36.13),
                  LuxData(DateTime.parse("1997-07-20"), 36.13),
                  LuxData(DateTime.parse("1997-07-21"), 35.16),
                  LuxData(DateTime.parse("1997-07-22"), 43.95),
                  LuxData(DateTime.parse("1997-07-23"), 46.88),
                  LuxData(DateTime.parse("1997-07-24"), 44.92),
                  LuxData(DateTime.parse("1997-07-25"), 45.9),
                  LuxData(DateTime.parse("1997-07-26"), 45.9),
                  LuxData(DateTime.parse("1997-07-27"), 46.88)
                ],
                xValueMapper: (LuxData lux, _) => lux.timeStamp,
                yValueMapper: (LuxData lux, _) => lux.lux
              )
            ],
            zoomPanBehavior: ZoomPanBehavior(
              enablePinching: true
            ),
          )
        )
      ],
    );
  }
}

class LuxData {
  LuxData(this.timeStamp, this.lux);
  final DateTime timeStamp;
  final double lux;
}