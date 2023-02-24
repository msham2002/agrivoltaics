import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:influxdb_client/api.dart';
import 'app_constants.dart';
import 'pages/login.dart';

void main() async {
  // Register singletons
  final getIt = GetIt.instance;
  getIt.registerSingleton<InfluxDBClient>(InfluxDBClient(
    url: AppConstants.influxdbUrl,
    token: AppConstants.influxdbToken,
    org: AppConstants.influxdbOrg,
    bucket: AppConstants.influxdbBucket,
    debug: AppConstants.influxdbDebug // TODO: disable on release
  ));

  // Launch application
  runApp(const App());
}

// Root application
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Name',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey)
      ),
      home: const LoginPage()
    );
  }
}