import 'package:agrivoltaics_flutter_app/app_state.dart';
import 'package:agrivoltaics_flutter_app/pages/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:influxdb_client/api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'firebase_options.dart';
import 'app_constants.dart';
import 'pages/login.dart';

void main() async {
  // Initialize Firebase
  // (https://stackoverflow.com/a/63873689)
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  // Register getIt
  final getIt = GetIt.instance;
  getIt.registerSingleton<InfluxDBClient>(InfluxDBClient(
    url: AppConstants.influxdbUrl,
    token: AppConstants.influxdbToken,
    org: AppConstants.influxdbOrg,
    bucket: AppConstants.influxdbBucket,
    debug: AppConstants.influxdbDebug // TODO: disable on release
  ));

  // Register Google Firebase Auth Provider
  GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
  googleAuthProvider.setCustomParameters({
    'prompt': 'select_account'
  });
  getIt.registerSingleton<GoogleAuthProvider>(googleAuthProvider);

  // Initialize timezone database
  tz.initializeTimeZones();

  // Launch application
  runApp(const App());
}

// Root application
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Vinovoltaics',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey)
        ),
        home: const LoginPage(),
        // home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}