import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:influxdb_client/api.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dashboard_drawer.dart';
import 'dashboard_state.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

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
          // TODO: Drawer when vertical, sliding up panel when horizontal
          // Sliding up panel should be formatted with datepicker on left, time interval and apply button on right
          endDrawer: (MediaQuery.of(context).orientation == Orientation.portrait) || (MediaQuery.of(context).size.shortestSide < 600.0) ? const DashboardDrawer() : null,
          appBar: AppBar(),
          body: const Dashboard()
        ),
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
        ),
        // if (MediaQuery.of(context).orientation == Orientation.landscape) SlidingUpPanel(
        //   panel: Center(
        //     child: Wrap(
        //       children: [
        //         Row(
        //           children: [
        //             Expanded(child: DateRangePicker()),
        //             Expanded(child: TimeRangePicker())
        //           ],
        //         ),
        //       ],
        //     )
        //   ),
        //   collapsed: Container(
        //     decoration: const BoxDecoration(
        //       // color: Colors.blueGrey,
        //       borderRadius: BorderRadius.only(
        //         topLeft: Radius.circular(24.0),
        //         topRight: Radius.circular(24.0)
        //       )
        //     ),
        //     child: Column(
        //       children: const [
        //         const BarIndicator()
        //       ]
        //     )
        //   )
        // )
      ],
    );
  }
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

class BarIndicator extends StatelessWidget {
  const BarIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: 40, height: 3,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }
}