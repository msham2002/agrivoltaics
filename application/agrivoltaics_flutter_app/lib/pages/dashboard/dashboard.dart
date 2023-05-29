import 'dart:async';
import 'dart:math';
import 'dart:math' as math;
import 'package:agrivoltaics_flutter_app/app_constants.dart';
import 'package:agrivoltaics_flutter_app/app_state.dart';
import 'package:agrivoltaics_flutter_app/influx.dart';
import 'package:agrivoltaics_flutter_app/pages/dashboard/dashboard_appbar.dart';
import 'package:agrivoltaics_flutter_app/pages/dashboard/dashboard_drawer.dart';
import 'package:agrivoltaics_flutter_app/pages/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:influxdb_client/api.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/*

Dashboard Page
- Page containing Dashboard related widgets

*/



class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // final appState = Provider.of<AppState>(context);
    return Scaffold(
      body: SafeArea(
        child: Scaffold(
          endDrawer: const DashboardDrawer(),
          appBar: const DashboardAppBar(),
          body: Dashboard()
        ),
      ),
    );
  }
}

/*

Dashboard
- Skeleton for nested graph-related widgets
- Extracted nested graph widget due to its size and complexity

*/
class Dashboard extends StatelessWidget {
late AppState appState;

Dashboard({super.key});

@override
Widget build(BuildContext context) {
  int numberOfGraphs = 0;
  int numberOfZones = 0;

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
  int graphsPerRow = 2;
  int numberOfRows = (numberOfGraphs / graphsPerRow).ceil();

  return LayoutBuilder(
    builder: (context, constraints) {
      double rowWidth = constraints.maxWidth;
      double rowHeight = constraints.maxHeight / numberOfRows;

      return ListView.builder(
        itemCount: numberOfRows,
        itemBuilder: (context, rowIndex) {
          int startIndex = rowIndex * graphsPerRow;
          int endIndex = startIndex + graphsPerRow;
          endIndex = endIndex > numberOfGraphs ? numberOfGraphs : endIndex;

          List<Widget> rowChildren = List.generate(
            endIndex - startIndex,
            (index) =>  Expanded(
              child: DashboardGraph(
                numberOfZones: numberOfZones += 1,
              ),
            ),
          );

          return Container(
            width: rowWidth,
            height: rowHeight,
            child: Row(
              children: rowChildren,
            ),
          );
        },
      );
    },
  );
}
}


// probably add a optional input idk like which zone to draw.
/*

Dashboard Graph
- Main Dashboard widget which displays relevant information in graph form

*/

class DashboardGraph extends StatefulWidget {
  final int numberOfZones;

  const DashboardGraph({Key? key, required this.numberOfZones}) : super(key: key);

  @override
  _DashboardGraphState createState() => _DashboardGraphState(numberOfZones: numberOfZones);
}

class _DashboardGraphState extends State<DashboardGraph>  {
  late int numberOfZones;
  int colorIndex = 0;
  List<Color> legendColorList = [];
  List<Color> currentLegendColors = [];

  _DashboardGraphState({required this.numberOfZones});

Color generateRandomColor({int minIntensityThreshold = 600, double minColorDistance = 200.0, required List<Color> ColorList, required int EntryAmount}) {
  final Random random = Random();

  Color generateColor() {
    int red = random.nextInt(256);
    int green = random.nextInt(256);
    int blue = random.nextInt(256);

    return Color.fromARGB(255, red, green, blue);
  }

  double calculateColorDistance(Color color1, Color color2) {
    final int deltaRed = color1.red - color2.red;
    final int deltaGreen = color1.green - color2.green;
    final int deltaBlue = color1.blue - color2.blue;

    return math.sqrt(deltaRed * deltaRed + deltaGreen * deltaGreen + deltaBlue * deltaBlue);
  }

  Color generateUniqueColor() {
    Color newColor;
    bool isSimilarColor;

    do {
      newColor = generateColor();
      isSimilarColor = ColorList.any((Color color) {
        final double distance = calculateColorDistance(color, newColor);
        return distance < minColorDistance;
      });
    } while (isSimilarColor);
    if (legendColorList.length != EntryAmount) {
      legendColorList.add(newColor);
    } else {
        colorIndex += 1;
        if (colorIndex == EntryAmount && colorIndex != 0) {
          colorIndex = 0;
          return legendColorList[EntryAmount-1];
        }
      return legendColorList[colorIndex-1];
    }

    
    

    return newColor;
  }

  return generateUniqueColor();
}


  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    

    return Consumer<AppState>(
      builder: (context, AppState, child) {
        // Refresh widget according to dashboard state's time interval (real-time data)
        Timer.periodic(AppState.timeInterval.duration!, (Timer t) => {if (this.mounted) setState((){})});



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
              graphTitle += '${appState.sites[i-1].name}, Zone $j';
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
            numberOfZones
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
                      color: generateRandomColor(ColorList: legendColorList, EntryAmount: snapshot.data!.entries.length),
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

// class BarIndicator extends StatelessWidget {
//   const BarIndicator({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Container(
//         width: 40, height: 3,
//         decoration: const BoxDecoration(
//           color: Colors.black,
//           borderRadius: BorderRadius.all(Radius.circular(10)),
//         ),
//       ),
//     );
//   }
// }