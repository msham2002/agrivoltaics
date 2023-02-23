import 'package:flutter/material.dart';
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
            title: ChartTitle(text: 'TODO: change me'),
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