import 'dart:async';
import 'dart:math';
import 'dart:math' as math;
import 'package:agrivoltaics_flutter_app/app_constants.dart';
import 'package:agrivoltaics_flutter_app/app_state.dart';
import 'package:agrivoltaics_flutter_app/influx.dart';
import 'package:agrivoltaics_flutter_app/pages/dashboard/dashboard_appbar.dart';
import 'package:agrivoltaics_flutter_app/pages/dashboard/dashboard_drawer.dart';
import 'package:agrivoltaics_flutter_app/pages/dashboard/dashboard_datetime_filter.dart';
import 'package:agrivoltaics_flutter_app/pages/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:influxdb_client/api.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
//import 'stationary_dashboard_graph.dart'; // We'll define this next

class TabbedDashboardPage extends StatelessWidget {
  const TabbedDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final sites = appState.sites;
    int numberOfZones = 0;

    // Each site will be its own tab. If there are no sites, show a simple message.
    if (sites.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No sites available.')),
      );
    }

    // A DefaultTabController is required for TabBar / TabBarView to work together.
    return DefaultTabController(
      length: sites.length,
      child: Scaffold(
        appBar: DashboardAppBar(
          tabBar: TabBar(
            isScrollable: true, 
            tabs: sites.map((site) {
              // Decide what text to display on the tab
              final tabText = site.nickName.isNotEmpty ? site.nickName : site.name;
              return Tab(text: tabText);
            }).toList(),
          ),
        ),
        // TabBarView shows a "page" for each tab
        body: TabBarView(
          children: sites.map((site) {
            // A SingleChildScrollView to allow vertical scrolling of zone charts
            return SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: site.zones.map((zone) {
                  // Only create a chart if the zone is checked
                  if (!zone.checked) return const SizedBox.shrink();

                  final zoneTitle = zone.nickName.isNotEmpty
                      ? zone.nickName
                      : zone.name;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            'Zone: $zoneTitle',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // Show your chart for this zone
                          SizedBox(
                            height: 300,
                            child: DashboardGraph(
                              numberOfZones: numberOfZones += 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}


class DashboardGraph extends StatefulWidget {
  final int numberOfZones;

  const DashboardGraph({Key? key, required this.numberOfZones}) : super(key: key);

  @override
  _DashboardGraphState createState() => _DashboardGraphState(numberOfZones: numberOfZones);
}

class _DashboardGraphState extends State<DashboardGraph> with AutomaticKeepAliveClientMixin{
  late int numberOfZones;
  int colorIndex = 0;
  List<Color> legendColorList = [];
  List<Color> currentLegendColors = [];

  _DashboardGraphState({required this.numberOfZones});

  Color assignColorToField(MapEntry<String, List<FluxRecord>> fieldData) {
    if (fieldData.key.contains("Humidity")) {
      return Colors.blue;
    } else if (fieldData.key.contains("Temperature")) {
      return Colors.red;
    } else if (fieldData.key.contains("Lux")) {
      return Colors.yellow;
    } else if (fieldData.key.contains("Rain")) {
      return Colors.purple;
    } else if (fieldData.key.contains("Frost")) {
      return Colors.green;
    } else if (fieldData.key.contains("Soil")) {
      return Colors.grey;
    }

      return Colors.black;
  }

  @override
  bool get wantKeepAlive => true;
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    

    return Consumer<AppState>(
      builder: (context, AppState, child) {
        // Refresh widget according to dashboard state's time interval (real-time data)
        Timer.periodic(AppState.timeInterval.duration!, (Timer t) => {if (this.mounted) setState((){})});



    String siteGraphTitle = '';
    String zoneGraphTitle = '';
    String graphTitle = '';
    int zoneValue = numberOfZones;
    if (appState.singleGraphToggle) {
      graphTitle = "All Data selected";
    } else {
      for (int i = 1; i <= appState.sites.length; i++) {
        if (zoneValue == 0) {
          break;
        }
        
        if (appState.sites[i-1].checked) {
          for (int j = 1; j <= appState.sites[i-1].zones.length; j++) {
            if (appState.sites[i-1].zones[j-1].checked) {
            zoneValue -= 1;
            if (zoneValue == 0) {
              if (appState.sites[i-1].nickName == '') {
                siteGraphTitle = appState.sites[i-1].name;
              } else {
                siteGraphTitle += '(${appState.sites[i-1].name}) ${appState.sites[i-1].nickName}';
              }
              
              if (appState.sites[i-1].zones[j-1].nickName == '') {
                zoneGraphTitle = appState.sites[i-1].zones[j-1].name;
              } else {
                zoneGraphTitle = '(${appState.sites[i-1].zones[j-1].name}) ${appState.sites[i-1].zones[j-1].nickName}';
              }
              
              graphTitle = '$siteGraphTitle, $zoneGraphTitle';
              

              
            }
            }
          }
        }
      }
    }

        return FutureBuilder<Map<String, List<FluxRecord>>>(
          // Async method called by FutureBuilder widget, whose results will eventually populate widget
          future: getInfluxData
          (
            appState.dateRangeSelection,
            appState.timeInterval,
            appState.sites,
            appState.singleGraphToggle,
            numberOfZones,
            appState.returnDataValue
          ),

          builder: (BuildContext context, AsyncSnapshot<Map<String, List<FluxRecord>>> snapshot) {
            // Once the data snapshot is populated with above method results, render chart
            if (snapshot.hasData) {
              return SfCartesianChart(
                title: ChartTitle(text: graphTitle),
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
                series: <LineSeries<InfluxDatapoint, String>>[
                  for (var data in snapshot.data!.entries)...[
                    LineSeries<InfluxDatapoint, String>(
                      // dataSource: InfluxData(data.value, appState.timezone).data,
                      dataSource: InfluxData(data, appState.timezone).datapoints,
                      color: assignColorToField(data),
                      xValueMapper: (InfluxDatapoint d, _) => d.timeStamp,
                      yValueMapper: (InfluxDatapoint d, _) => d.value,
                      legendItemText: data.key,
                      name: data.key
                    )
                  ]
                ],
                zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true
                ),
              );
            } else {
              // The results have not yet been returned. Indicate loading
              return Center(
                child: const CircularProgressIndicator(),
              );
            }
          },
        );
      }
    );
  }
}