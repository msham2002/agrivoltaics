import 'package:agrivoltaics_flutter_app/app_constants.dart';
import 'package:agrivoltaics_flutter_app/auth.dart';
import 'package:agrivoltaics_flutter_app/pages/login.dart';
import 'package:agrivoltaics_flutter_app/pages/settings.dart';
import 'package:agrivoltaics_flutter_app/pages/sites.dart';
import 'package:flutter/material.dart';

/*

Home Page
- All navigations redirect back here

*/
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [
          NotificationsButton(),
          // SignOutButton()
        ],
      ),
      endDrawer: const Drawer(),
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
                      builder: (context) => SitesPage(destination: SiteRoute.dashboard)
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
                    builder: (context) => SettingsPage()
                  )
                )
              },
            )
          ],
        ),
      ),
    );
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

/*

Notifications Button
- Opens drawer containing notifications
- Alerts user if there are unread notifications

*/
class NotificationsButton extends StatelessWidget {
  const NotificationsButton({
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
              Scaffold.of(context).openEndDrawer();
            },
            icon: Stack(
              children: const [
                Icon(
                  Icons.notifications,
                ),
                Positioned(
                  child: Icon(
                    Icons.brightness_1,
                    color: Colors.red,
                    size: 9.0
                  )
                )
              ]
            )
          ),
        );
      }
    );
  }
}
