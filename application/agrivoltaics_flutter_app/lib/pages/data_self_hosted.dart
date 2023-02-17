import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DataDashboardSelfHosted extends StatefulWidget {
  const DataDashboardSelfHosted({super.key});

  @override
  State<DataDashboardSelfHosted> createState() => _DataDashboardSelfHostedState();
}

class _DataDashboardSelfHostedState extends State<DataDashboardSelfHosted> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: OrientationBuilder(builder: (context, orientation) {
        return Center(
          child: SfCartesianChart(
            title: ChartTitle(text: 'Lux Measurements'),
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
        );
      })
    );
  }
}

class LuxData {
  LuxData(this.timeStamp, this.lux);
  final DateTime timeStamp;
  final double lux;
}