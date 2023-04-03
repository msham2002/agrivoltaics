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
          NotificationsButton()
        ],
      ),
      endDrawer: const Drawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              child: const Text('View Data'),
              onPressed: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SitesPage()
                    )
                  )
              },
            ),
            // TODO: implement
            ElevatedButton(
              child: const Text('Manage Sensors'),
              onPressed: () => {debugPrint('Manage Sensors selected')},
            ),
            // TODO: implement
            ElevatedButton(
              child: const Text('Settings'),
              onPressed: () => {debugPrint('Settings selected')},
            )
          ],
        ),
      ),
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
