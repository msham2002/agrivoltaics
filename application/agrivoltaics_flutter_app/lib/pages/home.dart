import 'package:flutter/material.dart';
import 'data.dart';
import 'data_self_hosted.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
                      // builder: (context) => const DataDashboard()
                      builder: (context) => const DataDashboardSelfHosted()
                      // builder: (context) => const DataPointSelection()
                    )
                  )
              },
            ),
            ElevatedButton(
              child: const Text('Manage Sensors'),
              onPressed: () => {print('hello')},
            ),
            ElevatedButton(
              child: const Text('Settings'),
              onPressed: () => {print('hello')},
            )
          ],
        ),
      ),
    );
  }
}
