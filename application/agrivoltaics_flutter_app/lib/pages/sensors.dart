import 'dart:convert';

import 'package:agrivoltaics_flutter_app/app_constants.dart';
import 'package:agrivoltaics_flutter_app/pages/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SensorsPage extends StatelessWidget {
  SensorsPage({super.key, required int site});
  int site = 1;

  Future<List<Map<String, Map<String, String>>>> getSensors(String uri) async {
    uri += '';
    http.Response response = http.Response('', 400);
    try {
      response = await http.get(Uri.https(uri));
    } catch (error) {
      debugPrint(error.toString());
    }
    // {
    //   "sensors": [
    //     {
    //       "26": {
    //         "name": "",
    //         "state": "off"
    //       }
    //     },
    //     {
    //       "33": {
    //         "name": "",
    //         "state": "on"
    //       }
    //     }
    //   ]
    // }

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body)['sensors'];
      return json;
    } else {
      return [];
    }
  }

  void toggleSensor(Map<String, Map<String, String>> sensor, String uri) async {
    String sensorPin = sensor.keys.first;
    Map<String, String> sensorValues = sensor.values.first;
    String newState = sensorValues['state'] == 'on' ? 'off' : 'on';
    uri += '/${sensorPin}/${newState}';
    http.Response response = await http.get(Uri.parse(uri));
    debugPrint(response.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<List<Map<String, Map<String, String>>>>(
        future: getSensors(AppConstants.siteConfiguration[1]!),
        builder: (context, AsyncSnapshot<List<Map<String, Map<String, String>>>> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (Map<String, Map<String, String>> sensor in snapshot.data!)...[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          child: Text('Sensor ${sensor.keys.first}'),
                          onPressed: () => {
                            // Send on/off request
                            // Then refresh Widget state based on new board state
                            toggleSensor(sensor, AppConstants.siteConfiguration[1]!)
                          },
                        ),
                      )
                    ]
                  ],
                ),
              ),
            );
          } else {
            // The results have not yet been returned. Indicate loading
            return Center(child: const CircularProgressIndicator());
          }
        }
      ),
    );
  }
}