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

class TabbedDashboardPage extends StatelessWidget {
  TabbedDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int numberOfGraphs = 0;
    int numberOfZones = 0;
    final appState = Provider.of<AppState>(context);
    final sites = appState.sites;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWideScreen = MediaQuery.of(context).size.width >= 1920 || screenHeight < screenWidth;

    if (context.read<AppState>().singleGraphToggle) {
      numberOfGraphs = 1;
    } else {
      for (int i = 0; i < context.read<AppState>().sites.length; i++) {
          for (int j = 0; j < context.read<AppState>().sites[i].zones.length; j++) {
            if (context.read<AppState>().sites[i].zones[j].checked) {
              numberOfGraphs += 1;
            }
          }
      }
    }
    int graphsPerRow = 1;
    int numberOfRows = (numberOfGraphs / graphsPerRow).ceil();

    if (sites.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No sites available.')),
      );
    }

    return DefaultTabController(
      length: sites.length,
      child: Scaffold(
        appBar: DashboardAppBar(
          tabBar: TabBar(
            isScrollable: true,
            tabs: sites.map((site) {
              final tabText = site.nickName.isNotEmpty ? site.nickName : site.name;
              return Tab(text: tabText);
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: sites.map((site) {
            final zoneKeys = <GlobalKey>[];
            final scrollController = ScrollController();

            for (int i = 0; i < site.zones.length; i++) {
              zoneKeys.add(GlobalKey());
            }

            if (isWideScreen){
              return Row(
                children: [
                  // Left pane: zone graphs
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: List.generate(site.zones.length, (index) {
                          final zone = site.zones[index];
                          if (!zone.checked) return const SizedBox.shrink();

                          final zoneTitle = zone.nickName.isNotEmpty
                              ? zone.nickName
                              : zone.name;

                          return Card(
                            key: zoneKeys[index],
                            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    'Zone: $zoneTitle',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 600,
                                    child: DashboardGraph(
                                      numberOfZones: numberOfZones += 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  // Right pane: zone jump list
                  Container(
                    width: 350,
                    padding: const EdgeInsets.only(top: 16, right: 12),
                    child: Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Zones", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                itemCount: site.zones.length,
                                itemBuilder: (context, index) {
                                  final zone = site.zones[index];
                                  if (!zone.checked) return const SizedBox.shrink();

                                  final zoneLabel = zone.nickName.isNotEmpty
                                      ? zone.nickName
                                      : zone.name;

                                  return ListTile(
                                    title: Text(zoneLabel),
                                    onTap: () {
                                      final keyContext = zoneKeys[index].currentContext;
                                      if (keyContext != null) {
                                        Scrollable.ensureVisible(
                                          keyContext,
                                          duration: const Duration(milliseconds: 500),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return Container(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: List.generate(site.zones.length, (index) {
                    final zone = site.zones[index];
                    if (!zone.checked) return const SizedBox.shrink();
                    final zoneTitle = zone.nickName.isNotEmpty
                        ? zone.nickName
                        : zone.name;
                    return Card(
                      key: zoneKeys[index],
                      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              'Zone: $zoneTitle',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 600,
                              child: DashboardGraph(
                                numberOfZones: numberOfZones += 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
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