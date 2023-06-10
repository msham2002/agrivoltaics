import 'dart:convert';

import 'package:agrivoltaics_flutter_app/app_constants.dart';
import 'package:agrivoltaics_flutter_app/app_state.dart';
import 'package:agrivoltaics_flutter_app/auth.dart';
import 'package:agrivoltaics_flutter_app/pages/login.dart';
import 'package:agrivoltaics_flutter_app/pages/settings.dart';
import 'package:agrivoltaics_flutter_app/pages/sites.dart';
import 'package:agrivoltaics_flutter_app/pages/home/notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dashboard/dashboard.dart';

class HomeState extends StatefulWidget {
  const HomeState({
    super.key
  });

  @override
  State<HomeState> createState() => HomePage();
}

/*

Home Page
- All navigations redirect back here

*/
class HomePage extends State<HomeState> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(
        actions: const [
          NotificationsButton(),
          SignOutButton()
        ],
      ),
      endDrawer: const NotificationsDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              'Vinovoltaics',
              style: TextStyle(
                fontSize: 50
              ),
            ),
            ElevatedButton(
              child: const Text('View Data'),
                    onPressed: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                              DashboardPage(), 
                              maintainState: false // This allows the graph to update after adjusting date and time interval
                    )
                  )
              },
            ),
            // ElevatedButton(
            //   child: const Text('Manage Sensors'),
            //   onPressed: () => {
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => SitesPage(destination: SiteRoute.sensorManagement)
            //         )
            //       )
            //   },
            // ),
            ElevatedButton(
              child: const Text('Settings'),
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage()
                  )
                )
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      AppState appState = context.read<AppState>();
      await getSettings(FirebaseAuth.instance.currentUser?.email, appState);
      // appState.addSite();
      appState.finalizeState();
    });
  }
}

/*

Sign Out button
- Signs out user from Firebase and rest of application

*/
class SignOutButton extends StatelessWidget {
  const SignOutButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => SignOutDialog()
              );
            },
            icon: Icon(Icons.power_settings_new_rounded)
          ),
        );
      }
    );
  }
}

/*

Sign Out Dialog
- Dialog which prompts whether user would like to sign out

*/
class SignOutDialog extends StatelessWidget {
  const SignOutDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sign out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Future<void> signoutPromise = signOut();
            signoutPromise.then((_) => {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage()
                )
              )
            });
          },
          child: const Text('Sign out')
        )
      ]
    );
  }
}

class AppSettings {
  AppSettings(this.body, this.siteChecked);
  AppNotificationBody body;
  String siteChecked;

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    print(json['site1'].toString());
    return AppSettings(
      AppNotificationBody.fromJson(json['settings']),
      json['site1'].toString().split('/')[0]
    );
  }
}

Future<void> getSettings(String? email, AppState appstate) async {
  try {
  http.Response response = await http.get(Uri.parse('https://vinovoltaics-notification-api-6ajy6wk4ca-ul.a.run.app/getSettings?email=${email}'));
  
  if (response.statusCode == 200) {
    appstate.sites = [];
    bool siteChecked = false;
    bool zoneChecked = false;
    bool temperature = false;
    bool humidity = false;
    bool frost = false;
    bool rain = false;
    bool soil = false;
    bool light = false;

    for (int i = 0; i < jsonDecode(response.body)['settings'].length - 2; i++) {
      for (int j = 0; j < jsonDecode(response.body)['settings']['site${i+1}'].length - 1; j++) {
        siteChecked = json.decode(response.body)['settings']['site${i+1}']["site_checked"];
        zoneChecked = json.decode(response.body)['settings']['site${i+1}']["zone${j+1}"]["zone_checked"];
        temperature = json.decode(response.body)['settings']['site${i+1}']["zone${j+1}"]["temperature"];
        humidity = json.decode(response.body)['settings']['site${i+1}']["zone${j+1}"]["humidity"];
        frost = json.decode(response.body)['settings']['site${i+1}']["zone${j+1}"]["frost"];
        rain = json.decode(response.body)['settings']['site${i+1}']["zone${j+1}"]["rain"];
        soil = json.decode(response.body)['settings']['site${i+1}']["zone${j+1}"]["soil"];
        light = json.decode(response.body)['settings']['site${i+1}']["zone${j+1}"]["light"];

        if (j == 0) {
          appstate.addSiteFromDB(siteChecked, zoneChecked, humidity, temperature, light, frost, rain, soil);
        } else {
          appstate.addZoneFromDB(i, zoneChecked, humidity, temperature, light, frost, rain, soil);
        }
      }
    }

    appstate.singleGraphToggle = json.decode(response.body)['settings']['singleGraphToggle'];
    appstate.timezone = tz.getLocation(json.decode(response.body)['settings']['timeZone']); 
  }

  // ignore: empty_catches
  } catch (e) {
    print(e);
  }
}
