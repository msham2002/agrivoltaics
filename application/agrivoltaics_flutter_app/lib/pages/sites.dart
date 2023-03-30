import 'package:agrivoltaics_flutter_app/app_constants.dart';
import 'package:agrivoltaics_flutter_app/pages/dashboard/dashboard.dart';
import 'package:flutter/material.dart';

class SitesPage extends StatelessWidget {
  const SitesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      endDrawer: const Drawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int site = 1; site <= AppConstants.numSites; site++)...[
              ElevatedButton(
                child: Text('Site ${site}'),
                onPressed: () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DashboardPage(site: site)
                      )
                    )
                },
              )
            ]
          ],
        ),
      ),
    );
  }
}